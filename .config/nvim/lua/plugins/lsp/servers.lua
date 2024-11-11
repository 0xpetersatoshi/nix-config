local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

return {
  -- jsonls = {
  --   settings = {
  --     json = {
  --       schema = require("schemastore").json.schemas(),
  --       validate = { enable = true },
  --     },
  --   },
  -- },
  terraformls = {
    cmd = { "terraform-ls" },
    arg = { "server" },
    filetypes = { "terraform", "tf", "terraform-vars" },
  },
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
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  bashls = {
    filetypes = { "sh", "zsh" },
  },
  vimls = {
    filetypes = { "vim" },
  },
  tsserver = {},
  gopls = {},
  pyright = {
    before_init = function(_, config)
      local venv = vim.fn.trim(vim.fn.system("poetry env info --path"))
      if vim.v.shell_error == 0 then
        config.settings.python.pythonPath = venv .. "/bin/python"
      else
        print("Poetry environment not found. Using system Python.")
      end
    end,
    root_dir = function(fname)
      return util.root_pattern("pyproject.toml")(fname) or util.find_git_ancestor(fname)
    end,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
        },
      },
    },
  },

  solidity = {
    cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
    filetypes = { "solidity" },
    root_dir = lspconfig.util.find_git_ancestor,
    single_file_support = true,
  },
  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
  },
  taplo = {},
  sqls = {},
}
