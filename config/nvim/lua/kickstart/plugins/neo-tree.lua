-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

--- \ focuses the explorer, or returns to the previous window if already in it.
--- Neo-tree stays open either way. Use <leader>e to actually hide/show it.
local function neo_tree_focus_or_return()
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd 'wincmd p'
  else
    vim.cmd 'Neotree filesystem focus left'
  end
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', neo_tree_focus_or_return, desc = 'Focus Neo-tree / return to editor' },
    { '<leader>e', '<cmd>Neotree filesystem toggle left<cr>', desc = 'Toggle [E]xplorer' },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = 'rounded',
    window = {
      position = 'left',
      width = 32,
      mappings = {
        -- Stay open; just jump back to the previous window
        ['\\'] = function()
          vim.cmd 'wincmd p'
        end,
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
      window = {
        mappings = {
          ['\\'] = function()
            vim.cmd 'wincmd p'
          end,
        },
      },
    },
  },
}
