local M = {}

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require "lazy.core.plugin"
  return Plugin.values(plugin, "opts", false)
end

function M.is_loaded(name)
  local Config = require "lazy.core.config"
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

--- Gets a path to a package in the system PATH.
---@param pkg string The package name or executable
---@param subpath? string Optional subpath within the package
---@param opts? { warn?: boolean } Options for the function
---@return string The full path to the package or executable (i.e. /usr/local/bin/{pkg}/{subpath})
function M.get_pkg_path(pkg, subpath, opts)
  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  subpath = subpath or ""

  -- First, try to find the executable in PATH
  local exec_path = vim.fn.exepath(pkg)

  -- If we found the executable
  if exec_path and exec_path ~= "" then
    -- If a subpath was requested, try to resolve it relative to the executable
    if subpath ~= "" then
      -- Get the directory containing the executable
      local base_dir = vim.fn.fnamemodify(exec_path, ":h")

      -- If the subpath starts with "/", remove it to avoid double slashes
      if subpath:sub(1, 1) == "/" then
        subpath = subpath:sub(2)
      end

      -- Return the base directory plus the subpath
      return base_dir .. "/" .. subpath
    else
      -- Just return the executable path if no subpath was requested
      return exec_path
    end
  end

  -- If we get here, we couldn't find the package
  if opts.warn and not require("lazy.core.config").headless() then
    vim.notify(
      ("Package not found in PATH: **%s**\nPlease ensure it's installed via Nix or your preferred package manager."):format(
        pkg
      ),
      vim.log.levels.WARN
    )
  end

  -- Return empty string if not found
  return ""
end

function M.setup()
  require("util.root").setup()
  require("util.plugin").setup()
end

-- Provides utilities for getting the project root directory
M.root = require "util.root"

-- Provides utilities for lualine
M.lualine = require "util.lualine"

-- Provides lsp related utilities
M.lsp = require "util.lsp"

-- Provides utilities for pickers
M.pick = require "util.pick"

-- Utility for setting up better text objects with which-key
M.mini = require "util.mini"

-- Provides formatting utilities
M.format = require "util.format"

-- Provides completion utilities
M.cmp = require "util.cmp"

return M
