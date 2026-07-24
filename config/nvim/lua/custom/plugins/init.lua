-- Custom Cursor-max plugins live in this directory (imported via lazy).
--
-- After changing plugins:
--   1. Restart Neovim
--   2. Run :Lazy sync
--   3. :Codeium Auth  (first time)
--   4. npm i -g @agentclientprotocol/claude-agent-acp  (for Avante Claude Code ACP)
--   5. Optional: :AvanteSwitchProvider claude  (Claude Pro/Max browser auth fallback)
--
-- Keymap cheat sheet:
--   \              Neo-tree file explorer
--   <leader>sf/sg  Find files / live grep  (Cmd-P / Cmd-Shift-F)
--   <leader>aa/at  Avante ask / toggle sidebar
--   <leader>ae     Avante edit selection
--   <leader>tt     Toggle terminal
--   <leader>xx     Trouble diagnostics
--   <leader>gg     Neogit
--   s / S          Flash jump / treesitter select

return {}
