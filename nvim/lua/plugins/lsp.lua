return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "saghen/blink.cmp", lazy = false }, -- Force load before lspconfig
      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },
    },
    event = { "BufReadPre", "BufNewFile" },
    ---@class PluginLspOpts
    opts = {
      ---@type table<string, lspconfig.Config>
      servers = {
        bashls = {
          filetypes = { "bash", "sh", "zsh" },
        },

        clangd = {},

        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              completeUnimported = true,
              gofumpt = true,
              staticcheck = true,
            },
          },
        },

        graphql = {
          filetypes = { "graphql", "gql", "graphqls", "typescriptreact" },
        },

        jsonls = {},

        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  "${3rd}/luv/library",
                  unpack(vim.api.nvim_get_runtime_file("", true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              completion = {
                callSnippet = "Replace",
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },

        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }",
              },
              formatting = {
                command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
              },
            },
          },
        },

        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                ignore = { "*" },
              },
            },
          },
        },

        ruff = {},

        solidity_ls_nomicfoundation = {},

        sqls = {},

        taplo = {},

        terraformls = {},

        ts_ls = {},

        vimls = {},

        yamlls = {
          filetypes = { "yaml", "yml" },
        },
      },
    },
    config = function(_, opts)
      local blink_cmp = require("blink.cmp")

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- Find references for the word under your cursor.
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
          then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, blink_cmp.get_lsp_capabilities(capabilities))

      for server, config in pairs(opts.servers) do
        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (for example, turning off formatting for ts_ls)
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})

        -- Check if the server exists in lspconfig
        local lsp_server = require("lspconfig")[server]
        if not lsp_server then
          vim.notify(
            "LSP server '"
              .. server
              .. "' not found in lspconfig. "
              .. "Check if the server name is correct and the corresponding LSP is installed.",
            vim.log.levels.ERROR
          )
        else
          -- Safely setup the server with error handling
          local ok, err = pcall(function()
            lsp_server.setup(config)
          end)

          if not ok then
            vim.notify("Failed to setup LSP server '" .. server .. "': " .. tostring(err), vim.log.levels.ERROR)
            -- else
            -- vim.notify("Successfully configured LSP server: " .. server, vim.log.levels.INFO)
          end
        end
      end

      -- -- Create a function to safely get capabilities with retries
      -- local function get_capabilities(base_capabilities)
      --   -- Try to load blink.cmp with retries
      --   local max_retries = 3
      --   local retry_delay_ms = 100
      --   local blink_cmp = nil
      --
      --   for attempt = 1, max_retries do
      --     local ok, result = pcall(require, "blink.cmp")
      --     if ok and result then
      --       blink_cmp = result
      --       break
      --     end
      --
      --     -- If not successful and we have more retries, wait a bit
      --     if attempt < max_retries then
      --       vim.defer_fn(function() end, retry_delay_ms)
      --       retry_delay_ms = retry_delay_ms * 2 -- Exponential backoff
      --     else
      --       vim.notify("Failed to load blink.cmp after " .. max_retries .. " attempts", vim.log.levels.WARN)
      --       -- Return default capabilities if blink.cmp fails to load
      --       return vim.lsp.protocol.make_client_capabilities()
      --     end
      --   end
      --   -- Now safely get capabilities
      --   if blink_cmp and blink_cmp.get_lsp_capabilities then
      --     local ok, capabilities = pcall(blink_cmp.get_lsp_capabilities, base_capabilities)
      --     if ok then
      --       return capabilities
      --     else
      --       vim.notify("Error getting LSP capabilities: " .. tostring(capabilities), vim.log.levels.ERROR)
      --       return vim.lsp.protocol.make_client_capabilities()
      --     end
      --   else
      --     return vim.lsp.protocol.make_client_capabilities()
      --   end
      -- end
      --
      -- -- Setup each server with proper error handling
      -- for server, config in pairs(opts.servers) do
      --   -- Get capabilities safely
      --   config.capabilities = get_capabilities(config.capabilities)
      --
      --   -- Setup server with error handling
      --   local ok, err = pcall(function()
      --     lspconfig[server].setup(config)
      --   end)
      --
      --   if not ok then
      --     vim.notify("Failed to setup " .. server .. ": " .. tostring(err), vim.log.levels.ERROR)
      --   end
      -- end

      vim.diagnostic.config({
        title = false,
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          source = true,
          style = "minimal",
          border = "rounded",
          header = "",
          prefix = "",
        },
      })

      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
  },
  -- TODO: make this work
  { "cordx56/rustowl", dependencies = { "neovim/nvim-lspconfig" } },
}
