local api = _G.ScriptrsAdminMain
local con = {}

return {
	help = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 0;
		Args = {};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			local retmsg = "\n<i><b>All the commands for "..api.settings.CoreName..":</b></i>\n\n"
			for _,v in api.commands do
				retmsg = retmsg..`<font weight="Regular">{v.Rank} | ;{v.Name} {(if #v.Args>0 then "&lt;" else "")..table.concat(v.Args," / ")..(if #v.Args>0 then "&gt;" else "")}</font>\n`
			end
			api.shared.SARemotes.SendSystemChat:FireClient(exec,retmsg)
		end,
	};
	cmds = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 0;
		Args = {};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			local retmsg = "\n<i><b>All the commands for "..api.settings.CoreName..":</b></i>\n\n"
			for _,v in api.commands do
				retmsg = retmsg..`<font weight="Regular">{v.Rank} | ;{v.Name} {(if #v.Args>0 then "&lt;" else "")..table.concat(v.Args," / ")..(if #v.Args>0 then "&gt;" else "")}</font>\n`
			end
			api.shared.SARemotes.SendSystemChat:FireClient(exec,retmsg)
		end,
	};
	whois = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 0;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			api.shared.SARemotes.SendSystemChat:FireClient(exec,`\n{args[1].Name}:\n<font weight="Regular">Rank: <b>{api.serveradmins[args[1].UserId]}</b>\nIsOwner: <b>{args[1].UserId == api.getOwner().UserId}</b></font>\n`)
		end,
	};
	ranks = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 0;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			local s = "\nServer Ranks:\n"
			for i,v in api.serveradmins do
				s=s..`<font weight="Regular">{game.Players:GetPlayerByUserId(i)}</font> | <font weight="Regular">{v} / {require(api.server.SAModules.GetRankInfo)(v)[2]}</font>\n`
			end
			api.shared.SARemotes.SendSystemChat:FireClient(exec,s)
		end,
	};
	m = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 1;
		Args = {"Text"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			api.shared.SARemotes.AnnounceClient:FireAllClients(`{exec.DisplayName} (@{exec.Name})\n[ {api.serveradmins[exec.UserId]} / {require(api.server.SAModules.GetRankInfo)(api.serveradmins[exec.UserId])[2]} ]\n\n{args[1]}`)
		end,
	};
	h = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 1;
		Args = {"Text"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			api.shared.SARemotes.HintClient:FireAllClients(`{exec.DisplayName} (@{exec.Name}): {args[1]}`)
		end,
	};
	heal = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 1;
		Args = {"Player","Number"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not args[1].Character:IsDescendantOf(game) then return false, "Target's Character isnt visible to server, are they using fakechar?, or are they stuck in a limbo of loading character?" end
			if not args[1].Character:FindFirstChildOfClass("Humanoid") then return false, "Interesting... the target doesnt have humanoid" end
			args[1].Character:FindFirstChildOfClass("Humanoid").Health+=args[2]
		end,
	};
	re = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 1;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			local pivot
			if args[1].Character:IsDescendantOf(game) then pivot=args[1].Character:GetPivot()end
			args[1]:LoadCharacterAsync()
			if pivot then args[1].Character:PivotTo(pivot) end
		end,
	};
	mute = {
		RankLock = true;
		ExcludeCreator = true;
		NoStudio = false;
		Rank = 2;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			api.server.EditClientInsProp:FireClient(args[1],"TextChatService.ChatInputBarConfiguration","Enabled",undo)
		end,
	};
	kick = {
		RankLock = true;
		ExcludeCreator = true;
		NoStudio = false;
		Rank = 2;
		Args = {"Player","Text"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			args[1]:Kick(args[2])
		end,
	};
	freeze = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 2;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not args[1].Character:IsDescendantOf(game) then return false, "Target's Character isnt visible to server, are they using fakechar?, or are they stuck in a limbo of loading character?" end
			args[1].Character:WaitForChild("HumanoidRootPart").Anchored = not undo
		end,
	};
	bring = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 2;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not args[1].Character:IsDescendantOf(game) then return false, "Target's Character isnt visible to server, are they using fakechar?, or are they stuck in a limbo of loading character?" end
			if not exec.Character:IsDescendantOf(game) then return false, "Your Character isnt visible to server, are you using fakechar?, or are you stuck in a limbo of loading character?" end
			args[1].Character:PivotTo(exec.Character:GetPivot())
		end,
	};
	to = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 2;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not args[1].Character:IsDescendantOf(game) then return false, "Target's Character isnt visible to server, are they using fakechar?, or are they stuck in a limbo of loading character?" end
			if not exec.Character:IsDescendantOf(game) then return false, "Your Character isnt visible to server, are you using fakechar?, or are you stuck in a limbo of loading character?" end
			exec.Character:PivotTo(args[1].Character:GetPivot())
		end,
	};
	ban = {
		RankLock = true;
		ExcludeCreator = true;
		NoStudio = false;
		Rank = 3;
		Args = {"UserId","Reason","Seconds"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not ({pcall(function()game.Players:GetNameFromUserIdAsync(args[1])end)})[1] then return false, "Invalid UserId" end
			if not undo then
				game.Players:BanAsync({
					UserIds = {args[1]};
					Duration = args[3] or -1;
					DisplayReason = args[2] or "Reason unprovided";
					PrivateReason = "Banned by "..exec.Name;
					ApplyToUniverse = true
				})
			else
				game.Players:UnbanAsync({UserIds={args[1]},ApplyToUniverse=true})
			end
		end,
	};
	gear = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 3;
		Args = {"Player","Number"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			local _,gear = pcall(function()return game.MarketplaceService:GetProductInfoAsync(args[2])end)
			if gear and gear.AssetTypeId == 19 then
				local tool = game.AssetService:LoadAssetAsync(args[2])
				if tool:FindFirstChildOfClass("Tool") then
					tool:FindFirstChildOfClass("Tool").Parent = args[1].Backpack
				end
				tool:Destroy()
			else
				return false, "The provided ID is whether NOT a valid gear or a privated asset"
			end
		end,
	};
	btools = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 3;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			local tool = script:WaitForChild("Building Tools"):Clone()
			tool.Parent = args[1].Backpack
		end,
	};
	serverlock = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 3;
		Args = {};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not undo then
				if con[self.Name] then return end
				con[self.Name] = game.Players.PlayerAdded:Connect(function(a)
					if not(a.UserId == api.getOwner().UserId) then
						a:Kick("This server is locked for all new joiners")
					end
				end)
			else
				if con[self.Name] then
					con[self.Name]:Disconnect()
					con[self.Name] = nil
				end
			end
		end,
	};
	view = {
		RankLock = false;
		ExcludeCreator = false;
		NoStudio = false;
		Rank = 3;
		Args = {"Player"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			if not args[1].Character:IsDescendantOf(game) then return false, "Target's Character isnt visible to server, are they using fakechar?, or are they stuck in a limbo of loading character?" end
			if undo then
				api.server.EditClientInsProp:FireClient(exec,"Workspace.Camera","CameraSubject",args[1].Character)
			else
				api.server.EditClientInsProp:FireClient(exec,"Workspace.Camera","CameraSubject",exec.Character)
			end
		end,
	};
	rank = {
		RankLock = true;
		ExcludeCreator = true;
		NoStudio = false;
		Rank = 4;
		Args = {"Player","Number"};
		Func = function(self:{any}, undo: boolean, exec: Player, args: {any})
			api.serveradmins[args[1].UserId]=math.clamp(args[2],api.settings.ranks[#api.settings.ranks][1],api.serveradmins[exec.UserId]-1)
			if undo then
				api.serveradmins[args[1].UserId] = api.settings.DefaultPlayerRank
			end
		end,
	};
	shutdown = {
		Rank = 5;
		Args = {};
		Func = function(_,_,exec,_)
			Instance.new("Message",workspace.Terrain).Text = `{exec} is shutting down the server..."`
			wait(3)
			game.Players:ClearAllChildren()
		end,
	}
}
