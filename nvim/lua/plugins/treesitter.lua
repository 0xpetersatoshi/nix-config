return {
  -- Parser installation (nvim-treesitter main branch, simplified scope)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install {
        "bash",
        "c",
        "css",
        "csv",
        "diff",
        "dockerfile",
        "fish",
        "git_config",
        "gitattributes",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "gotmpl",
        "graphql",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "kdl",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "ninja",
        "nix",
        "printf",
        "prisma",
        "proto",
        "python",
        "query",
        "rasi",
        "regex",
        "ron",
        "rst",
        "rust",
        "solidity",
        "sql",
        "terraform",
        "tmux",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      -- Filetypes where Neovim 0.12 already enables treesitter via built-in ftplugin
      local native_ts_filetypes = { lua = true, markdown = true, help = true, query = true, vimdoc = true }

      -- Enable native treesitter highlighting and indentation for all other filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if native_ts_filetypes[vim.bo[args.buf].filetype] then
            -- Only set indentexpr; highlighting is already started by Neovim's ftplugin
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            return
          end
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Ruby: use vim regex highlighting alongside treesitter, skip treesitter indent
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function(args)
          vim.bo[args.buf].indentexpr = ""
        end,
      })
    end,
  },

  -- Textobject navigation
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local move = require "nvim-treesitter-textobjects.move"

      local goto_mappings = {
        ["]f"] = { query = "@function.outer", desc = "Next function start" },
        ["]F"] = { query = "@function.outer", desc = "Next function end", goto_end = true },
        ["]c"] = { query = "@class.outer", desc = "Next class start" },
        ["]C"] = { query = "@class.outer", desc = "Next class end", goto_end = true },
        ["]a"] = { query = "@parameter.inner", desc = "Next parameter" },
        ["]A"] = { query = "@parameter.inner", desc = "Next parameter end", goto_end = true },
        ["[f"] = { query = "@function.outer", desc = "Prev function start", prev = true },
        ["[F"] = { query = "@function.outer", desc = "Prev function end", prev = true, goto_end = true },
        ["[c"] = { query = "@class.outer", desc = "Prev class start", prev = true },
        ["[C"] = { query = "@class.outer", desc = "Prev class end", prev = true, goto_end = true },
        ["[a"] = { query = "@parameter.inner", desc = "Prev parameter", prev = true },
        ["[A"] = { query = "@parameter.inner", desc = "Prev parameter end", prev = true, goto_end = true },
      }

      for key, mapping in pairs(goto_mappings) do
        local fn
        if mapping.prev and mapping.goto_end then
          fn = function()
            move.goto_previous_end(mapping.query, "textobjects")
          end
        elseif mapping.prev then
          fn = function()
            move.goto_previous_start(mapping.query, "textobjects")
          end
        elseif mapping.goto_end then
          fn = function()
            move.goto_next_end(mapping.query, "textobjects")
          end
        else
          fn = function()
            move.goto_next_start(mapping.query, "textobjects")
          end
        end

        vim.keymap.set({ "n", "x", "o" }, key, fn, { desc = mapping.desc })
      end
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },
}
