-- Cursor-like AI agent / Composer sidebar via avante.nvim
--
-- Default: Claude Pro/Max via Avante's native auth (auth_type = "max")
--   First use: complete browser OAuth once; token is saved to
--   ~/.local/share/nvim/avante/claude-auth.json and won't prompt again.
--
-- Optional ACP (needs ANTHROPIC_API_KEY — Claude Pro OAuth is blocked by Anthropic ToS):
--   :AvanteSwitchProvider claude-code
--
-- Optional Cursor Agent ACP:
--   :AvanteSwitchProvider cursor-agent

return {
  {
    'yetone/avante.nvim',
    -- Load only when you open Avante — avoids OAuth popup on every Neovim start
    version = false, -- Never set to "*"
    build = vim.fn.has 'win32' ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' or 'make',
    cmd = {
      'AvanteAsk',
      'AvanteChat',
      'AvanteToggle',
      'AvanteEdit',
      'AvanteFocus',
      'AvanteRefresh',
      'AvanteSwitchProvider',
      'AvanteSwitchModel',
      'AvanteClear',
      'AvanteShowRepoMap',
      'AvanteBuild',
    },
    keys = {
      {
        '<leader>aa',
        function()
          require('avante.api').ask()
        end,
        desc = 'Avante: ask',
        mode = { 'n', 'v' },
      },
      {
        '<leader>at',
        function()
          require('avante.api').toggle()
        end,
        desc = 'Avante: toggle',
      },
      {
        '<leader>ae',
        function()
          require('avante.api').edit()
        end,
        desc = 'Avante: edit',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ar',
        function()
          require('avante.api').refresh()
        end,
        desc = 'Avante: refresh',
      },
      {
        '<leader>af',
        function()
          require('avante.api').focus()
        end,
        desc = 'Avante: focus',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-telescope/telescope.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-tree/nvim-web-devicons',
      'stevearc/dressing.nvim',
      {
        'HakonHarnes/img-clip.nvim',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
            use_absolute_path = true,
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    opts = {
      instructions_file = 'avante.md',
      provider = 'claude',
      providers = {
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-sonnet-4-20250514',
          auth_type = 'max',
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
      },
      acp_providers = {
        ['claude-code'] = {
          command = 'claude-agent-acp',
          args = {},
          env = {
            NODE_NO_WARNINGS = '1',
            ANTHROPIC_API_KEY = os.getenv 'ANTHROPIC_API_KEY',
          },
        },
        ['cursor-agent'] = {
          command = 'cursor-agent',
          args = { 'acp' },
          env = {
            CURSOR_API_KEY = os.getenv 'CURSOR_API_KEY',
          },
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        acp_follow_agent_locations = true,
      },
      selector = {
        provider = 'telescope',
      },
      input = {
        provider = 'dressing',
      },
    },
  },
}
