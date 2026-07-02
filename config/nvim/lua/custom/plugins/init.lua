return {

  -- lazygit inside neovim — <leader>gg to open
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = { { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' } },
  },

  -- highlight TODO/FIXME/HACK/NOTE comments and list them
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
    keys = {
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Search Todos' },
    },
  },

  -- better diagnostics/quickfix list — <leader>xx to toggle
  {
    'folke/trouble.nvim',
    opts = {},
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',              desc = 'Diagnostics' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>',                  desc = 'Location List' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>',                   desc = 'Quickfix List' },
    },
  },

  -- surround text objects — ys, cs, ds (e.g. ysiw" to wrap word in quotes)
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function() require('nvim-surround').setup() end,
  },

  -- yazi file manager — <leader>yy to open alongside neovim
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>yy', '<cmd>Yazi<cr>',          desc = 'Yazi (cwd)' },
      { '<leader>yw', '<cmd>Yazi cwd<cr>',      desc = 'Yazi (file dir)' },
    },
    opts = { open_for_directories = true },
  },

}
