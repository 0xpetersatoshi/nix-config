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
            -- TODO: not working as expected
            -- keymaps = {
            --   send = {
            --     modes = {
            --       n = "<leader>cs", -- Send in normal mode
            --       v = "<leader>cs", -- Send in visual mode
            --       i = { "<C-CR>", "<C-s>" }, -- Send in insert mode
            --     },
            --   },
            --   completion = {
            --     modes = {
            --       i = "<C-x>",
            --     },
            --   },
            --   close = {
            --     modes = {
            --       n = "<leader>cc", -- Close chat window
            --     },
            --   },
            --   new = {
            --     modes = {
            --       n = "<leader>cn", -- Start new chat
            --     },
            --   },
            -- },
          },
          inline = {
            adapter = "anthropic",
          },
          cmd = {
            adapter = "anthropic",
          },
        },
      })
    end,
  },
}
