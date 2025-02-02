return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- This shows all files, including those beginning with a dot
        hide_dotfiles = false,
        hide_gitignored = true, -- Still hide files in .gitignore
        hide_by_name = {
          ".DS_Store",
          "node_modules",
        },
        never_show = {
          ".cache",
          ".git",
          ".hg",
          ".svn",
          "node_modules",
          ".DS_Store",
          "thumbs.db",
        },
      },
    },
  },
}
