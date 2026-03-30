local map = vim.keymap.set

-- Better escape
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation handled by vim-tmux-navigator plugin (see editor.lua)
-- <C-h/j/k/l> navigates both vim splits and tmux panes

-- Resize windows with arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Prev search result centered" })

-- Better paste (don't overwrite register)
map("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- Indent in visual mode (stay in visual)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Quickfix navigation
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })

-- Diagnostic navigation
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Peek definition in floating window (like VS Code Alt+F12)
map("n", "gpd", function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, ctx)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No definition found", vim.log.levels.INFO)
      return
    end
    local def = vim.islist(result) and result[1] or result
    local uri = def.uri or def.targetUri
    local range = def.range or def.targetSelectionRange or def.targetRange
    if not uri or not range then return end
    local bufnr = vim.uri_to_bufnr(uri)
    vim.fn.bufload(bufnr)
    local start_line = range.start.line
    local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, start_line - 2), start_line + 40, false)
    local float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
    local ft = vim.bo[bufnr].filetype
    if ft ~= "" then vim.bo[float_buf].filetype = ft end
    local width = math.min(120, math.floor(vim.o.columns * 0.7))
    local height = math.min(#lines, 30)
    vim.api.nvim_open_win(float_buf, true, {
      relative = "cursor", row = 1, col = 0,
      width = width, height = height,
      border = "rounded", style = "minimal",
      title = " " .. vim.fn.fnamemodify(vim.uri_to_fname(uri), ":.") .. ":" .. (start_line + 1) .. " ",
      title_pos = "center",
    })
    vim.api.nvim_win_set_cursor(0, { math.min(3, #lines), 0 })
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = float_buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = float_buf, silent = true })
  end)
end, { desc = "Peek definition (floating)" })

-- Open definition in vertical split (like VS Code Ctrl+\ then gd)
map("n", "gvd", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Go to definition in vsplit" })

-- VSCode-style comment toggle (Ctrl+/)
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle line comment" })
map("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })

-- Terminal (snacks.nvim)
map({ "n", "t" }, "<leader>t", function()
  Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } })
end, { desc = "Toggle terminal" })

map({ "n", "t" }, "<leader>T", function()
  Snacks.terminal.toggle(nil, { win = { position = "float" } })
end, { desc = "Toggle floating terminal" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Copy file path variants
map("n", "<leader>cp", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied relative path" })
end, { desc = "Copy relative path" })

map("n", "<leader>cP", function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied absolute path" })
end, { desc = "Copy absolute path" })

map("n", "<leader>cn", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.notify(name, vim.log.levels.INFO, { title = "Copied filename" })
end, { desc = "Copy filename" })

map("n", "<leader>cl", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied path:line" })
end, { desc = "Copy path:line" })

map("n", "<leader>cL", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.") .. ":" .. vim.fn.line(".") .. ":" .. vim.fn.col(".")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied path:line:col" })
end, { desc = "Copy path:line:col" })

-- Right-click popup menu: add path copy items to Neovim's built-in popup
-- (Neovim 0.10+ already provides LSP items: Go to Definition, References, etc.)
vim.cmd([[
  amenu PopUp.-PathSep-               <Nop>
  amenu PopUp.Copy\ Relative\ Path    <cmd>lua vim.fn.setreg('+', vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':.'))<CR>
  amenu PopUp.Copy\ Absolute\ Path    <cmd>lua vim.fn.setreg('+', vim.api.nvim_buf_get_name(0))<CR>
  amenu PopUp.Copy\ Filename           <cmd>lua vim.fn.setreg('+', vim.fn.expand('%:t'))<CR>
  amenu PopUp.Copy\ Path:Line          <cmd>lua vim.fn.setreg('+', vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':.') .. ':' .. vim.fn.line('.'))<CR>
]])
