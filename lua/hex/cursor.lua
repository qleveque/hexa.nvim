local refs = require'hex.references'
local u = require'hex.utils'

file_to_column = {}
file_was_ascii = {}

M = {}

local HEX_to_ASCII_column = function(col)
  local l
  if refs.is_binary() then l = 9 else l = 3 end
  return u.int_div(col, l)
end

local ASCII_to_HEX_column = function(col)
  local l
  if refs.is_binary() then l = 9 else l = 3 end
  return col * l
end

local highlight_ASCII_cursor = function(ASCII_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local c = HEX_to_ASCII_column(cursor[2])
  vim.api.nvim_buf_clear_highlight(ASCII_buf, 3, 0, -1)
  vim.api.nvim_buf_add_highlight(ASCII_buf, 3, 'HexFocus', cursor[1] - 1, c, c+1)
end

local highlight_HEX_cursor = function(HEX_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local c = ASCII_to_HEX_column(cursor[2])
  vim.api.nvim_buf_clear_highlight(HEX_buf, 3, 0, -1)
  local l
  if refs.is_binary() then l = 8 else l = 2 end
  vim.api.nvim_buf_add_highlight(HEX_buf, 3, 'HexFocus', cursor[1] - 1, c, c + l)
end

local move_to_col = function(col)
  if col == nil then
    return
  end
  vim.cmd('normal! 0')
  if col > 0 then
    vim.cmd('normal! '..col..'l')
  end
end

M.on_HEX_enter = function(file)
  if file_was_ascii[file] then
    move_to_col(file_to_column[file])
  end
end

M.on_ASCII_enter = function(file)
  if not file_was_ascii[file] then
    local c = file_to_column[file]
    move_to_col(HEX_to_ASCII_column(c))
  end
end

M.on_HEX_leave = function(file)
  local cursor = vim.api.nvim_win_get_cursor(0)
  file_to_column[file] = cursor[2]
  file_was_ascii[file] = false
end

M.on_ASCII_leave = function(file)
  local cursor = vim.api.nvim_win_get_cursor(0)
  file_to_column[file] = ASCII_to_HEX_column(cursor[2])
  file_was_ascii[file] = true
end

M.on_HEX_cursor_move = function()
  local ASCII_buf = refs.get_current_ASCIIbuf()
  if ASCII_buf == nil then return end
  highlight_ASCII_cursor(ASCII_buf)
end

M.on_ASCII_cursor_move = function()
  local HEX_buf = refs.get_current_hexbuf()
  if HEX_buf == nil then return end
  highlight_HEX_cursor(HEX_buf)
end

return M
