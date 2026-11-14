-- In the time im writing this im not in a good mood rn, so expect the instructions to be dry
local api = _G.ScriptrsAdminMain -- This lets you access the admin systems APIs and variables

return {
	-- Firstly, this is the command name, you could try to change the "test1" to something else
	["test1"] = {
		-- Secondary, this is the configuration, changes how it behave and do logics
		RankLock = false; -- Blocks admins from using the command on higher rankers, for example MoreAccess cant do ;fire on Administrator
		ExcludeCreator = false; -- This blocks admin from using the command on the games owner specifically
		NoStudio = true; -- Makes the command unusable in Test Mode in Roblox Studio
		Rank = 0; -- This decides what rank can use this command, anyone above or equal to this rankId will able to use the command
		Args = {"Player"}; -- This lets you choose the args name, some names like Player will automactically changes that argument to a specific type, read more at the github page:
		--- Github page: put link here theres no repo for it yet
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			-- self: This is the command itself, you can do self.Name
			--- now if youre a nerd like me, the .Name index is assigned by the inner system automactically
			-- undo: This tells you whether the executor did ;un commands or not
			--- for example: ;untest
			-- exec: its YOU, the executor
			-- args: shorten from "arguments", pretty much self explainatory
			if not undo then
				print(exec.Name,"executed ;"..self.Name.." with this args",args[1],"which is a",self.Args[1])
			else
				print(exec.Name,"reversed ;"..self.Name.." with this args",args[1],"which is a",self.Args[1])
			end
			print("the corename is",api.settings.CoreName)
			return true, "tested, its pretty much working trust me lol"
		end,
		-- Additionally you can do "return boolean,message" to send a notice whether the command worked or not
	};
}
