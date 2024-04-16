local File = {}

function File:new(origin, win, to_origin)
  local filename=vim.fn.fnamemodify(origin, ":t")
  local file = vim.fn.tempname().."_"..filename
  to_origin[file] = origin
  local newObj = {
    file = file,
    origin = origin,
    buf = nil,
    win = win
  }
  setmetatable(newObj, self)
  self.__index = self
  return newObj
end

function File:set_current()
  self.buf = vim.api.nvim_get_current_buf()
  self.win.win = vim.api.nvim_get_current_win()
end

function File:is_new_buf()
  return self.buf == nil
end

function File:on_closed()
  self.win.show = false
  self.win.win = nil
end

return File
