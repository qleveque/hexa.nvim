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

local load = function()
  refs = require("hex.references")
  actions = require("hex.actions")
  setup = require("hex.setup")
  cur = require("hex.cursor")

  toggled = false
  changed_shell_count = 0

  set_scroll = function()
    refs.windows.hex:set_scroll()
    vim.cmd("sync")
    refs.windows.line:set_scroll()
    refs.windows.ascii:set_scroll()
  end

  unset_scroll = function()
    refs.windows.hex:unset_scroll()
    refs.windows.line:unset_scroll()
    refs.windows.ascii:unset_scroll()
  end

  shell_changed = function()
    changed_shell_count = 0
    if refs.windows.ascii:is_visible() then
      changed_shell_count = changed_shell_count + 1
    end
    if refs.windows.line:is_visible() then
      changed_shell_count = changed_shell_count + 1
    end
  end

  M.on_HEX_saved = function()
    unset_scroll()
    shell_changed()
    actions.update()
    actions.dump_LINE()
    actions.dump_ASCII()
  end

  M.on_HEX_hidden = function()
    unset_scroll()
    refs.windows.ascii:close_if_visible()
    refs.windows.line:close_if_visible()
  end

  M.open_wins = function(reset)
    if refs.unknown_dump() then return end

    if reset ~= nil and reset == true then
      refs.windows.line.show = true
      refs.windows.ascii.show = true
    end

    refs.file().hex:set_current()

    local any = false
    if not refs.windows.ascii:is_visible() and refs.windows.ascii.show then
      any = true
      local ASCII_file = refs.file().ascii.file
      vim.api.nvim_command(":rightbelow vsplit "..ASCII_file.." | vertical resize 17")
      vim.cmd('setl nonu ft=hexd noma winfixwidth')
      if refs.file().ascii:is_new_buf() then
        setup.setup_ASCII(M.cfg)
      end
      refs.file().ascii:set_current()
      vim.cmd('wincmd h')
    end

    if not refs.windows.line:is_visible() and refs.windows.line.show then
      any = true
      local LINE_file = refs.file().line.file
      vim.api.nvim_command(":vsplit "..LINE_file.." | vertical resize 10")
      vim.cmd('setl nonu ft=hexd noma winfixwidth')
      if refs.file().line:is_new_buf() then
        setup.setup_LINE(M.cfg)
      end
      refs.file().line:set_current()
      vim.cmd('wincmd l')
    end

    if any then
      set_scroll()
    end

    cur.on_HEX_enter()
    local HEX_buf = refs.file().hex.buf
    if HEX_buf == nil then return end
    vim.api.nvim_buf_clear_highlight(HEX_buf, -1, 0, -1)
  end

  M.on_ASCII_enter = function()
    local ASCII_buf = refs.file().ascii.buf
    if ASCII_buf == nil then return end
    vim.api.nvim_buf_clear_highlight(ASCII_buf, -1, 0, -1)
    cur.on_ASCII_enter()
  end

  M.run = function()
    vim.api.nvim_command(M.cfg.run_cmd(refs.file().origin))
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

  M.toggle_bin = function()
    vim.api.nvim_command(":0")
    shell_changed()
    toggled = true
    refs.file().binary = not refs.file().binary
    actions.dump_HEX()
    actions.dump_ASCII()
    actions.dump_LINE()
  end

  replace_with_xxd = function()
    local original_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command(':edit '..refs.file().hex.file)
    refs.file().hex:set_current()
    vim.api.nvim_buf_delete(original_buf, { force = true })
  end

  vim.cmd[[
    com! -nargs=1 -bang HexSearch lua require'hex.actions'.HEX_search('/', <f-args>)
    com! -nargs=1 -bang HexSearchBack lua require'hex.actions'.HEX_search('?', <f-args>)
    com! -nargs=0 -bang HexReformat lua require'hex.actions'.dump_HEX()
    com! -nargs=0 -bang HexShow lua require'hex'.open_wins(true)
    com! -nargs=0 -bang HexToggleBin lua require'hex'.toggle_bin()
    com! -nargs=0 -bang HexRun lua require'hex'.run()

    hi HexFocus guibg=yellow guifg=black
  ]]
end

loaded = false

local is_binary_file = function(file)
  if string.sub(file, 1, 5) == '/tmp/' then return false end
  if vim.bo.ft ~= "" then return false end
  if vim.bo.bin then return true end
  local ext = vim.fn.fnamemodify(file, ":e")
  binary_ext = { 'out', 'bin', 'png', 'exe', 'dll' }
  if vim.tbl_contains(binary_ext, ext) then return true end
  return false
end

M.on_open = function()
  local file=vim.fn.expand("%:p")
  if is_binary_file(file) then
    if not loaded then
      load()
      loaded = true
    end
    if refs.already_dumped(file) then
      replace_with_xxd()
    else
      refs.init(file)
      actions.dump_HEX()
      actions.dump_ASCII()
      actions.dump_LINE()
      replace_with_xxd()
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
  ]]
end

return M
