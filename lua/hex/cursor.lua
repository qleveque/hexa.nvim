local refs = require'hex.references'
local hi = require'hex.highlights'
local u = require'hex.utils'

file_to_cursor = {}

M = {}

local move_to_col = function(col)
  if col > 0 then
    vim.cmd('normal! 0'..col..'l')
  else
    vim.cmd('normal! 0')
  end
  vim.cmd('syncbind')
end

M.on_HEX_enter = function(file)
  local cursor = file_to_cursor[file]
  if cursor ~= nil then
    local yc = cursor[2]
    move_to_col(yc)
  end
end

M.on_ASCII_enter = function(file)
  local cursor = file_to_cursor[file]
  local _, _, yc = u.HEX_to_ASCII_cursor(cursor)
  move_to_col(yc)
end

M.on_HEX_leave = function(file)
  local cursor = vim.api.nvim_win_get_cursor(0)
  file_to_cursor[file] = {cursor[1], cursor[2]}
end

M.on_ASCII_leave = function(file)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local x, y, yc = u.ASCII_to_HEX_cursor(cursor)
  file_to_cursor[file] = {x, yc}
end

M.on_HEX_cursor_move = function()
  local ASCII_buf = refs.get_current_ASCIIbuf()
  if ASCII_buf == nil then return end
  hi.ASCII_cursor(ASCII_buf)
end

M.on_ASCII_cursor_move = function()
  local HEX_buf = refs.get_current_hexbuf()
  if HEX_buf == nil then return end
  hi.hex_cursor(HEX_buf)
end

return M
