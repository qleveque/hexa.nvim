local M = {}

local hex_search = function(s, char)
  local chars = {}
  for char in s:gmatch(".") do
      table.insert(chars, char)
  end
  local pattern_with_space = table.concat(chars, '[\\s\\n]*') 
  vim.api.nvim_command(':'..char..'\\v' .. pattern_with_space)
end

M.hex_search_forward = function(s)
  hex_search(s, '/')
end

M.hex_search_backward = function(s)
  hex_search(s, '?')
end

M.setup = function()
  vim.cmd("au BufEnter <buffer> nn / :HexSearch ")
  vim.cmd("au BufEnter <buffer> nn ? :HexSearchBack ")
  vim.cmd("com! -nargs=1 -bang HexSearch lua require'hex.search'.hex_search_forward(<f-args>)")
  vim.cmd("com! -nargs=1 -bang HexSearchBack lua require'hex.search'.hex_search_backward(<f-args>)")
end

return M
