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
          },
        },
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = false,
      },
      highlights = {
          fill = { bg = "#000000" },
          background = { bg = "#0a0a0a" },
          buffer_selected = { bg = "#1a1a1a", bold = true, italic = false },
          buffer_visible = { bg = "#0a0a0a" },
          separator = { fg = "#000000", bg = "#0a0a0a" },
          separator_selected = { fg = "#000000", bg = "#1a1a1a" },
          separator_visible = { fg = "#000000", bg = "#0a0a0a" },
        },
    },
  },
}
