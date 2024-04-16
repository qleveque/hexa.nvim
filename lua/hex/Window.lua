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

function Window:set_current()
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
    self:set_current()
    u.bind_scroll_and_cursor()
    vim.api.nvim_set_current_win(win)
  end
end

function Window:unset_scroll()
  if self:is_visible() then
    local win = vim.api.nvim_get_current_win()
    self:set_current()
    u.unbind_scroll_and_cursor()
    vim.api.nvim_set_current_win(win)
  end
end

return Window
