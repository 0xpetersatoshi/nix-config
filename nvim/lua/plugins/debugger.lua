return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local widgets = require("dap.ui.widgets")

      dapui.setup()
      require("dap-go").setup()
      require("nvim-dap-virtual-text").setup({})

      -- dap config
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
      vim.keymap.set("n", "<F8>", dap.step_over, { desc = "DAP Step Over" })
      vim.keymap.set("n", "<F6>", dap.step_into, { desc = "DAP Step Into" })
      vim.keymap.set("n", "<F4>", dap.step_out, { desc = "DAP Step Out" })
      vim.keymap.set("n", "<Leader>ds", dap.close, { desc = "DAP Stop" })
      vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "DAP Repl" })
      vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "DAP Run Last" })
      vim.keymap.set("n", "<Leader>dt", function()
        local filetype = vim.bo.filetype
        if filetype == "go" then
          require("dap-go").debug_test()
        elseif filetype == "python" then
          require("dap-python").test_method()
        -- Add more language-specific handlers as needed
        else
          vim.notify("Test debugging not supported for filetype: " .. filetype, vim.log.levels.WARN)
        end
      end, { desc = "DAP Debug Test" })

      -- breakpoints
      vim.keymap.set("n", "<Leader>dbt", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
      vim.keymap.set("n", "<Leader>dbs", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP Set Conditional Breakpoint" })
      vim.keymap.set("n", "<Leader>dbc", dap.clear_breakpoints, { desc = "DAP Clear Breakpoints" })
      vim.keymap.set("n", "<Leader>dbl", function()
        dap.list_breakpoints(true)
      end, { desc = "DAP List Breakpoints" })

      -- dap-ui
      vim.keymap.set({ "n", "v" }, "<Leader>dh", widgets.hover, { desc = "DAP Hover" })
      vim.keymap.set({ "n", "v" }, "<Leader>dp", widgets.preview, { desc = "DAP Preview" })
      vim.keymap.set("n", "<Leader>duff", function()
        widgets.centered_float(widgets.frames)
      end, { desc = "DAP Frames" })
      vim.keymap.set("n", "<Leader>dufs", function()
        widgets.centered_float(widgets.scopes)
      end, { desc = "DAP Scopes" })
      vim.keymap.set("n", "<Leader>do", dapui.toggle, { desc = "Toggle DAP UI" })
      vim.keymap.set("n", "<Leader>dus", function()
        widgets.sidebar(widgets.scopes).open()
      end, { desc = "DAP Sidebar" })

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- icons
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "DapBreakpointLine", { fg = "#e0cf6c" })
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      -- Point to system debugpy installation
      debugpy = {
        path = vim.fn.exepath("debugpy"), -- This will use debugpy from PATH
      },
    },
  },
}
