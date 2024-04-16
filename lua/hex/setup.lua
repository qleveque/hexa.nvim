local M = {}

M.setup_search = function()
  vim.cmd[[
    nn <buffer> / :HexSearch 
    nn <buffer> ? :HexSearchBack 
  ]]
end

M.setup_ASCII = function(cfg)
  M.setup_search()
  vim.cmd[[
    " cursor
    au CursorMoved,CursorMovedI <buffer> lua require'hex.cursor'.on_ASCII_cursor_move()
    au BufLeave <buffer> lua require'hex.cursor'.on_ASCII_leave()
    au BufEnter <buffer> lua require'hex'.on_ASCII_enter()
    " when outside changes finished, sync
    au FileChangedShellPost <buffer> lua require'hex'.on_changed_shell()
    " on closed
    au WinClosed <buffer> lua require'hex.references'.file().ascii:on_closed()
  ]]
  local buf = vim.api.nvim_get_current_buf()
  local skm = vim.api.nvim_buf_set_keymap
  skm(buf, 'n', cfg.keymaps.replace_ascii,
    ':lua require"hex.actions".replace_in_ASCII()<CR>',
  {})
  skm(buf, 'n', cfg.keymaps.undo_ascii,
    ':lua require"hex.actions".undo_from_ASCII()<CR>',
  {})
  skm(buf, 'n', cfg.keymaps.redo_ascii,
    ':lua require"hex.actions".redo_from_ASCII()<CR>',
  {})
  skm(buf, 'n', cfg.keymaps.run, ':lua require"hex".run()<CR>', {})
end

M.setup_LINE = function(cfg)
  vim.cmd[[
    " when outside changes finished, sync
    au FileChangedShellPost <buffer> lua require'hex'.on_changed_shell()
    " on closed
    au WinClosed <buffer> lua require'hex.references'.file().line:on_closed()
  ]]
end

M.setup_HEX = function(cfg)
  M.setup_search()
  vim.cmd[[
    setl nonu
    " enter
    au BufEnter <buffer> lua require'hex'.open_wins()
    " cursor
    au CursorMoved,CursorMovedI <buffer> lua require'hex.cursor'.on_HEX_cursor_move()
    au BufLeave <buffer> lua require'hex.cursor'.on_HEX_leave()
    " close other windows when hidden
    au BufHidden <buffer> lua require'hex'.on_HEX_hidden()
    " close other windows instead of HEX
    au WinClosed <buffer> lua require'hex.references'.on_HEX_close()
    " remove scroll bind when saved
    au BufWritePost <buffer> lua require'hex'.on_HEX_saved()
  ]]

  local buf = vim.api.nvim_get_current_buf()
  local skm = vim.api.nvim_buf_set_keymap
  skm(buf, 'n', cfg.keymaps.reformat_hex, ':HexReformat<CR>', {})
  skm(buf, 'n', cfg.keymaps.run, ':lua require"hex".run()<CR>', {})
end

return M
