local u = require 'hex.utils'

local M = {}

local to_origin = {}
local file_to_HEX = {}
local file_to_HEXbuf = {}
local file_to_ASCII = {}
local file_to_ASCIIbuf = {}
local file_to_LINE = {}
local file_to_LINEbuf = {}

local file_to_ASCIIshow = {}
local file_to_LINEshow = {}

local ASCIIwin = nil
local LINEwin = nil
local HEXwin = nil

local file_to_binary = {}

M.ASCIIwin = function(f)
  return ASCIIwin
end

M.HEXwin = function(f)
  return HEXwin
end

M.LINEwin = function()
  return LINEwin
end

M.ASCII_should_spawn = function()
  local file=M.get_current_file()
  return file_to_ASCIIshow[file]
end

M.on_ASCII_closed = function()
  local file=M.get_current_file()
  file_to_ASCIIshow[file] = false
  ASCIIwin = nil
end

M.LINE_should_spawn = function()
  local file=M.get_current_file()
  return file_to_LINEshow[file]
end

M.on_LINE_closed = function()
  local file=M.get_current_file()
  file_to_LINEshow[file] = false
  LINEwin = nil
end

M.reset_show_state = function()
  local file=M.get_current_file()
  file_to_LINEshow[file] = true
  file_to_ASCIIshow[file] = true
end

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
  local LINE_file = vim.fn.tempname().."_"..filename
  file_to_LINE[file]=LINE_file
  to_origin[LINE_file]=file

  file_to_ASCIIshow[file] = true
  file_to_LINEshow[file] = true
end

M.set_current_ASCII = function()
  local file=M.get_current_file()
  file_to_ASCIIbuf[file]=vim.api.nvim_get_current_buf()
  ASCIIwin=vim.api.nvim_get_current_win()
end

M.set_current_LINE = function()
  local file=M.get_current_file()
  file_to_LINEbuf[file]=vim.api.nvim_get_current_buf()
  LINEwin=vim.api.nvim_get_current_win()
end

M.ASCII_is_new_buf = function(file)
  return file_to_ASCIIbuf[file] == nil
end

M.LINE_is_new_buf = function(file)
  return file_to_LINEbuf[file] == nil
end

M.ASCII_is_visible = function()
  return ASCIIwin ~= nil and vim.api.nvim_win_is_valid(ASCIIwin)
end

M.LINE_is_visible = function()
  return LINEwin ~= nil and vim.api.nvim_win_is_valid(LINEwin)
end

M.close_ASCII_if_visible = function()
  local file=M.get_current_file()
  if M.ASCII_is_visible() then
    vim.api.nvim_win_close(ASCIIwin, true)
  end
  ASCIIwin = nil
end

M.close_LINE_if_visible = function()
  local file=M.get_current_file()
  if M.LINE_is_visible() then
    vim.api.nvim_win_close(LINEwin, true)
  end
  LINEwin = nil
end

M.already_dumped = function(file)
  return file_to_HEX[file] ~= nil
end

M.set_current_HEX = function(file)
  HEXwin=vim.api.nvim_get_current_win()
  file_to_HEXbuf[file]=vim.api.nvim_get_current_buf()
end

M.get_HEX_file = function(file)
  return file_to_HEX[file]
end

M.get_ASCII_file = function(file)
  return file_to_ASCII[file]
end

M.get_LINE_file = function(file)
  return file_to_LINE[file]
end

M.on_HEX_close = function()
  if M.ASCII_is_visible() or M.LINE_is_visible() then
    vim.api.nvim_command(":vsplit")
  end
  M.close_ASCII_if_visible()
  M.close_LINE_if_visible()
  local file=M.get_current_file()
  M.set_current_HEX(file)
  file_to_LINEshow[file] = false
  file_to_ASCIIshow[file] = false
end

return M
