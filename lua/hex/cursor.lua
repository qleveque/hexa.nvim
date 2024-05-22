local refs = require'hex.references'
local u = require'hex.utils'

local cursor_setup = false

M = {}

local to_ASCII_column = function(col)
  local l
  if refs.file().binary then l = 9 else l = 3 end
  return u.int_div(col, l)
end

local from_ASCII_column = function(col)
  local l
  if refs.file().binary then l = 9 else l = 3 end
  return col * l
end

local highlight = function(file, length)
  local x = vim.api.nvim_win_get_cursor(0)[1] - 1
  local y = file.col
  local z
  if length == -1 then
    z = -1
  else
    z = file.col + length
  end
  if file.buf ~= nil then
    vim.api.nvim_buf_add_highlight(file.buf, 3, 'HexFocus', x, y, z)
  end
end

local highlight_ASCII_cursor = function(ASCII_buf)
  if refs.file() ~= nil then
    highlight(refs.file().ascii, 1)
  end
end

local highlight_HEX_cursor = function(ASCII_buf)
  if refs.file() ~= nil then
    local length
    if refs.file().binary then length = 8 else length = 2 end
    highlight(refs.file().hex, length)
  end
end

local highlight_ADDRESS_cursor = function(ASCII_buf)
  if refs.file() ~= nil then
    highlight(refs.file().address, -1)
  end
end

M.highlight = function()
  highlight_ASCII_cursor()
  highlight_ADDRESS_cursor()
  highlight_HEX_cursor()
end

M.on_leave = function()
  M.highlight()
  cursor_setup = false
end

local update_cols = function(col)
  local f = refs.file()
  if f.ascii ~= nil then
    f.ascii.col = to_ASCII_column(col)
  end
  if f.hex ~= nil then
    f.hex.col = col
  end
  if f.address ~= nil then
    f.address.col = 0
  end
end

local clear_highlights = function()
  local f = refs.file()
  for _, file in ipairs({f.hex, f.ascii, f.address}) do
    if file.buf ~= nil then
      vim.api.nvim_buf_clear_highlight(file.buf, 3, 0, -1)
    end
  end
end

M.on_HEX_cursor_move = function()
  if not cursor_setup then
    u.move_to_col(refs.file().hex.col)
    cursor_setup = true
  end
  local c = vim.api.nvim_win_get_cursor(0)[2]
  update_cols(c)
  clear_highlights()
  highlight_ASCII_cursor()
  highlight_ADDRESS_cursor()
end

M.on_ASCII_cursor_move = function()
  if not cursor_setup then
    u.move_to_col(refs.file().ascii.col)
    cursor_setup = true
  end
  local c = vim.api.nvim_win_get_cursor(0)[2]
  update_cols(from_ASCII_column(c))
  clear_highlights()
  highlight_HEX_cursor()
  highlight_ADDRESS_cursor()
end

M.on_ADDRESS_cursor_move = function()
  if not cursor_setup then
    u.move_to_col(refs.file().address.col)
    cursor_setup = true
  end
  clear_highlights()
  highlight_HEX_cursor()
  highlight_ASCII_cursor()
end

return M
