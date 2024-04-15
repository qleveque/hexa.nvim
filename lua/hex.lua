local u = require("hex.utils")
local refs = require("hex.references")
local actions = require("hex.actions")
local setup = require("hex.setup")
local cur = require("hex.cursor")

local toggled = false
local changed_shell_count = 0

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

local set_scroll = function()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(refs.HEXwin())
  u.bind_scroll_and_cursor()
  vim.cmd("sync")
  if refs.LINE_is_visible() then
    vim.api.nvim_set_current_win(refs.LINEwin())
    u.bind_scroll_and_cursor()
  end
  if refs.ASCII_is_visible() then
    vim.api.nvim_set_current_win(refs.ASCIIwin())
    u.bind_scroll_and_cursor()
  end
  vim.api.nvim_set_current_win(win)
end

local unset_scroll = function()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(refs.HEXwin())
  u.unbind_scroll_and_cursor()
  if refs.ASCII_is_visible() then
    vim.api.nvim_set_current_win(refs.ASCIIwin())
    u.unbind_scroll_and_cursor()
  end
  if refs.LINE_is_visible() then
    vim.api.nvim_set_current_win(refs.LINEwin())
    u.unbind_scroll_and_cursor()
  end
  vim.api.nvim_set_current_win(win)
end

local shell_changed = function()
  changed_shell_count = 0
  if refs.ASCII_is_visible() then
    changed_shell_count = changed_shell_count + 1
  end
  if refs.LINE_is_visible() then
    changed_shell_count = changed_shell_count + 1
  end
end

M.on_HEX_saved = function()
  unset_scroll()
  shell_changed()
  local file=refs.get_current_file()
  actions.update(file)
  actions.dump_LINE(file)
  actions.dump_ASCII(file)
end

M.on_HEX_hidden = function()
  unset_scroll()
  refs.close_ASCII_if_visible()
  refs.close_LINE_if_visible()
end

M.open_wins = function(reset)
  if reset ~= nil and reset == true then
    refs.reset_show_state()
  end

  local file = refs.get_current_file()
  if file == nil then return end
  refs.set_current_HEX(file)

  local new = false
  if not refs.ASCII_is_visible() and refs.ASCII_should_spawn() then
    new = true
    local ASCII_file = refs.get_ASCII_file(file)
    vim.api.nvim_command(":rightbelow vsplit "..ASCII_file.." | vertical resize 17")
    vim.cmd('setl nonu ft=hexd noma winfixwidth')
    if refs.ASCII_is_new_buf(file) then
      setup.setup_ASCII(M.cfg)
    end
    refs.set_current_ASCII()
    vim.cmd('wincmd h')
  end

  if not refs.LINE_is_visible() and refs.LINE_should_spawn() then
    new = true
    local LINE_file = refs.get_LINE_file(file)
    vim.api.nvim_command(":vsplit "..LINE_file.." | vertical resize 10")
    vim.cmd('setl nonu ft=hexd noma winfixwidth')
    if refs.LINE_is_new_buf(file) then
      setup.setup_LINE(M.cfg)
    end
    refs.set_current_LINE()
    vim.cmd('wincmd l')
  end
  
  if new then
    set_scroll()
  end


  local file = refs.get_current_file()
  cur.on_HEX_enter(file)
  local HEX_buf = refs.get_current_hexbuf()
  if HEX_buf == nil then return end
  vim.api.nvim_buf_clear_highlight(HEX_buf, -1, 0, -1)
end

M.on_ASCII_enter = function()
  local ASCII_buf = refs.get_current_ASCIIbuf()
  if ASCII_buf == nil then return end
  vim.api.nvim_buf_clear_highlight(ASCII_buf, -1, 0, -1)
  local file = refs.get_current_file()
  cur.on_ASCII_enter(file)
  vim.cmd('sync')
end

M.on_ASCII_leave = function()
  local file = refs.get_current_file()
  cur.on_ASCII_leave(file)
end

M.on_HEX_leave = function()
  local file = refs.get_current_file()
  cur.on_HEX_leave(file)
end

M.run = function()
  local file = refs.get_current_file()
  vim.api.nvim_command(M.cfg.run_cmd(file))
end

M.on_changed_shell = function()
  if changed_shell_count == 0 then
    return
  end
  changed_shell_count = changed_shell_count - 1
  if changed_shell_count > 0 then
    return
  end

  if toggled then
    toggled = false
  else
    set_scroll()
  end
end

replace_with_xxd = function(file)
  local original_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_command(':edit '..refs.get_HEX_file(file))
  refs.set_current_HEX(file)
  vim.api.nvim_buf_delete(original_buf, { force = true })
end

M.toggle_bin = function()
  vim.api.nvim_command(":0")
  shell_changed()
  toggled = true
  refs.toggle_bin()
  local file = refs.get_current_file()
  actions.dump_HEX(file)
  actions.dump_ASCII(file)
  actions.dump_LINE(file)
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
      actions.dump_LINE(file)
      replace_with_xxd(file)
      setup.setup_HEX(M.cfg)
    end
  end
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
    com! -nargs=0 -bang HexShow lua require'hex'.open_wins(true)
    com! -nargs=0 -bang HexToggleBin lua require'hex'.toggle_bin()

    hi HexFocus guibg=yellow guifg=black
  ]]
end

return M
