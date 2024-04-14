local u = require 'hex.utils'

local M = {}

local to_origin = {}
local file_to_HEX = {}
local file_to_HEXbuf = {}
local file_to_HEXwin = {}
local file_to_ASCII = {}
local file_to_ASCIIbuf = {}
local file_to_ASCIIwin = {}

M.get_current_file = function()
  return to_origin[vim.fn.expand("%:p")]
end

M.get_current_hexbuf = function()
  local file=M.get_current_file()
  return file_to_HEXbuf[file]
end

M.get_current_ASCIIbuf = function()
  local file=M.get_current_file()
  return file_to_ASCIIbuf[file]
end

M.on_HEX_unloaded = function()
  local file=M.get_current_file()
  if file_to_ASCIIwin[file] ~= nil then
    vim.api.nvim_win_close(file_to_ASCIIwin[file], true)
  end
  file_to_ASCIIwin[file] = nil
end

M.on_ASCII_unloaded = function()
  local file = M.get_current_file()
  if file_to_HEXwin[file] ~= nil then
    vim.api.nvim_win_close(file_to_HEXwin[file], true)
  end
  file_to_HEXwin[file] = nil
end

M.on_ASCII_close = function()
  file_to_ASCIIwin[M.get_current_file()] = nil
end

M.on_HEX_close = function()
  file_to_HEXwin[M.get_current_file()] = nil
end

M.on_HEX_deleted = function()
  local file = M.get_current_file()
  local HEX_file=file_to_HEX[file]
  local ASCII_file=file_to_ASCII[file]
  file_to_HEX[file]=nil
  file_to_HEXbuf[file]=nil
  file_to_ASCII[file]=nil
  file_to_ASCIIwin[file]=nil
  file_to_ASCIIbuf[file]=nil
end

M.init = function(file)
  local filename=vim.fn.fnamemodify(file, ":t")
  local HEX_file = vim.fn.tempname().."_"..filename
  file_to_HEX[file]=HEX_file
  local ASCII_file = vim.fn.tempname().."_"..filename
  file_to_ASCII[file]=ASCII_file
  to_origin[HEX_file]=file
  to_origin[ASCII_file]=file
end

M.set_current_ASCII = function(file)
  file_to_ASCIIbuf[file]=vim.api.nvim_get_current_buf()
  file_to_ASCIIwin[file]=vim.api.nvim_get_current_win()
end

M.ASCII_is_new_buf = function(file)
  return file_to_ASCIIbuf[file] == nil
end

M.ASCII_is_visible = function(file)
  return file_to_ASCIIwin[file] ~= nil
end

M.HEX_file_loaded = function(file)
  return file_to_HEX[file] ~= nil
end

M.set_current_hex = function(file)
  vim.api.nvim_command(':edit '..file_to_HEX[file])
  file_to_HEXbuf[file]=vim.api.nvim_get_current_buf()
  file_to_HEXwin[file]=vim.api.nvim_get_current_win()
end

M.get_HEX_file = function(file)
  return file_to_HEX[file]
end

M.get_ASCII_file = function(file)
  return file_to_ASCII[file]
end

return M
