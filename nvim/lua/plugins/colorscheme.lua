return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      filter = "classic",
      transparent_background = false,
      inc_search = "underline",
      plugins = {
        bufferline = {
          underline_selected = false,
          underline_visible = false,
        },
        indent_blankline = {
          context_highlight = "pro",
          context_start_underline = false,
        },
      },
    },
    config = function(_, opts)
      require("monokai-pro").setup(opts)
      vim.cmd.colorscheme("monokai-pro")

      -- Override background to pure black (matching OpenCode)
      local bg = "#000000"
      local set = vim.api.nvim_set_hl

      set(0, "Normal", { bg = bg, fg = "#fcfcfa" })
      set(0, "NormalNC", { bg = bg, fg = "#fcfcfa" })
      set(0, "NormalFloat", { bg = "#0a0a0a", fg = "#fcfcfa" })
      set(0, "FloatBorder", { bg = "#0a0a0a", fg = "#505050" })
      set(0, "SignColumn", { bg = bg })
      set(0, "FoldColumn", { bg = bg })
      set(0, "CursorLine", { bg = "#111111" })
      set(0, "CursorLineNr", { fg = "#fcfcfa", bg = bg, bold = true })
      set(0, "LineNr", { fg = "#505050", bg = bg })
      set(0, "StatusLine", { bg = "#0a0a0a", fg = "#fcfcfa" })
      set(0, "StatusLineNC", { bg = "#0a0a0a", fg = "#505050" })
      set(0, "WinSeparator", { fg = "#2d2d2d", bg = bg })
      set(0, "VertSplit", { fg = "#2d2d2d", bg = bg })
      set(0, "EndOfBuffer", { fg = bg, bg = bg })
      set(0, "MsgArea", { bg = bg })
      set(0, "TabLine", { bg = "#0a0a0a" })
      set(0, "TabLineFill", { bg = bg })

      -- Keep neo-tree dark
      set(0, "NeoTreeNormal", { bg = "#0a0a0a", fg = "#fcfcfa" })
      set(0, "NeoTreeNormalNC", { bg = "#0a0a0a", fg = "#fcfcfa" })
      set(0, "NeoTreeEndOfBuffer", { bg = "#0a0a0a", fg = "#0a0a0a" })

      -- Treesitter highlight overrides for better Python differentiation
      -- Classic Monokai colors:
      --   pink:   #f92672  (keywords, operators)
      --   green:  #a6e22e  (functions)
      --   yellow: #e6db74  (strings)
      --   orange: #fd971f  (parameters, self)
      --   cyan:   #66d9ef  (types, builtins)
      --   purple: #ae81ff  (numbers, constants)
      --   white:  #f8f8f2  (plain variables)

      -- self, cls -> orange italic (stands out from regular variables)
      set(0, "@variable.builtin", { fg = "#fd971f", italic = true })
      set(0, "@variable.builtin.python", { fg = "#fd971f", italic = true })
      -- SelfKeyword: used by matchadd in python FileType autocmd to force self/cls orange
      set(0, "SelfKeyword", { fg = "#fd971f", italic = true })
      -- Clear @variable so it doesn't override more specific captures.
      -- matchadd rules in autocmds.lua handle coloring imports, types, etc.
      set(0, "@variable", {})
      set(0, "@variable.python", {})
      -- object.member -> white
      set(0, "@variable.member", { fg = "#f8f8f2" })
      set(0, "@property", { fg = "#f8f8f2" })
      -- parameters -> orange italic
      set(0, "@variable.parameter", { fg = "#fd971f", italic = true })
      -- builtin functions (len, print, abs, range) -> cyan
      set(0, "@function.builtin", { fg = "#66d9ef" })
      -- regular functions -> green
      set(0, "@function", { fg = "#a6e22e" })
      set(0, "@function.call", { fg = "#a6e22e" })
      set(0, "@function.method", { fg = "#a6e22e" })
      set(0, "@function.method.call", { fg = "#a6e22e" })
      -- decorators -> green
      set(0, "@attribute", { fg = "#a6e22e" })
      -- numbers/booleans/None -> purple
      set(0, "@number", { fg = "#ae81ff" })
      set(0, "@boolean", { fg = "#ae81ff" })
      set(0, "@constant.builtin", { fg = "#ae81ff" })
      -- types -> cyan
      set(0, "@type", { fg = "#66d9ef" })
      set(0, "@type.builtin", { fg = "#66d9ef", italic = true })
      -- keywords -> pink
      set(0, "@keyword", { fg = "#f92672", italic = true })
      set(0, "@keyword.return", { fg = "#f92672", italic = true })
      set(0, "@keyword.function", { fg = "#66d9ef", italic = true })
      set(0, "@keyword.operator", { fg = "#f92672" })
      set(0, "@keyword.import", { fg = "#f92672", italic = true })
      -- operators -> pink
      set(0, "@operator", { fg = "#f92672" })
      -- strings -> yellow
      set(0, "@string", { fg = "#e6db74" })
      set(0, "@string.escape", { fg = "#ae81ff" })
      -- comments -> grey
      set(0, "@comment", { fg = "#75715e", italic = true })
      -- punctuation
      set(0, "@punctuation.bracket", { fg = "#f8f8f2" })
      set(0, "@punctuation.delimiter", { fg = "#f8f8f2" })
      -- constructor / class name
      set(0, "@constructor", { fg = "#a6e22e" })

      -- module names in imports (e.g., covariant.models.llm...)
      set(0, "@module", { fg = "#66d9ef", italic = true })
      set(0, "@module.python", { fg = "#66d9ef", italic = true })

      -- LSP semantic token highlights (Pyright provides these)
      -- These give much richer coloring than treesitter alone — class names,
      -- type references, namespaces, etc. all get distinct colors instead of
      -- falling through to white.
      set(0, "@lsp.type.class", { fg = "#66d9ef" })              -- class name references (e.g., MultiModalTokenizerConfig in annotations)
      set(0, "@lsp.type.type", { fg = "#66d9ef" })               -- type references
      set(0, "@lsp.type.typeParameter", { fg = "#66d9ef", italic = true }) -- generic type params
      set(0, "@lsp.type.namespace", { fg = "#66d9ef", italic = true })     -- module/package references
      set(0, "@lsp.type.parameter", { fg = "#fd971f", italic = true })     -- function parameters
      set(0, "@lsp.type.variable", {})                            -- keep cleared (same as @variable)
      set(0, "@lsp.type.property", { fg = "#f8f8f2" })           -- object properties
      set(0, "@lsp.type.decorator", { fg = "#a6e22e" })          -- decorators
      set(0, "@lsp.type.function", { fg = "#a6e22e" })           -- function references
      set(0, "@lsp.type.method", { fg = "#a6e22e" })             -- method references
      set(0, "@lsp.type.enum", { fg = "#66d9ef" })               -- enum types
      set(0, "@lsp.type.enumMember", { fg = "#ae81ff" })         -- enum values -> purple like constants

      -- LSP semantic modifiers (fine-tuning)
      set(0, "@lsp.mod.defaultLibrary", { italic = true })       -- stdlib items get italic
      set(0, "@lsp.typemod.function.defaultLibrary", { fg = "#66d9ef" }) -- builtin functions -> cyan
      set(0, "@lsp.typemod.class.defaultLibrary", { fg = "#66d9ef", italic = true }) -- builtin types -> cyan italic

      -- matchadd highlight groups (used in python_opts autocmd)
      set(0, "PyModule", { fg = "#66d9ef", italic = true })       -- module paths in imports
      set(0, "PyType", { fg = "#66d9ef" })                        -- imported class names, type annotations, superclasses
      set(0, "PyFuncImport", { fg = "#a6e22e" })                  -- imported function names (lowercase)
      set(0, "PyConstant", { fg = "#ae81ff" })                    -- UPPER_CASE constants
    end,
  },
}
