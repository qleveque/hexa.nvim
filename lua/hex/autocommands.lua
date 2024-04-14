local search = require'hex.search'

local M = {}

M.setup_ASCII = function()
  vim.api.nvim_command(":setl nonu ft=hexASCII noma")

  -- search
  search.setup()

  -- cursor
  vim.cmd("au CursorMoved,CursorMovedI <buffer> lua require'hex.cursor'.on_ASCII_cursor_move()")

  -- on close
  vim.cmd("au WinClosed <buffer> lua require'hex.references'.on_ASCII_close()")
  vim.cmd("au BufHidden,BufUnload <buffer> lua require'hex.references'.on_ASCII_unloaded()")

  -- on enter/leave
  vim.cmd("au BufEnter <buffer> lua require'hex'.on_ASCII_enter()")
  vim.cmd("au BufLeave <buffer> lua require'hex'.on_ASCII_leave()")

  -- rebind scroll and cursor on properly loaded (prevent jumps when reloading)
  vim.cmd("au FileChangedShellPost <buffer> lua require'hex.utils'.bind_scroll_and_cursor()")

  -- replace
  vim.api.nvim_buf_set_keymap(
    vim.api.nvim_get_current_buf(), 'n', 'r',
    ':lua require"hex.utils".replace_in_ASCII()<CR>',
    { noremap = true, silent = true }
  )
  -- undo
  vim.api.nvim_buf_set_keymap(
    vim.api.nvim_get_current_buf(), 'n', 'u',
    ':lua require"hex.utils".undo_from_ASCII()<CR>',
    { noremap = true, silent = true }
  )
end

M.setup_HEX = function(file)
  -- search
  search.setup()

  -- cursor
  vim.cmd("au CursorMoved,CursorMovedI <buffer> lua require'hex.cursor'.on_HEX_cursor_move()")

  -- on close
  vim.cmd("au WinClosed <buffer> lua require'hex.references'.on_HEX_close()")
  vim.cmd("au BufHidden,BufUnload <buffer> lua require'hex.references'.on_HEX_unloaded()")

  -- on enter/leave
  vim.cmd("au BufEnter <buffer> lua require'hex'.on_HEX_enter()")
  vim.cmd("au BufLeave <buffer> lua require'hex'.on_HEX_leave()")

  -- open ascii automatically
  vim.cmd("au BufWinEnter <buffer> lua require'hex'.open_ASCII()")

  -- dump ascii
  vim.cmd("au BufWritePost <buffer> lua require'hex'.on_HEX_saved()")

  -- clear references
  vim.cmd("au BufDelete <buffer> lua require'hex'.on_HEX_deleted()")

  -- reformat
  vim.api.nvim_buf_set_keymap(
    vim.api.nvim_get_current_buf(),
    'n',
    '<leader>f',
    ':lua require"hex".reformat_HEX()<CR>',
    { noremap = true, silent = true }
  )
end

return M
