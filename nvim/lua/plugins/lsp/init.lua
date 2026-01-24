---@class LspServerConfig
---@field settings? table
---@field keys? {[1]: string, [2]: string|function, desc?: string}[]
---@field cmd? string[]
---@field root_markers? string[]

---@class LspOpts
---@field diagnostics? { underline?: boolean, virtual_text?: { spacing?: number } }
---@field inlay_hints? { enabled?: boolean }
---@field servers table<string, LspServerConfig|false>

return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    opts = function()
      ---@class LspOpts
      local ret = {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
            -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
            -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
            -- prefix = "icons",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = config.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = config.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = config.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = config.icons.diagnostics.Info,
            },
          },
        },
        -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the inlay hints.
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the code lenses.
        codelens = {
          enabled = false,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the LazyVim formatter,
        -- but can be also overridden when specified
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        -- LSP Server Settings
        ---@type LspServerConfig[]
        servers = {
          lua_ls = {
            -- mason = false, -- set to false if you don't want this server to be installed with mason
            -- Use this to add any additional keymaps
            -- for specific lsp servers
            -- ---@type LazyKeysSpec[]
            -- keys = {},
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:LspServerConfig):boolean?>
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
        },
      }
      return ret
    end,

    ---@param opts LspOpts
    config = function(_, opts)
      -- setup autoformat
      util.format.register(util.lsp.formatter())

      -- setup keymaps
      util.lsp.on_attach(function(client, buffer)
        require("plugins.lsp.keymaps").on_attach(client, buffer)
      end)

      util.lsp.setup()
      util.lsp.on_dynamic_capability(require("plugins.lsp.keymaps").on_attach)

      -- diagnostics signs
      if vim.fn.has "nvim-0.10.0" == 0 then
        if type(opts.diagnostics.signs) ~= "boolean" then
          for severity, icon in pairs(opts.diagnostics.signs.text) do
            local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
            name = "DiagnosticSign" .. name
            vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
          end
        end
      end

      if vim.fn.has "nvim-0.10" == 1 then
        -- inlay hints
        if opts.inlay_hints.enabled then
          util.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
            if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ""
              and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
            then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
          end)
        end

        -- code lens
        if opts.codelens.enabled and vim.lsp.codelens then
          util.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = buffer,
              callback = vim.lsp.codelens.refresh,
            })
          end)
        end
      end

      if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
        opts.diagnostics.virtual_text.prefix = vim.fn.has "nvim-0.10.0" == 0 and "●"
          or function(diagnostic)
            local icons = config.icons.diagnostics
            for d, icon in pairs(icons) do
              if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                return icon
              end
            end
          end
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        has_blink and blink.get_lsp_capabilities() or {},
        opts.capabilities or {}
      )

      -- Apply global config
      vim.lsp.config("*", { root_markers = { ".git" }, capabilities = capabilities })

      -- Apply per-server configs and enable
      local servers_to_enable = {}
      for server, server_opts in pairs(opts.servers) do
        if server ~= "*" and server_opts ~= false then
          if server_opts.enabled ~= false then
            -- Call custom setup function if defined (doesn't prevent default setup unless it returns true)
            if opts.setup[server] then
              if opts.setup[server](server, server_opts) then
                goto continue
              end
            elseif opts.setup["*"] then
              if opts.setup["*"](server, server_opts) then
                goto continue
              end
            end

            vim.lsp.config(server, server_opts)
            table.insert(servers_to_enable, server)
          end
        end
        ::continue::
      end
      vim.lsp.enable(servers_to_enable)

      -- Trigger LSP attach for already-opened buffers (needed for lazy loading)
      -- vim.lsp.enable() only sets up autocmds for future buffers, so we need
      -- to manually trigger attachment for buffers that are already open
      vim.schedule(function()
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
            -- Re-trigger BufReadPost which is what vim.lsp.enable() listens to
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname and bufname ~= "" then
              vim.api.nvim_exec_autocmds("BufReadPost", { buffer = bufnr })
            end
          end
        end
      end)

      if util.lsp.is_enabled "denols" and util.lsp.is_enabled "vtsls" then
        local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
        util.lsp.disable("vtsls", is_deno)
        util.lsp.disable("denols", function(root_dir, config)
          if not is_deno(root_dir) then
            config.settings.deno.enable = false
          end
          return false
        end)
      end
    end,
  },
}
