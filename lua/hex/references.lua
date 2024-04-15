local u = require 'hex.utils'

local M = {}

local to_origin = {}
local file_to_HEX = {}
local file_to_HEXbuf = {}
local file_to_ASCII = {}
local file_to_ASCIIbuf = {}

local ASCIIwin = nil

local file_to_binary = {}

M.is_binary = function()
  local file=M.get_current_file()
  return file_to_binary[file]
end

M.toggle_bin = function()
  local file=M.get_current_file()
  file_to_binary[file] = not file_to_binary[file]
end

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

M.init = function(file)
  local filename=vim.fn.fnamemodify(file, ":t")
  local HEX_file = vim.fn.tempname().."_"..filename
  file_to_HEX[file]=HEX_file
  to_origin[HEX_file]=file
  local ASCII_file = vim.fn.tempname().."_"..filename
  file_to_ASCII[file]=ASCII_file
  to_origin[ASCII_file]=file
  file_to_binary[file] = false
end

M.set_current_ASCII = function()
  local file=M.get_current_file()
  file_to_ASCIIbuf[file]=vim.api.nvim_get_current_buf()
  ASCIIwin=vim.api.nvim_get_current_win()
end

M.ASCII_is_new_buf = function(file)
  return file_to_ASCIIbuf[file] == nil
end

M.ASCII_is_visible = function()
  return ASCIIwin ~= nil and vim.api.nvim_win_is_valid(ASCIIwin)
end

M.close_ASCII_if_visible = function()
  local file=M.get_current_file()

  if M.ASCII_is_visible() then
    vim.api.nvim_win_close(ASCIIwin, true)
  end
  ASCIIwin = nil
end

M.resize_ASCII = function()
  if M.ASCII_is_visible() then
    vim.api.nvim_win_set_width(ASCIIwin, 20)
  end
end

M.already_dumped = function(file)
  return file_to_HEX[file] ~= nil
end

M.set_current_hex = function(file)
  vim.api.nvim_command(':edit '..file_to_HEX[file])
  file_to_HEXbuf[file]=vim.api.nvim_get_current_buf()
end

M.get_HEX_file = function(file)
  return file_to_HEX[file]
end

M.get_ASCII_file = function(file)
  return file_to_ASCII[file]
end

M.on_ASCII_close = function()
  ASCIIwin = nil
end

M.on_HEX_close = function()
  if M.ASCII_is_visible() then
    vim.api.nvim_command(":vsplit")
  end
  M.close_ASCII_if_visible()
end

return M
