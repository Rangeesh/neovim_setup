local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Resize splits when window is resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_loc", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-create parent directories when saving a file
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Set Python-specific options
autocmd("FileType", {
  group = augroup("python_opts", { clear = true }),
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "88"

    -- matchadd overrides (priority 300 beats treesitter extmarks at 100)
    -- self/cls -> orange italic
    vim.fn.matchadd("SelfKeyword", [[\<self\>]], 300)
    vim.fn.matchadd("SelfKeyword", [[\<cls\>]], 300)

    -- Module paths: dotted names after from/import -> cyan italic
    vim.fn.matchadd("PyModule", [[\v(from\s+)@<=(\w+\.)+\w+]], 300)
    vim.fn.matchadd("PyModule", [[\v(import\s+)@<=(\w+\.)+\w+]], 300)

    -- Imported names: CamelCase names in import blocks -> cyan (types/classes)
    vim.fn.matchadd("PyType", "\\v(import\\s+\\(?\\n?\\s*)@<=[A-Z]\\w*", 300)
    vim.fn.matchadd("PyType", "\\v^\\s+[A-Z]\\w*\\ze\\s*,?\\s*$", 300)

    -- Type annotations: CamelCase after : or -> -> cyan
    vim.fn.matchadd("PyType", "\\v(:\\s*)@<=[A-Z]\\w*", 300)
    vim.fn.matchadd("PyType", "\\v(->\\s*)@<=[A-Z]\\w*", 300)

    -- Superclass names: CamelCase inside class Foo(Bar, Baz) -> cyan
    vim.fn.matchadd("PyType", "\\v(class\\s+\\w+\\()@<=[A-Z]\\w*", 300)
    vim.fn.matchadd("PyType", "\\v(,\\s*)@<=[A-Z]\\w*\\ze\\s*[,)]", 300)

    -- Imported lowercase names (functions): after import ( on indented lines -> green
    vim.fn.matchadd("PyFuncImport", "\\v^\\s+[a-z_]\\w*\\ze\\s*,?\\s*$", 290)

    -- UPPER_CASE constants -> purple
    vim.fn.matchadd("PyConstant", "\\v<[A-Z][A-Z0-9_]+>", 290)

    -- CamelCase identifiers anywhere (class names, constructors, type refs) -> cyan
    -- Matches words starting with uppercase followed by at least one lowercase letter
    vim.fn.matchadd("PyType", "\\v<[A-Z][a-zA-Z0-9]*[a-z][a-zA-Z0-9]*>", 280)

    -- Function/method calls: any word immediately followed by ( -> green
    vim.fn.matchadd("PyFuncImport", "\\v<[a-z_][a-zA-Z0-9_]*\\ze\\(", 280)
  end,
})

-- Set C/C++ specific options
autocmd("FileType", {
  group = augroup("c_cpp_opts", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- Autosave on focus lost or buffer leave
autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("autosave", { clear = true }),
  pattern = "*",
  command = "silent! wa",
})

-- Close certain filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = { "help", "man", "qf", "checkhealth", "lspinfo", "notify", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})
