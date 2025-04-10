---@class utils.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

-- Specifications for root detection in order of priority
---@type (string|string[]|function)[]
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Cache for root directories by buffer
---@type table<number, string>
M.cache = {}

-- Detector functions
M.detectors = {}

-- Current working directory detector
function M.detectors.cwd()
  return { vim.uv.cwd() }
end

-- LSP-based root detector
function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end

  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients { bufnr = buf }

  -- Filter out any ignored LSP clients
  local ignore_list = vim.g.root_lsp_ignore or {}
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(ignore_list, client.name)
  end, clients)

  for _, client in pairs(clients) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end

  return vim.tbl_filter(function(path)
    path = M.normalize(path)
    return path and bufpath:find(path, 1, true) == 1 or false
  end, roots)
end

-- Pattern-based root detector
---@param patterns string[]|string
---@param buf number
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()

  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then
        return true
      end
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]

  return pattern and { vim.fs.dirname(pattern) } or {}
end

---@return string|nil
function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

---@return string
function M.cwd()
  return M.realpath(vim.uv.cwd()) or ""
end

---@param path string|nil
---@return string|nil
function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.uv.fs_realpath(path) or path
  return M.normalize(path)
end

---@param path string|nil
---@return string|nil
function M.normalize(path)
  if path == nil then
    return nil
  end
  -- Normalize path separators
  if jit and jit.os == "Windows" then
    path = path:gsub("\\", "/")
  end
  -- Remove trailing slash
  if path:sub(-1) == "/" then
    path = path:sub(1, -2)
  end
  return path
end

-- Resolve a spec to a detector function
---@param spec string|string[]|function
---@return function
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

-- Detect root directories based on specs
---@param opts? { buf?: number, spec?: table, all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type table[]
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }

    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end

    table.sort(roots, function(a, b)
      return #a > #b
    end)

    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end

  return ret
end

-- Set up autocmds to clear cache
function M.setup()
  vim.api.nvim_create_user_command("ShowRoot", function()
    M.info()
  end, { desc = "Show root directories for the current buffer" })

  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("custom_root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
end

-- Display root information
function M.info()
  local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  local roots = M.detect { all = true }
  local lines = {} ---@type string[]
  local first = true

  for _, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(root.spec) == "table" and table.concat(root.spec, ", ") or tostring(root.spec)
      )
      first = false
    end
  end

  lines[#lines + 1] = "```lua"
  lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
  lines[#lines + 1] = "```"

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Root Directories" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

-- Get the root directory
---@param opts? {normalize?:boolean, buf?:number}
---@return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]

  if not ret then
    local roots = M.detect { all = false, buf = buf }
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end

  if opts and opts.normalize then
    return ret
  end

  -- Convert path separators for Windows if needed
  return jit and jit.os == "Windows" and not opts.normalize and ret:gsub("/", "\\") or ret
end

-- Get the git root directory
function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

return M
