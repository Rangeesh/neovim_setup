return {
  {
    "folke/sidekick.nvim",
    opts = {
      -- Disable Copilot NES (we don't have a Copilot subscription)
      nes = { enabled = false },

      -- AI CLI integration (OpenCode)
      cli = {
        watch = true, -- auto-reload files modified by AI tools
        win = {
          layout = "right",
          split = {
            width = 80,
            height = 20,
          },
        },
        mux = {
          backend = "tmux",
          enabled = true,  -- persist CLI sessions via tmux
          create = "terminal",
        },
        -- OpenCode is already configured as a built-in tool
        tools = {
          opencode = {
            cmd = { "opencode" },
            env = { OPENCODE_THEME = "system" },
          },
        },
        picker = "fzf-lua",
      },
    },
    keys = {
      -- Toggle OpenCode CLI
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
        desc = "Toggle OpenCode",
      },
      -- Select AI CLI tool
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        desc = "Select AI CLI",
      },
      -- Detach CLI session
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "Detach CLI session",
      },
      -- Send context to AI
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "n", "x" },
        desc = "Send this (context at cursor)",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send current file",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send visual selection",
      },
      -- Prompt picker
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Select prompt (explain, fix, review...)",
      },
      -- Quick toggle with Ctrl+.
      {
        "<C-.>",
        function() require("sidekick.cli").toggle() end,
        mode = { "n", "t", "i", "x" },
        desc = "Toggle Sidekick CLI",
      },
    },
  },
}
