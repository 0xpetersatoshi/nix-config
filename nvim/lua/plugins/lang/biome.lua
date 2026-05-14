return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        biome = {
          cmd = { "biome", "lsp-proxy" },
          filetypes = {
            "astro",
            "css",
            "graphql",
            "html",
            "javascript",
            "javascriptreact",
            "json",
            "jsonc",
            "svelte",
            "typescript",
            "typescriptreact",
            "vue",
          },
          workspace_required = true,
          root_markers = {
            "biome.json",
            "biome.jsonc",
            "package.json",
            "package-lock.json",
            "yarn.lock",
            "pnpm-lock.yaml",
            "bun.lockb",
            "bun.lock",
            "deno.lock",
            ".git",
          },
        },
      },
    },
  },
}
