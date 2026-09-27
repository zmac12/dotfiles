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
  -- netrw is disabled in init.lua, so load Neo-tree when Neovim is started
  -- on a directory (`nvim .`); it then takes over that buffer.
  init = function()
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('neo_tree_start_directory', { clear = true }),
      once = true,
      callback = function()
        if package.loaded['neo-tree'] then
          return
        end
        local stat = vim.uv.fs_stat(vim.fn.argv(0) --[[@as string]])
        if stat and stat.type == 'directory' then
          require 'neo-tree'
        end
      end,
    })
  end,
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
      -- `nvim .` / `:e dir` open Neo-tree in that window, like netrw did
      hijack_netrw_behavior = 'open_current',
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
