local M = {}

M.is_binary_file = function(file)
  if string.sub(file, 1, 5) == '/tmp/' then return false end
  if vim.bo.ft ~= "" then return false end
  if vim.bo.bin then return true end
  local filename = vim.fn.fnamemodify(file, ":t")
  local ext = vim.fn.fnamemodify(file, ":e")
  binary_ext = { 'out', 'bin', 'png', 'jpg', 'jpeg', 'exe', 'dll' }
  if vim.tbl_contains(binary_ext, ext) then return true end
  return false
end

M.bind_scroll_and_cursor = function(sync)
  vim.api.nvim_command(":setl cursorbind scrollbind")
  if sync then
    vim.api.nvim_command(":syncbind")
  end
end

M.unbind_scroll_and_cursor = function()
  vim.api.nvim_command(":setl noscrollbind nocursorbind")
end

M.int_div = function(dividend, divisor)
  return (dividend - (dividend % divisor)) / divisor
end

return M
