return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  opts = {
    keymap = {
      builtin = {
        true,
        -- Half-page scrolling
        ["<C-u>"] = "preview-page-up",
        ["<C-d>"] = "preview-page-down",
        -- Single-line scrolling
        ["<C-y>"] = "preview-up",
        ["<C-e>"] = "preview-down",
      },
    },
  },
}
