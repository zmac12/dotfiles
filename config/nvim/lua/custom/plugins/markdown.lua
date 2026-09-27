-- Markdown: render-markdown.nvim renders headers, tables, code blocks, etc.
-- inline in the buffer as you edit (no separate preview window/tab).

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      -- Table borders are drawn with `virt_text_pos = 'overlay'`, pinned to a
      -- buffer column, and the renderer has no wrap handling. That is fine here
      -- only because markdown buffers set `nowrap` (see after/ftplugin/markdown.lua).
      -- If wrap is ever turned back on for a file with wide tables, expect the
      -- borders to shred and turn this off.
      pipe_table = { preset = 'double' },
    },
    keys = {
      { '<localleader>mt', '<cmd>RenderMarkdown toggle<cr>', desc = 'Markdown: toggle render', ft = 'markdown' },
    },
  },
}
