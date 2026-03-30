return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hi", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>ht", gs.toggle_deleted, "Toggle deleted lines inline")
      end,
    },
  },

  -- Git-conflict: inline merge/rebase conflict resolution (VSCode-style)
  {
    "akinsho/git-conflict.nvim",
    event = "BufReadPost",
    opts = {
      default_mappings = true, -- co=ours, ct=theirs, cb=both, c0=none, ]x/[x=navigate
      default_commands = true,
      disable_diagnostics = true, -- disable diagnostics in conflict regions
      list_opener = "copen",
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
  },

  -- Diffview: side-by-side diffs and 3-way merge tool
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<CR>", desc = "File history (repo)" },
      { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
      file_panel = {
        win_config = {
          position = "left",
          width = 35,
        },
      },
    },
  },
}
