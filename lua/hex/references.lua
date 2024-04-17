local u = require 'hex.utils'
local File = require'hex.File'
local Window = require'hex.Window'

local M = {}

local to_origin = {}
local files = {}

M.unknown_dump = function()
  return to_origin[vim.fn.expand("%:p")] == nil
end

M.already_dumped = function(file)
  return files[file] ~= nil
end

file = function()
  local origin = to_origin[vim.fn.expand("%:p")]
  return files[origin]
end
M.file = file

M.windows = {hex=Window:new(),ascii=Window:new(),address=Window:new()}

M.init = function(file)
  local filename=vim.fn.fnamemodify(file, ":t")

  files[file] = {}
  F = files[file]

  F.hex = File:new(file, M.windows.hex, to_origin)
  F.ascii = File:new(file, M.windows.ascii, to_origin)
  F.address = File:new(file, M.windows.address, to_origin)
  F.binary = false
  F.origin = file

  to_origin[file] = file
end

M.on_HEX_close = function()
  if M.windows.ascii:is_visible() or M.windows.address:is_visible() then
    vim.api.nvim_command(":vsplit")
  end
  M.windows.ascii:close_if_visible()
  M.windows.address:close_if_visible()
  file().hex:set_current()
  M.windows.address.show = false
  M.windows.ascii.show = false
end

return M
