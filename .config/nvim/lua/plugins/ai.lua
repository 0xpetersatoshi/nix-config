return {
  "Exafunction/codeium.vim",
  event = "BufEnter",
  config = function()
    -- Change '<C-g>' here to any keycode you like.
    vim.keymap.set("i", "kk", function()
      return vim.fn["codeium#Accept"]()
    end, { expr = true, silent = true })
  end,
}
