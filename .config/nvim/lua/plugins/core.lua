return {
  -- add LazyVim and import its plugins
  {
    "LazyVim/LazyVim",
    import = "lazyvim.plugins",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
  { import = "lazyvim.plugins.extras.coding.copilot" },
}
