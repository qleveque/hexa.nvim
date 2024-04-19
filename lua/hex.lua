local M = {}

M.cfg = {
  keymaps = {
    hex = {
      reformat = '<leader>f',
    },
    ascii = {
      replace = 'r',
      undo = 'u',
      redo = '<C-R>',
    },
    run = '<CR>',
  },
  run_cmd = function(file) return 'bot sp | term "'..file..'"' end,
  ascii_left = false,
}

local load = function()
  refs = require("hex.references")
  actions = require("hex.actions")
  setup = require("hex.setup")
  cur = require("hex.cursor")

  changed_shell_count = 0

  set_scroll = function(center)
    local f = refs.file()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if center then vim.cmd("sync") end
    f.hex.win:sync_scroll(line, center)
    f.address.win:sync_scroll(line, center)
    f.ascii.win:sync_scroll(line, center)
    f.hex.win:set_scroll()
    f.address.win:set_scroll()
    f.ascii.win:set_scroll()
    if not center then vim.cmd("sync") end
  end

  unset_scroll = function()
    local f = refs.file()
    f.hex.win:unset_scroll()
    f.address.win:unset_scroll()
    f.ascii.win:unset_scroll()
    changed_shell_count = 0
    if f.ascii.win:is_visible() then
      changed_shell_count = changed_shell_count + 1
    end
    if f.address.win:is_visible() then
      changed_shell_count = changed_shell_count + 1
    end
  end

  M.on_HEX_saved = function()
    unset_scroll()
    actions.update()
    actions.dump_ADDRESS()
    actions.dump_ASCII()
  end

  M.on_HEX_hidden = function()
    local f = refs.file()
    unset_scroll()
    f.ascii.win:close_if_visible()
    f.address.win:close_if_visible()
  end

  M.open_wins = function(reset)
    if refs.unknown_dump() then return end

    local f = refs.file()
    if f.hex.win.winnr ~= vim.api.nvim_get_current_win() then
      f.hex:set_current()
    end

    if reset ~= nil and reset == true then
      f.address.win.show = true
      f.ascii.win.show = true
    end

    local any = false

    if f.address.win.show and f.address.win.winnr == nil then
      any = true
      vim.api.nvim_command(":vsplit "..f.address.file.." | vertical resize 10")
      vim.cmd('setl nonu ft=hexd noma winfixwidth stl=\\ ')
      if f.address:is_new_buf() then
        setup.setup_ADDRESS(M.cfg)
      end
      f.address:set_current()
      f.hex.win:focus()
    end

    if f.ascii.win.show and f.ascii.win.winnr == nil then
      any = true
      local right = 'rightbelow '
      if M.cfg.ascii_left then right = '' end
      vim.api.nvim_command(":"..right.."vsplit "..f.ascii.file.." | vertical resize 17")
      vim.cmd('setl nonu ft=hexd noma winfixwidth stl=\\ ')
      if f.ascii:is_new_buf() then
        setup.setup_ASCII(M.cfg)
      end
      f.ascii:set_current()
      f.hex.win:focus()
    end

    if any then
      set_scroll(true)
    end
  end

  M.run = function()
    vim.api.nvim_command(M.cfg.run_cmd(refs.file().origin))
  end

  M.on_changed_shell = function()
    if changed_shell_count == 0 then
      return
    end
    changed_shell_count = changed_shell_count - 1
    if changed_shell_count == 0 then
      set_scroll(false)
    end
  end

  M.toggle_bin = function()
    unset_scroll()
    refs.file().binary = not refs.file().binary
    actions.dump_HEX()
    actions.dump_ASCII()
    actions.dump_ADDRESS()
  end

  replace_with_xxd = function()
    local original_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command(':edit '..refs.file().hex.file)
    vim.api.nvim_buf_delete(original_buf, { force = true })
  end

  vim.cmd[[
    com! -nargs=1 -bang HexSearch lua require'hex.actions'.search('/', <f-args>)
    com! -nargs=1 -bang HexSearchBack lua require'hex.actions'.search('?', <f-args>)
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
      actions.dump_ADDRESS()
      replace_with_xxd()
    end
    setup.setup_HEX(M.cfg)
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
