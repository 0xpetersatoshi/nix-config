local lspconfig = require("lspconfig")

return {
  jsonls = {},
  terraformls = {},
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
  ts_ls = {},

  gopls = {},

  ruff = {},

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

  nixd = {
    cmd = { "nixd" },
    filetypes = { "nix" },
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

  -- graphql = {
  --   cmd = { "graphql-lsp", "server", "-m", "stream" },
  --   filetypes = { "graphql", "gql", "graphqls", "typescriptreact" },
  -- },

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
