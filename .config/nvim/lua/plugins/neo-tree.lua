return {
  "nvim-neo-tree/neo-tree.nvim",
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
