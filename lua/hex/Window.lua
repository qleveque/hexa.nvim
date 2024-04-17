local u = require'hex.utils'

local Window = {}

function Window:new()
  local newObj = {
    win = nil,
    show = true
  }
  setmetatable(newObj, self)
  self.__index = self
  return newObj
end

function Window:focus()
  vim.api.nvim_set_current_win(self.win)
end

function Window:is_visible()
  return self.win ~= nil and vim.api.nvim_win_is_valid(self.win)
end

function Window:close_if_visible()
  if self:is_visible() then
    vim.api.nvim_win_close(self.win, true)
  end
  self.win = nil
end

function Window:set_scroll()
  if self:is_visible() then
    local win = vim.api.nvim_get_current_win()
    self:focus()
    vim.api.nvim_command(":setl cursorbind scrollbind")
    vim.api.nvim_set_current_win(win)
  end
end

function Window:sync_scroll(line)
  if self:is_visible() then
    local win = vim.api.nvim_get_current_win()
    self:focus()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, {line, cursor[2]})
    vim.cmd('normal! zz')
    vim.api.nvim_set_current_win(win)
  end
end

function Window:unset_scroll()
  if self:is_visible() then
    local win = vim.api.nvim_get_current_win()
    self:focus()
    vim.api.nvim_command(":setl nocursorbind noscrollbind")
    vim.api.nvim_set_current_win(win)
  end
end

return Window
