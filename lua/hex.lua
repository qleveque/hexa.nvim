local u = require("hex.utils")
local refs = require("hex.references")
local cmd = require("hex.cmd")
local au = require("hex.autocommands")
local cur = require("hex.cursor")

local M = {}

M.cfg = {}

M.on_HEX_saved = function()
  u.unbind_scroll_and_cursor()
  local file=refs.get_current_file()
  cmd.update(file)
  cmd.dump_ASCII(file)
end

M.open_ASCII = function()
  local file = refs.get_current_file()
  if file == nil or refs.ASCII_is_visible(file) then
    return
  end
  local ASCII_file = refs.get_ASCII_file(file)

  vim.api.nvim_command(":rightbelow vsplit +10 "..ASCII_file.." | vertical resize 20")
  u.bind_scroll_and_cursor()

  if refs.ASCII_is_new_buf(file) then
    au.setup_ASCII()
  end
  refs.set_current_ASCII(file)
  vim.cmd('wincmd h')
  u.bind_scroll_and_cursor()
end

M.on_ASCII_enter = function()
  local ASCII_buf = refs.get_current_ASCIIbuf()
  if ASCII_buf == nil then return end
  vim.api.nvim_buf_clear_highlight(ASCII_buf, -1, 0, -1)
  local file = refs.get_current_file()
  cur.on_ASCII_enter(file)
end

M.on_HEX_enter = function()
  local HEX_buf = refs.get_current_hexbuf()
  if HEX_buf == nil then return end
  vim.api.nvim_buf_clear_highlight(HEX_buf, -1, 0, -1)
  local file = refs.get_current_file()
  cur.on_HEX_enter(file)
end

M.on_ASCII_leave = function()
  local file = refs.get_current_file()
  cur.on_ASCII_leave(file)
end

M.on_HEX_leave = function()
  local file = refs.get_current_file()
  cur.on_HEX_leave(file)
end

M.reformat_HEX = function()
  local file = refs.get_current_file()
  cmd.dump_HEX(file)
end

setup_HEX = function(file)
  local original_buf = vim.api.nvim_get_current_buf()
  cmd.dump_HEX(file)
  cmd.dump_ASCII(file)
  refs.set_current_hex(file)
  vim.api.nvim_buf_delete(original_buf, { force = true })
end

M.on_open = function()
  local file=vim.fn.expand("%:p")
  if u.is_binary(file) then
    if refs.HEX_file_loaded(file) then
      setup_HEX(file)
      M.open_ASCII()
    else
      refs.init(file)
      setup_HEX(file)
      M.open_ASCII()
      au.setup_HEX(file)
    end
  end
end


vim.cmd[[
  augroup OnHexOpen
    autocmd!
    autocmd BufReadPost * lua require'hex'.on_open()
  augroup END
]]

M.setup = function(args)
  -- vim.api.nvim_create_user_command('HexDump', M.dump, {})
  -- vim.api.nvim_create_user_command('HexAssemble', M.assemble, {})
  -- vim.api.nvim_create_user_command('HexToggle', M.toggle, {})
end

return M
