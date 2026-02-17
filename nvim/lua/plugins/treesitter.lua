return {
  -- Treesitter: syntax highlighting, code folding
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- load eagerly so parsers are available immediately
    config = function()
      -- nvim-treesitter (latest) removed the old configs module.
      -- Neovim 0.11+ auto-enables treesitter highlighting for any
      -- filetype with an installed parser. Use TSInstall or setup.sh
      -- to install parsers.
      local ok, install = pcall(require, "nvim-treesitter.install")
      if not ok then
        return -- plugin not yet downloaded (first boot via setup.sh)
      end
      install.auto_install = true

      -- Install desired parsers if missing
      local parsers = {
        "python", "c", "cpp", "lua", "bash",
        "json", "yaml", "toml", "markdown",
        "markdown_inline", "vim", "vimdoc",
        "diff", "gitcommit", "dockerfile",
        "make", "cmake", "regex",
      }
      install.install(parsers)
    end,
  },

  -- Treesitter textobjects: select/move by function, class, etc.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local select_ok, select = pcall(require, "nvim-treesitter-textobjects.select")
      local move_ok, move = pcall(require, "nvim-treesitter-textobjects.move")
      local swap_ok, swap = pcall(require, "nvim-treesitter-textobjects.swap")

      if not (select_ok and move_ok and swap_ok) then
        vim.notify("treesitter-textobjects failed to load", vim.log.levels.WARN)
        return
      end

      local map = vim.keymap.set

      -- Select keymaps
      map({ "x", "o" }, "af", function() select.select_textobject("@function.outer") end, { desc = "around function" })
      map({ "x", "o" }, "if", function() select.select_textobject("@function.inner") end, { desc = "inside function" })
      map({ "x", "o" }, "ac", function() select.select_textobject("@class.outer") end, { desc = "around class" })
      map({ "x", "o" }, "ic", function() select.select_textobject("@class.inner") end, { desc = "inside class" })
      map({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer") end, { desc = "around argument" })
      map({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner") end, { desc = "inside argument" })

      -- Move keymaps
      map({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer") end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer") end, { desc = "Next class start" })
      map({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.inner") end, { desc = "Next argument" })
      map({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer") end, { desc = "Next function end" })
      map({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer") end, { desc = "Next class end" })
      map({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer") end, { desc = "Prev function start" })
      map({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer") end, { desc = "Prev class start" })
      map({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.inner") end, { desc = "Prev argument" })
      map({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer") end, { desc = "Prev function end" })
      map({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer") end, { desc = "Prev class end" })

      -- Swap keymaps
      map("n", "<leader>sn", function() swap.swap_next("@parameter.inner") end, { desc = "Swap with next parameter" })
      map("n", "<leader>sp", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap with prev parameter" })
    end,
  },

  -- Treesitter context: sticky function/class header
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 20,
      multiline_threshold = 1,
      trim_scope = "outer",
    },
    keys = {
      {
        "[x",
        function() require("treesitter-context").go_to_context() end,
        desc = "Jump to context (upward)",
      },
    },
  },

  -- Rainbow delimiters: colored brackets by nesting level
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
