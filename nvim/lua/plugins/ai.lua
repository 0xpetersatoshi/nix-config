return {
  -- codeium
  {
    "Exafunction/codeium.vim",
    enabled = true,
    event = "BufEnter",
    config = function()
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "kk", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
    end,
  },

  -- code companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        display = {
          diff = {
            provider = "mini_diff",
          },
        },
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:op read op://Private/anthropic-api-keys/code-companion-nvim --no-newline",
              },
            })
          end,
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.5-sonnet",
                },
                max_tokens = {
                  default = 8192,
                },
              },
            })
          end,
        },
        strategies = {
          chat = {
            adapter = "anthropic",
            roles = {
              llm = "Claude",
            },
          },
          inline = {
            adapter = "anthropic",
          },
          cmd = {
            adapter = "anthropic",
          },
        },
      })

      -- Add custom keymaps after setup
      vim.keymap.set(
        "n",
        "<leader>cn",
        ":CodeCompanionChat<CR>",
        { silent = true, desc = "Open new CodeCompanion chat" }
      )
      vim.keymap.set(
        "v",
        "<leader>ca",
        ":CodeCompanionChat Add<CR>",
        { silent = true, desc = "Add selection to CodeCompanion chat" }
      )
      vim.keymap.set(
        "n",
        "<leader>ca",
        ":CodeCompanionActions<CR>",
        { silent = true, desc = "Open CodeCompanion Actions Pallete" }
      )
    end,
  },
}
