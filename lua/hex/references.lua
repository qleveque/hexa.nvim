local u = require 'hex.utils'
local File = require'hex.File'

local M = {}

local to_origin = {}
local files = {}

M.unknown_dump = function()
  return to_origin[vim.fn.expand("%:p")] == nil
end

M.already_dumped = function(file)
  return files[file] ~= nil
end

M.file = function()
  local origin = to_origin[vim.fn.expand("%:p")]
  return files[origin]
end

M.init = function(file)
  if files[file] ~= nil then return end
  local filename=vim.fn.fnamemodify(file, ":t")

  files[file] = {}
  F = files[file]

  F.hex = File:new(file, to_origin)
  F.ascii = File:new(file, to_origin)
  F.address = File:new(file, to_origin)
  F.binary = false
  F.origin = file
  F.open_as_bin = true

  to_origin[file] = file
end

M.on_win_closed = function()
  local f = M.file()
  local winnr = vim.api.nvim_get_current_win()
  if f.address.win.winnr ~= winnr then
    f.address.win:close_if_visible()
  end
  if f.ascii.win.winnr ~= winnr then
    f.ascii.win:close_if_visible()
  end
  if f.hex.win.winnr ~= winnr then
    f.hex.win:close_if_visible()
  end
  if #vim.api.nvim_list_wins() == 1 then
    vim.api.nvim_command('q!')
  end
end

return M
