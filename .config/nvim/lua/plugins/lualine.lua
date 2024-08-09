return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Ensure the default configuration is preserved
    opts.sections.lualine_x = opts.sections.lualine_x or {}

    -- Append your custom component
    table.insert(opts.sections.lualine_x, {
      "encoding",
      "fileformat",
      "filetype",
    })
  end,
}
