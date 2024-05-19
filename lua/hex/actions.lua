refs = require'hex.references'
u = require'hex.utils'
setup = require'hex.setup'

M = {}

M.dump_HEX = function()
  local HEX_file = refs.file().hex.file
  local file = refs.file().origin
  if refs.file().binary then
    vim.fn.system(
      'xxd -b "'..file..'" | cut -c 11-63 > "'..HEX_file..'"'
    )
  else
    vim.fn.system(
      'xxd -g1 "'..file..'" | cut -c 11-57 > "'..HEX_file..'"'
    )
  end
end

M.dump_ASCII = function()
  local ASCII_file = refs.file().ascii.file
  local file = refs.file().origin
  if refs.file().binary then
    vim.fn.system(
      'xxd -b "'..file..'" | cut -c 66- > "'..ASCII_file..'"'
    )
  else
    vim.fn.system(
      'xxd "'..file..'" | cut -c 52- > "'..ASCII_file..'"'
    )
  end
end

M.dump_ADDRESS = function()
  local ADDRESS_file = refs.file().address.file
  local file = refs.file().origin
  local bin = ""
  if refs.file().binary then bin = "-b " end
  vim.fn.system(
    'xxd '..bin..'"'..file..'" | cut -c -9 > "'..ADDRESS_file..'"'
  )
end

M.update = function()
  local HEX_file = refs.file().hex.file
  local file = refs.file().origin
  if refs.file().binary then
    local current_script = debug.getinfo(1, "S").source:sub(2)
    local current_path = vim.fn.fnamemodify(current_script, ":h")
    local o = HEX_file..".bin"
    vim.fn.system("cat "..HEX_file.." | tr -d '[:space:]' > "..o)
    vim.fn.system("python3 "..current_path.."/scripts/bin_to_exe.py "..o.." "..file)
  else
    vim.fn.system(
      'cat "'..HEX_file..'" | xxd -r -p > "'..file..'"'
    )
  end
end

local do_in_HEX = function(fun)
  local win = vim.api.nvim_get_current_win()
  local f = refs.file()
  f.hex.win:focus()
  fun()
  vim.cmd(':w!')
  f.ascii.win:focus()
end

M.replace_in_ASCII = function()
  local f= function()
    u.move_to_col(refs.file().hex.col)
    local char = vim.fn.nr2char(vim.fn.getchar())
    local byte = string.byte(char)
    if refs.file().binary then
      local binary = ""
      for i = 7, 0, -1 do
          binary = binary .. tostring(bit.band(byte, 2^i) > 0 and 1 or 0)
      end
      vim.cmd('normal! v7lc'..binary)
    else
      local hex = string.format("%X", byte)
      vim.cmd('normal! vlc'..hex)
    end
  end
  do_in_HEX(f)
end

M.undo_from_ASCII = function()
  local f= function()
    vim.cmd(':undo')
  end
  do_in_HEX(f)
end

M.redo_from_ASCII = function()
  local f= function()
    vim.cmd(':redo')
  end
  do_in_HEX(f)
end

M.search = function(char, s)
  local chars = {}
  for c in s:gmatch(".") do table.insert(chars, c) end
  local pattern_with_space = table.concat(chars, '[ \\n]*') 
  pcall(vim.api.nvim_command, ':'..char..'\\v' .. pattern_with_space)
end

M.ASCII_goto = function(s)
  local n = tonumber(s, 16)
  local d
  if refs.file().binary then d = 6 else d = 16 end
  local line = u.int_div(n, d) + 1
  local col = n % d
  vim.cmd(":"..line)
  u.move_to_col(col)
end

M.HEX_goto = function(s)
  local n = tonumber(s, 16)
  local line
  local col
  if refs.file().binary then
    line = u.int_div(n, 6) + 1
    col = n % 6 * 9
  else
    line = u.int_div(n, 16) + 1
    col = n % 16 * 3
  end
  vim.cmd(":"..line)
  u.move_to_col(col)
end

return M
