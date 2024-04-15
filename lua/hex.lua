local u = require("hex.utils")
local refs = require("hex.references")
local actions = require("hex.actions")
local setup = require("hex.setup")
local cur = require("hex.cursor")

local M = {}

M.cfg = {
  keymaps = {
    reformat_hex = '<leader>f',
    replace_ascii = 'r',
    undo_ascii = 'u',
    redo_ascii = '<C-R>',
    run = '<CR>',
  },
  run_cmd = function(file) return 'bot sp | term "'..file..'"' end
}

M.on_HEX_saved = function()
  u.unbind_scroll_and_cursor()
  local file=refs.get_current_file()
  actions.update(file)
  actions.dump_ASCII(file)
end

M.open_ASCII = function()
  refs.close_ASCII_if_visible()
  local file = refs.get_current_file()
  if file == nil then
    return
  end
  local ASCII_file = refs.get_ASCII_file(file)

  u.bind_scroll_and_cursor()
  vim.api.nvim_command(":rightbelow vsplit "..ASCII_file)
  u.bind_scroll_and_cursor()

  if refs.ASCII_is_new_buf(file) then
    setup.setup_ASCII(M.cfg)
  end
  refs.set_current_ASCII()
  refs.resize_ASCII()
  vim.cmd('wincmd h')
end

M.on_ASCII_enter = function()
  refs.resize_ASCII()
  local ASCII_buf = refs.get_current_ASCIIbuf()
  if ASCII_buf == nil then return end
  vim.api.nvim_buf_clear_highlight(ASCII_buf, -1, 0, -1)
  local file = refs.get_current_file()
  cur.on_ASCII_enter(file)
end

M.on_HEX_enter = function()
  refs.resize_ASCII()
  local HEX_buf = refs.get_current_hexbuf()
  if HEX_buf == nil then return end
  vim.api.nvim_buf_clear_highlight(HEX_buf, -1, 0, -1)
  local file = refs.get_current_file()
  cur.on_HEX_enter(file)
end

M.on_HEX_hidden = function()
  refs.close_ASCII_if_visible()
end

M.on_ASCII_leave = function()
  local file = refs.get_current_file()
  cur.on_ASCII_leave(file)
end

M.on_HEX_leave = function()
  local file = refs.get_current_file()
  cur.on_HEX_leave(file)
end

replace_with_xxd = function(file)
  local original_buf = vim.api.nvim_get_current_buf()
  refs.set_current_hex(file)
  vim.api.nvim_buf_delete(original_buf, { force = true })
end

M.on_open = function()
  local file=vim.fn.expand("%:p")
  if u.is_binary_file(file) then
    if refs.already_dumped(file) then
      replace_with_xxd(file)
    else
      refs.init(file)
      actions.dump_HEX(file)
      actions.dump_ASCII(file)
      replace_with_xxd(file)
      setup.setup_HEX(M.cfg)
    end
    M.open_ASCII()
  end
end

M.run = function()
  local file = refs.get_current_file()
  vim.api.nvim_command(M.cfg.run_cmd(file))
end

M.setup = function(cfg)
  if type(cfg) == "table" then
    M.cfg = vim.tbl_deep_extend("force", M.cfg, cfg)
  end
  vim.cmd[[
    augroup OnHexOpen
      autocmd!
      autocmd BufReadPost * lua require'hex'.on_open()
    augroup END

    com! -nargs=1 -bang HexSearch lua require'hex.actions'.HEX_search('/', <f-args>)
    com! -nargs=1 -bang HexSearchBack lua require'hex.actions'.HEX_search('?', <f-args>)
    com! -nargs=0 -bang HexReformat lua require'hex.actions'.reformat_HEX()
    com! -nargs=0 -bang HexOpenAscii lua require'hex'.open_ASCII()
    com! -nargs=0 -bang HexToggleBin lua require'hex.actions'.toggle_bin()
  ]]
end

return M
