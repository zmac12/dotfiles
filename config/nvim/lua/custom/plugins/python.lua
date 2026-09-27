-- Python IDE layer for the ISyE 6740 term project (and Python work generally).
--
-- Toolchain is Astral-first: `ruff` for lint+format (LSP), `ty` for type
-- checking (LSP), `uv` for envs. No pip/black/isort/pyright.
--
-- Three pieces live here:
--   1. `ty` language server, resolved from the project's own .venv
--   2. Python debugging via nvim-dap-python + debugpy
--   3. Inline notebook output: Molten + image.nvim + jupytext
--
-- The `ruff` LSP and the conform formatter entry are wired in init.lua
-- (servers table + formatters_by_ft) so they follow the existing Mason flow.

--- Find the interpreter for the current project, preferring a local `.venv`.
local function project_python()
  local root = vim.fs.root(0, { 'pyproject.toml', '.git', 'uv.lock' }) or vim.fn.getcwd()
  local candidate = root .. '/.venv/bin/python'
  if vim.uv.fs_stat(candidate) then
    return candidate
  end
  return vim.fn.exepath 'python3'
end

--- Find a `ty` binary: project .venv first, then a uv tool install, then PATH.
local function ty_cmd()
  local root = vim.fs.root(0, { 'pyproject.toml', '.git', 'uv.lock' }) or vim.fn.getcwd()
  local local_ty = root .. '/.venv/bin/ty'
  if vim.uv.fs_stat(local_ty) then
    return { local_ty, 'server' }
  end
  if vim.fn.executable 'ty' == 1 then
    return { 'ty', 'server' }
  end
  return { 'uv', 'run', '--quiet', 'ty', 'server' }
end

return {
  ---------------------------------------------------------------------------
  -- 1. `ty` type-checking language server (Astral).
  ---------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    optional = true,
    opts = function()
      vim.lsp.config('ty', {
        cmd = ty_cmd(),
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'ty.toml', 'uv.lock', '.git' },
        settings = {
          ty = {
            experimental = { completions = { enable = true } },
          },
        },
      })
      vim.lsp.enable 'ty'
    end,
  },

  ---------------------------------------------------------------------------
  -- 2. Debugging: Python adapter for the existing kickstart dap setup.
  ---------------------------------------------------------------------------
  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = { 'mfussenegger/nvim-dap', 'rcarriga/nvim-dap-ui' },
    config = function()
      local mason_dbg = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
      local adapter = vim.uv.fs_stat(mason_dbg) and mason_dbg or project_python()
      require('dap-python').setup(adapter)
      require('dap-python').resolve_python = project_python
    end,
    keys = {
      { '<leader>dn', function() require('dap-python').test_method() end, desc = 'Debug: nearest test method', ft = 'python' },
      { '<leader>df', function() require('dap-python').test_class() end, desc = 'Debug: test class', ft = 'python' },
      { '<leader>ds', function() require('dap-python').debug_selection() end, mode = 'v', desc = 'Debug: selection', ft = 'python' },
    },
  },

  ---------------------------------------------------------------------------
  -- 3a. Terminal image rendering (Ghostty speaks the Kitty graphics protocol;
  --     magick_cli avoids needing the luarocks magick binding).
  ---------------------------------------------------------------------------
  {
    '3rd/image.nvim',
    ft = { 'python', 'markdown', 'quarto' },
    opts = {
      backend = 'kitty',
      processor = 'magick_cli',
      integrations = {
        markdown = { enabled = true, only_render_image_at_cursor = true },
      },
      max_width_window_percentage = 70,
      max_height_window_percentage = 45,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'snacks_notif', '' },
    },
  },

  ---------------------------------------------------------------------------
  -- 3b. Molten: run cells against a Jupyter kernel, plots render inline.
  ---------------------------------------------------------------------------
  {
    'benlubas/molten-nvim',
    version = '^1.0.0',
    ft = { 'python', 'markdown', 'quarto' },
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    init = function()
      local host = vim.fn.expand '~/.venvs/nvim/bin/python'
      if vim.uv.fs_stat(host) then
        vim.g.python3_host_prog = host
      end

      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 24
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_output_virt_lines = true
    end,
    keys = {
      { '<leader>mi', '<cmd>MoltenInit parishreg<cr>', desc = 'Molten: init parishreg kernel' },
      { '<leader>mI', '<cmd>MoltenInit<cr>', desc = 'Molten: init (pick kernel)' },
      { '<leader>ml', '<cmd>MoltenEvaluateLine<cr>', desc = 'Molten: eval line' },
      { '<leader>mc', '<cmd>MoltenReevaluateCell<cr>', desc = 'Molten: re-eval cell' },
      { '<leader>mo', '<cmd>MoltenEnterOutput<cr>', desc = 'Molten: enter output' },
      { '<leader>mh', '<cmd>MoltenHideOutput<cr>', desc = 'Molten: hide output' },
      { '<leader>md', '<cmd>MoltenDelete<cr>', desc = 'Molten: delete cell' },
      { '<leader>mr', '<cmd>MoltenRestart!<cr>', desc = 'Molten: restart kernel' },
      { '<leader>mv', ':<C-u>MoltenEvaluateVisual<cr>gv', mode = 'v', desc = 'Molten: eval visual' },
      {
        '<leader>me',
        function()
          local start_line = vim.fn.search('^# %%', 'bcnW')
          local end_line = vim.fn.search('^# %%', 'nW')
          start_line = start_line == 0 and 1 or start_line + 1
          end_line = end_line == 0 and vim.fn.line '$' or end_line - 1
          vim.cmd(('MoltenEvaluateRange %d %d'):format(start_line, end_line))
        end,
        desc = 'Molten: eval # %% cell',
      },
    },
  },

  ---------------------------------------------------------------------------
  -- 3c. Jupytext: edit .ipynb as plain `# %%` python buffers.
  ---------------------------------------------------------------------------
  {
    'GCBallesteros/jupytext.nvim',
    lazy = false,
    opts = {
      style = 'percent',
      output_extension = 'py',
      force_ft = 'python',
    },
  },
}
