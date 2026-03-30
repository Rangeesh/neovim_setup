return {
  -- Which-key: show available keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
      spec = {
        { "<leader>f", group = "find/search" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "git hunks" },
        { "<leader>a", group = "ai (OpenCode)" },
        { "<leader>b", group = "buffer" },
        { "<leader>s", group = "search/replace" },
        { "<leader>d", group = "debug" },
        { "<leader>x", group = "trouble/diagnostics" },
        { "<leader>n", group = "notes" },
        { "<leader>t", group = "terminal", icon = " " },
      },
    },
  },

  -- Neo-tree: file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
      { "<leader>E", "<cmd>Neotree reveal<CR>", desc = "Reveal file in explorer" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".git",
            "node_modules",
            "__pycache__",
            ".venv",
          },
        },
      },
      window = {
        width = 45,
        mappings = {
          ["<space>"] = "none",
          ["<C-h>"] = function() vim.cmd("TmuxNavigateLeft") end,
          ["<C-j>"] = function() vim.cmd("TmuxNavigateDown") end,
          ["<C-k>"] = function() vim.cmd("TmuxNavigateUp") end,
          ["<C-l>"] = function() vim.cmd("TmuxNavigateRight") end,
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
      },
    },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Toggle line comment" },
      { "gc", mode = { "n", "v" }, desc = "Toggle comment" },
    },
    opts = {},
  },

  -- Trouble: better diagnostics list
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
    },
    opts = {},
  },

  -- Conform: auto-formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format file/selection",
      },
    },
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "black", stop_after_first = true },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        json = { "jq" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },

  -- Nvim-lint: linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
      }
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Vim-tmux-navigator: seamless navigation between vim and tmux panes
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Navigate left (vim/tmux)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Navigate down (vim/tmux)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Navigate up (vim/tmux)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Navigate right (vim/tmux)" },
    },
  },

  -- Indent blankline: visual indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help", "dashboard", "neo-tree", "Trouble", "lazy", "mason",
          "notify", "toggleterm",
        },
      },
    },
  },

  -- Snacks.nvim: various utilities (notifications, dashboard)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      indent = { enabled = false }, -- using indent-blankline instead
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      terminal = { enabled = true },
      words = { enabled = true },
    },
  },

  -- Grug-far: project-wide find and replace (VSCode-like)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        desc = "Find and replace (project)",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Replace word under cursor",
      },
      {
        "<leader>sr",
        function()
          require("grug-far").open({ visual = true })
        end,
        mode = "v",
        desc = "Replace selection",
      },
    },
    opts = {
      headerHeight = 3,
      windowCreationCommand = "split",
      transient = true,
    },
  },
}
