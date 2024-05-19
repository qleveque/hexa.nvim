local u = require'hex.utils'

local Window = {}

function Window:new()
  local newObj = {
    winnr = nil
  }
  setmetatable(newObj, self)
  self.__index = self
  return newObj
end

function Window:is_visible()
  return self.winnr ~= nil and u.is_window_open(self.winnr)
end

function Window:focus()
  vim.api.nvim_set_current_win(self.winnr)
end

function Window:close_if_visible()
  if self:is_visible() then
    vim.api.nvim_win_close(self.winnr, true)
  end
  self.winnr = nil
end

function Window:set_scroll()
  if self:is_visible() then
    local winnr = vim.api.nvim_get_current_win()
    self:focus()
    vim.api.nvim_command(":setl cursorbind scrollbind")
    vim.api.nvim_set_current_win(winnr)
  end
end

function Window:sync_scroll(line, center)
  if self:is_visible() then
    local winnr = vim.api.nvim_get_current_win()
    self:focus()
    local cursor = vim.api.nvim_win_get_cursor(0)
    pcall(vim.api.nvim_win_set_cursor, 0, {line, cursor[2]})
    if center == true then
      vim.cmd('normal! zz')
    end
    vim.api.nvim_set_current_win(winnr)
  end
end

function Window:unset_scroll()
  if self:is_visible() then
    local winnr = vim.api.nvim_get_current_win()
    self:focus()
    vim.api.nvim_command(":setl nocursorbind noscrollbind")
    vim.api.nvim_set_current_win(winnr)
  end
end

return Window
