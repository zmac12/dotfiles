-- IDE chrome: tabs, Problems panel, sticky scope header

local excluded_filetypes = {
  ['neo-tree'] = true,
  Avante = true,
  AvanteInput = true,
  AvanteSelectedFiles = true,
  AvanteSelectedCode = true,
  AvanteTodos = true,
  AvantePromptInput = true,
  trouble = true,
  lazy = true,
  mason = true,
  notify = true,
  qf = true,
  toggleterm = true,
  TelescopePrompt = true,
  alpha = true,
  dashboard = true,
}

--- Switch to a non-fixed window before changing buffers (Avante/neo-tree use winfixbuf).
local function with_editable_win(fn)
  return function(...)
    if vim.wo.winfixbuf then
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) and not vim.api.nvim_get_option_value('winfixbuf', { win = win }) then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end
    if vim.wo.winfixbuf then
      return
    end
    return fn(...)
  end
end

local function cycle_buffer(direction)
  with_editable_win(function()
    local bufferline = require 'bufferline'
    if direction < 0 then
      bufferline.cycle(-1)
    else
      bufferline.cycle(1)
    end
  end)()
end

return {
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Pin buffer' },
      { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete non-pinned buffers' },
      {
        '<S-h>',
        function()
          cycle_buffer(-1)
        end,
        desc = 'Prev buffer',
      },
      {
        '<S-l>',
        function()
          cycle_buffer(1)
        end,
        desc = 'Next buffer',
      },
      {
        '[b',
        function()
          cycle_buffer(-1)
        end,
        desc = 'Prev buffer',
      },
      {
        ']b',
        function()
          cycle_buffer(1)
        end,
        desc = 'Next buffer',
      },
    },
    opts = {
      options = {
        mode = 'buffers',
        diagnostics = 'nvim_lsp',
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        -- Keep sidebar/UI buffers out of the tabline so cycling can't
        -- land on them or make them appear/disappear as tabs.
        custom_filter = function(buf_number)
          if not vim.api.nvim_buf_is_valid(buf_number) then
            return false
          end
          local ft = vim.bo[buf_number].filetype
          local bt = vim.bo[buf_number].buftype
          if excluded_filetypes[ft] then
            return false
          end
          if bt ~= '' then
            return false
          end
          return true
        end,
        left_mouse_command = with_editable_win(function(buf_id)
          if vim.api.nvim_buf_is_valid(buf_id) then
            vim.api.nvim_set_current_buf(buf_id)
          end
        end),
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Explorer',
            highlight = 'Directory',
            text_align = 'left',
          },
          {
            filetype = 'Avante',
            text = 'Avante',
            highlight = 'Directory',
            text_align = 'left',
          },
        },
      },
    },
  },

  {
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle' },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer diagnostics (Trouble)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP refs/defs (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location list (Trouble)' },
    },
    opts = {},
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      enable = true,
      max_lines = 3,
      multiline_threshold = 1,
      trim_scope = 'outer',
    },
  },
}
