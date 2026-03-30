return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      -- File finding (VSCode Ctrl+P equivalent)
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fB", "<cmd>FzfLua buffers<CR>", desc = "Open buffers" },

      -- Text search (VSCode Ctrl+Shift+F equivalent)
      { "<leader>fg", "<cmd>FzfLua grep<CR>", desc = "Grep (enter pattern)" },
      { "<leader>fl", "<cmd>FzfLua live_grep<CR>", desc = "Live grep (as you type)" },
      { "<leader>f/", "<cmd>FzfLua live_grep_glob<CR>", desc = "Live grep with glob filter" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep word under cursor" },
      { "<leader>fW", "<cmd>FzfLua grep_cWORD<CR>", desc = "Grep WORD under cursor" },
      { "<leader>fv", "<cmd>FzfLua grep_visual<CR>", mode = "v", desc = "Grep visual selection" },

      -- Buffer search (VSCode Ctrl+F equivalent)
      { "<leader>fb", "<cmd>FzfLua blines<CR>", desc = "Search current buffer" },
      { "<leader>fL", "<cmd>FzfLua lines<CR>", desc = "Search all open buffers" },

      -- LSP symbols (VSCode Ctrl+Shift+O / Ctrl+T)
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<CR>", desc = "Workspace symbols" },

      -- Diagnostics
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "Document diagnostics" },
      { "<leader>fD", "<cmd>FzfLua diagnostics_workspace<CR>", desc = "Workspace diagnostics" },

      -- Git
      { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Git commits" },
      { "<leader>gb", "<cmd>FzfLua git_branches<CR>", desc = "Git branches" },
      { "<leader>gg", "<cmd>FzfLua git_status<CR>", desc = "Git status" },

      -- Misc
      { "<leader>fh", "<cmd>FzfLua helptags<CR>", desc = "Help tags" },
      { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>FzfLua commands<CR>", desc = "Commands" },
      { "<leader>f:", "<cmd>FzfLua command_history<CR>", desc = "Command history" },
      { "<leader>fR", "<cmd>FzfLua resume<CR>", desc = "Resume last picker" },

      -- Quick access
      { "<leader><leader>", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>/", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<leader>fv", "<cmd>FzfLua files actions={ ['default']=require'fzf-lua.actions'.file_vsplit }<CR>", desc = "Find files -> vsplit" },
    },
    opts = {
      -- Global options
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = "rounded",
        backdrop = 60,
        preview = {
          border = "rounded",
          wrap = false,
          hidden = false,
          vertical = "down:45%",
          horizontal = "right:55%",
          layout = "flex",
          flip_columns = 120,
          delay = 20,
        },
      },
      fzf_opts = {
        ["--layout"] = "reverse",
        ["--info"] = "inline-right",
        ["--highlight-line"] = true,
      },
      fzf_colors = true, -- inherit from Neovim colorscheme
      files = {
        prompt = "Files> ",
        git_icons = false,
        file_icons = true,
        color_icons = true,
        hidden = true,
        follow = false,
        fd_opts = [[--color=never --hidden --type f --type l --exclude .git --exclude node_modules --exclude __pycache__ --exclude .venv]],
        cwd_prompt = true,
      },
      buffers = {
        prompt = "Buffers> ",
        sort_lastused = true,          -- most recently used first
        formatter = "path.filename_first",  -- show filename first, then path
      },
      grep = {
        prompt = "Grep> ",
        input_prompt = "Grep For> ",
        git_icons = false,
        file_icons = true,
        color_icons = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        hidden = true,
      },
      lsp = {
        symbols = {
          prompt = "Symbols> ",
          symbol_icons = {
            File = " ",
            Module = " ",
            Namespace = " ",
            Package = " ",
            Class = " ",
            Method = " ",
            Property = " ",
            Field = " ",
            Constructor = " ",
            Enum = " ",
            Interface = " ",
            Function = " ",
            Variable = " ",
            Constant = " ",
            String = " ",
            Number = " ",
            Boolean = " ",
            Array = " ",
            Object = " ",
            Key = " ",
            Null = " ",
            EnumMember = " ",
            Struct = " ",
            Event = " ",
            Operator = " ",
            TypeParameter = " ",
          },
        },
      },
    },
  },
}
