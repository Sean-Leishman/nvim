local leet_arg = "leetcode"

-- Pull LEETCODE_SESSION/csrftoken straight out of the browser's cookie DB.
-- LEETCODE_SESSION is httpOnly, so there is no link-based login to hook into --
-- reading the store after a normal browser sign-in is the only way to skip the
-- manual DevTools copy-paste.
-- ponytail: Firefox/Zen only. Chrome encrypts its cookie DB (kwallet/gnome-keyring);
-- add a decrypt path only if you switch browsers.
local cookie_db = "~/.var/app/app.zen_browser.zen/.zen/*/cookies.sqlite"

local extract = [[
import glob, shutil, sqlite3, sys, tempfile, os
db = next(iter(glob.glob(os.path.expanduser("%s"))), None)
if not db: sys.exit("cookie DB not found")
tmp = tempfile.mktemp(suffix=".sqlite")   # copy first: the browser holds a lock
shutil.copy(db, tmp)
rows = dict(sqlite3.connect(tmp).execute(
    "select name, value from moz_cookies where host like '%%leetcode.com'"
    " and name in ('LEETCODE_SESSION','csrftoken')"))
os.unlink(tmp)
if len(rows) < 2: sys.exit("not signed in")
print("LEETCODE_SESSION=%%s; csrftoken=%%s" %% (rows["LEETCODE_SESSION"], rows["csrftoken"]))
]]

local function sync_cookie()
	local out = vim.fn.system({ "python3", "-c", extract:format(cookie_db) })

	if vim.v.shell_error ~= 0 then
		vim.notify("Sign in to leetcode.com in your browser, then :LeetLogin again", vim.log.levels.WARN)
		vim.fn.jobstart({ "xdg-open", "https://leetcode.com/accounts/login/" }, { detach = true })
		return
	end

	-- the plugin only inits storage paths on VimEnter; do it now if we beat it there
	local lc_config = require("leetcode.config")
	if not lc_config.storage.cache then
		lc_config.setup()
	end

	local err = require("leetcode.cache.cookie").set(vim.trim(out))
	if err then
		vim.notify("leetcode: " .. err, vim.log.levels.ERROR)
	else
		vim.notify("leetcode: signed in")
		-- refreshes the dashboard; no-op if the menu isn't mounted yet
		pcall(require("leetcode.command").start_user_session)
	end
end

return {
	{
		"kawre/leetcode.nvim",
		-- ponytail: no `build = ":TSUpdate html"` -- html is already in treesitter's ensure_installed
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		-- loads eagerly when started as `nvim leetcode`, on the commands otherwise
		lazy = leet_arg ~= vim.fn.argv()[1],
		cmd = { "Leet", "LeetLogin" },
		opts = {
			arg = leet_arg,
			-- cpp solutions auto-get `#include <bits/stdc++.h>` + `using namespace std;`
			-- (leetcode.nvim's default cpp imports), so each file is self-contained and
			-- clangd resolves everything. std + format style live in compile_flags.txt
			-- and .clang-format in the storage dir; no compile_commands.json needed.
			lang = "cpp",
		},
		config = function(_, opts)
			require("leetcode").setup(opts)
			vim.api.nvim_create_user_command("LeetLogin", sync_cookie, {
				desc = "Sign in to leetcode.nvim using the browser's cookie",
			})
		end,
	},
}
