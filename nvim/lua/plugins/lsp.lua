return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "mfussenegger/nvim-dap",
      "jay-babu/mason-nvim-dap.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Key mappings
      vim.keymap.set("n", "<leader>cD", vim.lsp.buf.definition, { desc = "Code Definition" })
      vim.keymap.set("n", "<leader>cR", vim.lsp.buf.references, { desc = "Code References" })
      vim.keymap.set("n", "<leader>p", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename Symbol" })

      -- Mason setup
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      -- Setup Mason directly for additional tools (formatters, linters, etc.)
      local registry = require("mason-registry")
      local ensure_installed = {
        "stylua", -- Lua formatter
        "prettierd",
        "codelldb", -- Rust, Zig, C, C++ debugger
        "nomicfoundation-solidity-language-server", -- Solidity LSP
      }

      for _, tool in ipairs(ensure_installed) do
        if not registry.is_installed(tool) then
          vim.cmd("MasonInstall " .. tool)
        end
      end

      -- Load servers configuration
      local servers = require("plugins.lsp.servers")

      -- Mason-lspconfig setup
      require("mason-lspconfig").setup({
        automatic_installation = true,
        -- Filter out servers that shouldn't be installed via Mason
        ensure_installed = vim.tbl_filter(function(server)
          -- Add servers that should be excluded from Mason installation
          local excluded_servers = {
            "nixd",
            -- "graphql",
          }
          return not vim.tbl_contains(excluded_servers, server)
        end, vim.tbl_keys(servers)),
      })

      -- Mason-nvim-dap setup
      require("mason-nvim-dap").setup({
        -- Enable automatic installation
        automatic_installation = true,
        ensure_installed = {
          "js-debug-adapter", -- TODO: this isn't installing automatically
          "debugpy",
        },
      })

      require("lspconfig.ui.windows").default_options.border = "single"

      -- require("neodev").setup()

      -- Setup capabilities
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- LSP attach autocmd
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
          map("gr", require("telescope.builtin").lsp_references, "Goto References")
          map("gi", require("telescope.builtin").lsp_implementations, "Goto Implementation")
          map("go", require("telescope.builtin").lsp_type_definitions, "Type Definition")
          map("<leader>cp", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
          map("<leader>cP", require("telescope.builtin").lsp_workspace_symbols, "Workspace Symbols")
          map("<leader>Ps", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")

          map("gl", vim.diagnostic.open_float, "Open Diagnostic Float")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gs", vim.lsp.buf.signature_help, "Signature Documentation")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")

          map("<leader>v", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", "Goto Definition in Vertical Split")

          -- Document highlight setup
          -- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua#L502
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Server setup
      for server_name, server_settings in pairs(servers) do
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          settings = server_settings.settings,
          filetypes = server_settings.filetypes,
          cmd = server_settings.cmd,
        })
      end

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
