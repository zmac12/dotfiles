-- Swift / iOS IDE layer: build, run, test and debug Xcode projects without
-- leaving Neovim. Xcode.app must still be installed; everything here drives
-- its command-line tools (xcodebuild, simctl, sourcekit-lsp, lldb-dap).
--
-- Pieces:
--   1. sourcekit-lsp from the active Xcode toolchain (not Mason)
--   2. xcodebuild.nvim for build / run / test / device & scheme pickers
--   3. its nvim-dap integration, reusing the kickstart debug UI
--   4. swiftformat (conform) and swiftlint (kickstart lint.lua)
--   The Swift treesitter parser is in init.lua's `languages` list.
--
-- CLI tools come from the Brewfile "swift / iOS" section.
--
-- Per project (run once from the project root):
--   :XcodebuildSetup      pick project, scheme, device; writes .nvim/xcodebuild
--   it also runs `xcode-build-server config`, which writes buildServer.json so
--   sourcekit-lsp understands the .xcodeproj. Restart the LSP afterwards.
--
-- Keys live under <leader>i ("iOS"). <leader>x is Trouble, <leader>b bufferline.
--   <leader>ii  action picker        <leader>ir  build & run
--   <leader>ib  build                <leader>it  test (visual: selected)
--   <leader>iT  test this class      <leader>id  select device
--   <leader>il  toggle logs          <leader>ie  test explorer
--   <leader>ic  coverage toggle      <leader>iC  coverage report
--   <leader>ia  code actions         <leader>iq  quickfix line
--   <leader>ip  project manager      <leader>is  setup wizard
-- Debug (joins the existing <leader>d group):
--   <leader>dd  build & debug        <leader>dr  debug without building
--   <leader>dt  debug tests          <leader>dT  debug class tests
--   <leader>dx  stop debugging       (breakpoints stay <leader>db / dB)

--- True when Neovim starts inside something xcodebuild.nvim can drive.
local function in_apple_project()
  local cwd = vim.fn.getcwd()
  if vim.uv.fs_stat(cwd .. '/Package.swift') or vim.uv.fs_stat(cwd .. '/project.yml') then
    return true
  end
  -- Shallow scan only: an unbounded vim.fs.find from ~ would crawl the whole
  -- home directory on every startup.
  for name, kind in vim.fs.dir(cwd, { depth = 2 }) do
    if kind == 'directory' and (name:match '%.xcodeproj$' or name:match '%.xcworkspace$') then
      return true
    end
  end
  return false
end

--- Project root for sourcekit-lsp: buildServer.json beats Package.swift beats git.
local function swift_root(bufnr, on_dir)
  local root = vim.fs.root(bufnr, { 'buildServer.json' })
    or vim.fs.root(bufnr, { 'Package.swift' })
    or vim.fs.root(bufnr, function(name)
      return name:match '%.xcworkspace$' or name:match '%.xcodeproj$'
    end)
    or vim.fs.root(bufnr, { '.git' })
  on_dir(root)
end

return {
  ---------------------------------------------------------------------------
  -- 1. sourcekit-lsp. `xcrun` resolves it from whichever Xcode is selected
  --    with xcode-select, so it always matches the compiler that builds.
  ---------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    optional = true,
    opts = function()
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities(),
        -- sourcekit-lsp relies on file watching to notice new files.
        { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
      )
      vim.lsp.config('sourcekit', {
        cmd = { 'xcrun', 'sourcekit-lsp' },
        -- Swift only: the lspconfig default also claims C/C++, which would
        -- fight any future clangd setup.
        filetypes = { 'swift', 'objc', 'objcpp' },
        root_dir = swift_root,
        capabilities = capabilities,
      })
      vim.lsp.enable 'sourcekit'
    end,
  },

  ---------------------------------------------------------------------------
  -- 2 + 3. xcodebuild.nvim and its debugger integration.
  ---------------------------------------------------------------------------
  {
    'wojciech-kulik/xcodebuild.nvim',
    cond = in_apple_project,
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope.nvim', -- picker
      'MunifTanjim/nui.nvim', -- coverage report window
      'nvim-neo-tree/neo-tree.nvim', -- file ops update the .xcodeproj
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
    },
    config = function()
      require('xcodebuild').setup {
        show_build_progress_bar = false, -- fidget shows progress instead
        logs = {
          auto_open_on_failed_build = true,
          auto_open_on_failed_tests = true,
          auto_close_on_app_launch = true,
          only_summary = true,
          notify = function(message, severity)
            vim.notify(message, severity, { title = 'xcodebuild' })
          end,
        },
        code_coverage = { enabled = true },
        integrations = {
          -- Keep buildServer.json in step with the selected scheme.
          xcode_build_server = { enabled = true },
          neo_tree = { enabled = true },
          pymobiledevice = { enabled = true },
        },
      }

      local dap = require 'xcodebuild.integrations.dap'
      dap.setup() -- lldb-dap from Xcode 16+; no codelldb needed

      local map = function(lhs, rhs, desc, mode)
        vim.keymap.set(mode or 'n', lhs, rhs, { desc = desc })
      end
      map('<leader>ii', '<cmd>XcodebuildPicker<cr>', 'iOS: actions')
      map('<leader>is', '<cmd>XcodebuildSetup<cr>', 'iOS: setup project')
      map('<leader>ip', '<cmd>XcodebuildProjectManager<cr>', 'iOS: project manager')
      map('<leader>ib', '<cmd>XcodebuildBuild<cr>', 'iOS: build')
      map('<leader>ir', '<cmd>XcodebuildBuildRun<cr>', 'iOS: build & run')
      map('<leader>it', '<cmd>XcodebuildTest<cr>', 'iOS: test')
      map('<leader>it', '<cmd>XcodebuildTestSelected<cr>', 'iOS: test selected', 'v')
      map('<leader>iT', '<cmd>XcodebuildTestClass<cr>', 'iOS: test class')
      map('<leader>ie', '<cmd>XcodebuildTestExplorerToggle<cr>', 'iOS: test explorer')
      map('<leader>id', '<cmd>XcodebuildSelectDevice<cr>', 'iOS: select device')
      map('<leader>il', '<cmd>XcodebuildToggleLogs<cr>', 'iOS: toggle logs')
      map('<leader>ic', '<cmd>XcodebuildToggleCodeCoverage<cr>', 'iOS: coverage toggle')
      map('<leader>iC', '<cmd>XcodebuildShowCodeCoverageReport<cr>', 'iOS: coverage report')
      map('<leader>ia', '<cmd>XcodebuildCodeActions<cr>', 'iOS: code actions')
      map('<leader>iq', '<cmd>XcodebuildQuickfixLine<cr>', 'iOS: quickfix line')

      map('<leader>dd', dap.build_and_debug, 'Debug: build & debug (iOS)')
      map('<leader>dr', dap.debug_without_build, 'Debug: run without build (iOS)')
      map('<leader>dt', dap.debug_tests, 'Debug: tests (iOS)')
      map('<leader>dT', dap.debug_class_tests, 'Debug: class tests (iOS)')
      map('<leader>dx', dap.terminate_session, 'Debug: stop (iOS)')
    end,
  },

  ---------------------------------------------------------------------------
  -- 4. Formatting. Merged into the conform spec in init.lua.
  --    swiftformat reads a .swiftformat file from the project if present.
  ---------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = { formatters_by_ft = { swift = { 'swiftformat' } } },
  },
}
