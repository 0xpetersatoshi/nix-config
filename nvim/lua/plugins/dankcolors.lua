return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#24283b',
				base01 = '#16161e',
				base02 = '#16161e',
				base03 = '#7e8d90',
				base0B = '#ffef1b',
				base04 = '#d2e5e9',
				base05 = '#f4fdff',
				base06 = '#f4fdff',
				base07 = '#f4fdff',
				base08 = '#ff6398',
				base09 = '#ff6398',
				base0A = '#4bdaf4',
				base0C = '#a1f1ff',
				base0D = '#4bdaf4',
				base0E = '#6ee9ff',
				base0F = '#6ee9ff',
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
