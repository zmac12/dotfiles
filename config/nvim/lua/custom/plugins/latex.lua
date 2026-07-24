-- LaTeX: VimTeX (compile / view / motions) + works with texlab LSP from Mason

return {
  {
    'lervag/vimtex',
    lazy = false, -- VimTeX recommends not lazy-loading
    init = function()
      vim.g.vimtex_mappings_enabled = 1
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_compiler_latexmk = {
        build_dir = '',
        callback = 1,
        continuous = 1,
        executable = 'latexmk',
        options = {
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
        },
      }

      -- macOS: Skim is the usual PDF viewer for forward/inverse search.
      -- Install: brew install --cask skim
      -- Fallback: open with the system default PDF app.
      if vim.fn.has 'mac' == 1 then
        if vim.fn.isdirectory '/Applications/Skim.app' == 1 or vim.fn.executable 'skim' == 1 then
          vim.g.vimtex_view_method = 'skim'
          vim.g.vimtex_view_skim_sync = 1
          vim.g.vimtex_view_skim_activate = 1
        else
          vim.g.vimtex_view_method = 'general'
        end
      else
        vim.g.vimtex_view_method = 'general'
      end

      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_syntax_conceal_disable = 0
    end,
    keys = {
      { '<localleader>ll', '<cmd>VimtexCompile<cr>', desc = 'VimTeX: compile', ft = 'tex' },
      { '<localleader>lv', '<cmd>VimtexView<cr>', desc = 'VimTeX: view PDF', ft = 'tex' },
      { '<localleader>lk', '<cmd>VimtexStop<cr>', desc = 'VimTeX: stop compile', ft = 'tex' },
      { '<localleader>lc', '<cmd>VimtexClean<cr>', desc = 'VimTeX: clean', ft = 'tex' },
      { '<localleader>lt', '<cmd>VimtexTocToggle<cr>', desc = 'VimTeX: TOC', ft = 'tex' },
      { '<localleader>le', '<cmd>VimtexErrors<cr>', desc = 'VimTeX: errors', ft = 'tex' },
    },
  },
}
