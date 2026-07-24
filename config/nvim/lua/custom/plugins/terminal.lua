-- Integrated terminal panel (Cursor-like)

return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<leader>tt', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle terminal' },
      { '<C-\\>', '<cmd>ToggleTerm direction=float<cr>', desc = 'Float terminal', mode = { 'n', 't' } },
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Float terminal' },
      { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=60<cr>', desc = 'Vertical terminal' },
    },
    opts = {
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = false,
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = 'horizontal',
      close_on_exit = true,
      float_opts = {
        border = 'curved',
        winblend = 0,
      },
    },
  },
}
