local M = {}

M.is_binary = function(file)
  if string.sub(file, 1, 5) == '/tmp/' then
    return false
  end
  binary_ext = { 'out', 'bin', 'png', 'jpg', 'jpeg', 'exe', 'dll' }
  if vim.bo.ft ~= "" then return false end
  if vim.bo.bin then return true end
  local filename = vim.fn.fnamemodify(file, ":t")
  local ext = vim.fn.fnamemodify(file, ":e")
  if vim.tbl_contains(binary_ext, ext) then return true end
  return false
end

M.bind_scroll_and_cursor = function()
  vim.api.nvim_command(":set scrollbind cursorbind")
  vim.api.nvim_command(":syncbind")
end

M.unbind_scroll_and_cursor = function()
  vim.api.nvim_command(":set noscrollbind nocursorbind")
end

local do_in_ASCII = function(f)
  vim.cmd('wincmd h')
  f()
  vim.cmd(':w!')
  M.bind_scroll_and_cursor()
  vim.cmd('wincmd l')
  M.bind_scroll_and_cursor()
end

M.replace_in_ASCII = function()
  local f= function()
    local char = vim.fn.nr2char(vim.fn.getchar())
    local hex = string.format("%X", string.byte(char))
    vim.cmd('normal! vlc'..hex)
  end
  do_in_ASCII(f)
end

M.undo_from_ASCII = function()
  local f= function()
    vim.cmd(':undo')
  end
  do_in_ASCII(f)
end

M.redo_from_ASCII = function()
  local f= function()
    vim.cmd(':redo')
  end
  do_in_ASCII(f)
end

M.int_div = function(dividend, divisor)
  return (dividend - (dividend % divisor)) / divisor
end

M.HEX_to_ASCII_cursor = function(cursor)
  local y = 2 * M.int_div(cursor[2], 5)
  local yc = y
  if cursor[2]%5 > 1 then
    yc = yc + 1
  end
  return cursor[1]-1, y, yc
end

M.ASCII_to_HEX_cursor = function(cursor)
  local y = M.int_div(cursor[2], 2) * 5
  local yc = y
  if cursor[2]%2 == 1 then
    yc = yc + 2
  end
  return cursor[1]-1, y, yc
end

M.HEX_search = function(char, s)
  local chars = {}
  for char in s:gmatch(".") do
    table.insert(chars, char)
  end
  local pattern_with_space = table.concat(chars, '[\\s\\n]*') 
  pcall(vim.api.nvim_command, ':'..char..'\\v' .. pattern_with_space)
end

return M
