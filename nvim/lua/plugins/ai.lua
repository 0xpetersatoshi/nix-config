return {
  -- codeium
  {
    "Exafunction/codeium.vim",
    enabled = false,
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
    enabled = false,
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
  {
    "yetone/avante.nvim",
    enabled = true,
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      -- add any opts here
      -- for example
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-latest",
        api_key_name = "cmd:op read 'op://Private/anthropic-api-keys/avante' --no-newline",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 8000,
      },

      web_search_engine = {
        provider = "tavily",
        providers = {
          tavily = {
            api_key_name = "cmd:op read 'op://Private/tavily-api-keys/avante' --no-newline",
            extra_request_body = {
              include_answer = "basic",
            },
            ---@type WebSearchEngineProviderResponseBodyFormatter
            format_response_body = function(body)
              return body.answer, nil
            end,
          },
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "saghen/blink.cmp",
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    config = function()
      -- Configure blink.cmp for avante.nvim
      require("blink.cmp").setup({
        compat = {
          "avante_commands",
          "avante_mentions",
          "avante_files",
        },
        providers = {
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      })

      -- Set file selector to something other than native (e.g., fzf)
      require("avante").setup({
        file_selector = {
          provider = "fzf", -- or "telescope", "mini.pick", etc.
          provider_opts = {},
        },
      })
    end,
  },
}
