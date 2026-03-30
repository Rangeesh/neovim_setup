return {
  -- Obsidian.nvim: Zettelkasten-style notes in Neovim
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>no", "<cmd>ObsidianOpen<CR>", desc = "Open in Obsidian app" },
      { "<leader>nn", "<cmd>ObsidianNew<CR>", desc = "New note" },
      { "<leader>nd", "<cmd>ObsidianToday<CR>", desc = "Today's daily note" },
      { "<leader>ny", "<cmd>ObsidianYesterday<CR>", desc = "Yesterday's note" },
      { "<leader>nt", "<cmd>ObsidianTomorrow<CR>", desc = "Tomorrow's note" },
      { "<leader>ns", "<cmd>ObsidianSearch<CR>", desc = "Search notes" },
      { "<leader>nf", "<cmd>ObsidianQuickSwitch<CR>", desc = "Find note" },
      { "<leader>nl", "<cmd>ObsidianLinks<CR>", desc = "Show links in note" },
      { "<leader>nb", "<cmd>ObsidianBacklinks<CR>", desc = "Show backlinks" },
      { "<leader>nc", "<cmd>ObsidianTOC<CR>", desc = "Table of contents" },
      { "<leader>nk", "<cmd>ObsidianTemplate<CR>", desc = "Insert template" },
      { "<leader>nr", "<cmd>ObsidianRename<CR>", desc = "Rename note (update links)" },
      { "<leader>n[", "<cmd>ObsidianTags<CR>", desc = "Search by tag" },
      -- Checkbox cycling: [ ] -> [/] -> [x] -> [!] -> [~] -> [ ]
      {
        "<leader>nx",
        function()
          local line = vim.api.nvim_get_current_line()
          local states = { "[ ]", "[/]", "[x]", "[!]", "[~]" }
          for i, state in ipairs(states) do
            if line:find(state, 1, true) then
              local next_state = states[(i % #states) + 1]
              local new_line = line:gsub("%[.%]", next_state, 1)
              vim.api.nvim_set_current_line(new_line)
              return
            end
          end
          -- No checkbox found — add one
          local new_line = line:gsub("^(%s*[-*]+%s)", "%1[ ] ", 1)
          if new_line == line then
            new_line = line:gsub("^(%s*)", "%1- [ ] ", 1)
          end
          vim.api.nvim_set_current_line(new_line)
        end,
        ft = "markdown",
        desc = "Cycle checkbox state",
      },
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
      },
      -- Daily notes config (matches your existing YYYY-MM-DD.md format)
      daily_notes = {
        folder = ".",             -- daily notes in root of vault
        date_format = "%Y-%m-%d", -- matches your existing files
        template = nil,
      },
      -- Note ID: use the title as filename (readable names, not random IDs)
      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          -- Slugify: lowercase, replace spaces with dashes, remove special chars
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- No title: use timestamp
          suffix = tostring(os.time())
        end
        return suffix
      end,
      -- Put new notes in topics/ by default
      new_notes_location = "notes_subdir",
      notes_subdir = "topics",
      -- Wiki links: use [[note-name]] style
      wiki_link_func = "use_alias_only",
      preferred_link_style = "wiki",
      -- Don't add frontmatter by default (keep notes clean)
      disable_frontmatter = false,
      note_frontmatter_func = function(note)
        local out = { tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
      -- Follow links with gf
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
      -- Picker integration with fzf-lua
      picker = {
        name = "fzf-lua",
      },
      -- Completion
      completion = {
        nvim_cmp = false,
        min_chars = 2,
      },
      -- UI handled by render-markdown.nvim instead
      ui = { enable = false },
    },
  },

  -- render-markdown.nvim: pretty markdown rendering in the buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "Avante" },
    keys = {
      { "<leader>nm", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
    },
    opts = {
      heading = {
        enabled = true,
        sign = false,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },
      code = {
        enabled = true,
        sign = false,
        style = "full",           -- full block with language label
        width = "block",
        left_pad = 2,
        right_pad = 2,
        language_pad = 1,
        border = "thick",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "  TODO ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "  DONE ", highlight = "RenderMarkdownChecked" },
        custom = {
          important = { raw = "[!]", rendered = "  IMPT ", highlight = "RenderMarkdownImportant" },
          inprogress = { raw = "[/]", rendered = "  WIP  ", highlight = "RenderMarkdownProgress" },
          cancelled = { raw = "[~]", rendered = "  SKIP ", highlight = "RenderMarkdownCancelled" },
        },
      },
      pipe_table = {
        enabled = true,
        style = "full",
      },
      link = {
        enabled = true,
        wiki = { icon = "🔗 " },
        hyperlink = { icon = " " },
      },
      win_options = {
        conceallevel = { rendered = 2 },
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- Monokai-themed heading colors
      local set = vim.api.nvim_set_hl
      set(0, "RenderMarkdownH1", { fg = "#f92672", bold = true })
      set(0, "RenderMarkdownH2", { fg = "#a6e22e", bold = true })
      set(0, "RenderMarkdownH3", { fg = "#e6db74", bold = true })
      set(0, "RenderMarkdownH4", { fg = "#66d9ef", bold = true })
      set(0, "RenderMarkdownH5", { fg = "#ae81ff", bold = true })
      set(0, "RenderMarkdownH6", { fg = "#fd971f", bold = true })
      set(0, "RenderMarkdownH1Bg", { bg = "#2a0a14" })
      set(0, "RenderMarkdownH2Bg", { bg = "#1a2a0a" })
      set(0, "RenderMarkdownH3Bg", { bg = "#2a2a0a" })
      set(0, "RenderMarkdownH4Bg", { bg = "#0a1a2a" })
      set(0, "RenderMarkdownH5Bg", { bg = "#1a0a2a" })
      set(0, "RenderMarkdownH6Bg", { bg = "#2a1a0a" })
      set(0, "RenderMarkdownCode", { bg = "#1a1a1a" })
      set(0, "RenderMarkdownCodeInline", { bg = "#1a1a1a", fg = "#fd971f" })

      -- Checkbox highlights
      set(0, "RenderMarkdownUnchecked", { fg = "#000000", bg = "#fd971f", bold = true })  -- orange bg
      set(0, "RenderMarkdownChecked", { fg = "#000000", bg = "#a6e22e", bold = true })    -- green bg
      set(0, "RenderMarkdownProgress", { fg = "#000000", bg = "#66d9ef", bold = true })   -- cyan bg
      set(0, "RenderMarkdownCancelled", { fg = "#000000", bg = "#75715e", bold = true })  -- gray bg
      set(0, "RenderMarkdownImportant", { fg = "#000000", bg = "#f92672", bold = true })  -- pink bg
    end,
  },
}
