local Window = require'hex.Window'

local File = {}

function File:new(origin, to_origin)
  local filename=vim.fn.fnamemodify(origin, ":t")
  local file = vim.fn.tempname().."_"..filename
  to_origin[file] = origin
  local newObj = {
    file = file,
    origin = origin,
    buf = nil,
    win = Window:new(),
    col = 0,
  }
  setmetatable(newObj, self)
  self.__index = self
  return newObj
end

function File:set_current()
  self.buf = vim.api.nvim_get_current_buf()
  self.win.winnr = vim.api.nvim_get_current_win()
end

function File:is_new_buf()
  return self.buf == nil
end

return File
