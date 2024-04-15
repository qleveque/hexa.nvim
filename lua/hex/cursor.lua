local refs = require'hex.references'
local u = require'hex.utils'

file_to_cursor = {}

M = {}

local HEX_to_ASCII_cursor = function(cursor)
  if refs.is_binary() then
    local y = u.int_div(cursor[2], 9)
    return cursor[1]-1, y, y
  else
    local y = 2 * u.int_div(cursor[2], 5)
    local yc = y
    if cursor[2]%5 > 1 then
      yc = yc + 1
    end
    return cursor[1]-1, y, yc
  end
end

local ASCII_to_HEX_cursor = function(cursor)
  if refs.is_binary() then
    local y = cursor[2] * 9
    return cursor[1]-1, y, y
  else
    local y = u.int_div(cursor[2], 2) * 5
    local yc = y
    if cursor[2]%2 == 1 then
      yc = yc + 2
    end
    return cursor[1]-1, y, yc
  end
end

local highlight_ASCII_cursor = function(ASCII_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local x, y, yc = HEX_to_ASCII_cursor(cursor)
  vim.api.nvim_buf_clear_highlight(ASCII_buf, 2, 0, -1)
  vim.api.nvim_buf_clear_highlight(ASCII_buf, 3, 0, -1)
  if refs.is_binary() then
    vim.api.nvim_buf_add_highlight(ASCII_buf, 3, 'HexFocus', x, y, y+1)
  else
    vim.api.nvim_buf_add_highlight(ASCII_buf, 2, 'HexContext', x, y, y+2)
    vim.api.nvim_buf_add_highlight(ASCII_buf, 3, 'HexFocus', x, yc, yc+1)
  end
end

local highlight_HEX_cursor = function(HEX_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local x, y, yc = ASCII_to_HEX_cursor(cursor)
  vim.api.nvim_buf_clear_highlight(HEX_buf, 2, 0, -1)
  vim.api.nvim_buf_clear_highlight(HEX_buf, 3, 0, -1)
  if refs.is_binary() then
    vim.api.nvim_buf_add_highlight(HEX_buf, 3, 'HexFocus', x, y, y + 8)
  else
    vim.api.nvim_buf_add_highlight(HEX_buf, 2, 'HexContext', x, y, y+4)
    vim.api.nvim_buf_add_highlight(HEX_buf, 3, 'HexFocus', x, yc, yc+2)
  end
end

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
  local _, _, yc = HEX_to_ASCII_cursor(cursor)
  move_to_col(yc)
end

M.on_HEX_leave = function(file)
  local cursor = vim.api.nvim_win_get_cursor(0)
  file_to_cursor[file] = {cursor[1], cursor[2]}
end

M.on_ASCII_leave = function(file)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local x, _, yc = ASCII_to_HEX_cursor(cursor)
  file_to_cursor[file] = {x, yc}
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

vim.cmd("hi HexFocus guibg=yellow guifg=black")
vim.cmd("hi HexContext guibg=#444e88 guifg=white")

return M
