-- Wrapping is what breaks markdown rendering. Anything drawn with virtual text
-- pinned to a buffer column -- render-markdown's table borders, indent-blankline's
-- guides -- lands on the wrong screen cell once a row soft-wraps. Prose here is
-- already hard-wrapped, so `nowrap` costs nothing and only tables side-scroll.
vim.opt_local.wrap = false

-- For the occasional file with genuinely long prose lines. `linebreak` and
-- `breakindent` only take effect while wrap is on, so they sit inert otherwise:
-- breaks land on spaces and wrapped text hangs two columns in.
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.breakindentopt = 'shift:2'

vim.keymap.set('n', '<localleader>mw', function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify('wrap ' .. (vim.wo.wrap and 'on' or 'off'))
end, { buffer = true, desc = 'Markdown: toggle wrap' })
