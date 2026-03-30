return {
  -- Lualine: statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "monokai-pro",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard", "lazy" },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = {
          {
            "filename",
            path = 1, -- relative path
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = " [No Name]",
            },
          },
          { "diagnostics" },
        },
        lualine_x = {
          -- Sidekick CLI session status
          {
            function()
              local ok, status = pcall(require, "sidekick.status")
              if ok then
                local cli = status.cli()
                if #cli > 0 then
                  return " " .. (#cli > 1 and #cli or "")
                end
              end
              return ""
            end,
            cond = function()
              local ok, status = pcall(require, "sidekick.status")
              if ok then
                return #status.cli() > 0
              end
              return false
            end,
            color = { fg = "#a9dc76" },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "neo-tree", "lazy", "trouble", "quickfix" },
    },
  },

  -- Bufferline: tab/buffer bar
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
      { "<leader>bP", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Close buffers to right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Close buffers to left" },
      { "<leader>bs", "<cmd>BufferLineSortByDirectory<CR>", desc = "Sort by directory" },
      { "<S-Left>", "<cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
      { "<S-Right>", "<cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
    },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict, _)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or " ")
            s = s .. n .. sym
          end
          return s
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
            text_align = "left",
          },
        },
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = false,
      },
      highlights = {
          fill = { bg = "#000000" },
          background = { bg = "#0a0a0a", fg = "#505050" },
          buffer_selected = { bg = "#1a1a1a", fg = "#a6e22e", bold = true, italic = false },
          buffer_visible = { bg = "#0a0a0a", fg = "#75715e" },
          separator = { fg = "#000000", bg = "#0a0a0a" },
          separator_selected = { fg = "#000000", bg = "#1a1a1a" },
          separator_visible = { fg = "#000000", bg = "#0a0a0a" },
          indicator_selected = { fg = "#a6e22e", bg = "#1a1a1a" },
          modified_selected = { fg = "#e6db74", bg = "#1a1a1a" },
          modified = { fg = "#505050", bg = "#0a0a0a" },
        },
    },
  },

  -- Dropbar: VSCode-style breadcrumbs / winbar
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      bar = {
        enable = function(buf, win, _)
          local dominated = vim.tbl_contains(
            { "neo-tree", "dashboard", "lazy", "mason", "trouble", "dap-repl", "help", "qf" },
            vim.bo[buf].filetype
          )
          return not dominated
            and vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_win_is_valid(win)
            and vim.wo[win].winbar == ""
            and vim.fn.win_gettype(win) == ""
        end,
      },
    },
  },
}
