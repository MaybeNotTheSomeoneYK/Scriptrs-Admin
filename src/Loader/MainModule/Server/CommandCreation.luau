local api = _G.ScriptrsAdminMain
local commands = api.commands
local cmdfolder = Instance.new("Folder",game.TextChatService)
cmdfolder.Name = "SAChatCommands"
local function translate(val:string,typ,p)
	if val==nil then return end
	if typ == "Player" then
		if val:lower() == "all" then
			return "all"
		elseif val:lower() == "me" then
			return p
		elseif val:lower() == "random" then
			return game.Players:GetPlayers()[math.random(1,#game.Players:GetPlayers())]
		end
		for _,i in game.Players:GetPlayers() do
			if val:sub(1,1)=="@" and i.Name==val:gsub("@","") then
				return i
			elseif i.Name:sub(1,string.len(val)):lower()==val:lower() or i.UserId==tonumber(val) then
				return i
			end
		end
	elseif typ == "Number" or typ=="UserId" or typ=="Seconds" then
		return tonumber(val)
	else
		return game.TextService:FilterStringAsync(val,p.UserId):GetNonChatStringForBroadcastAsync()
	end
end

for _,v in commands do
	local new = Instance.new("TextChatCommand",cmdfolder)
	new.Name = v.Name
	new.PrimaryAlias = api.settings.Prefix..v.Name
	new.SecondaryAlias = api.settings.Prefix.."un"..v.Name
	new.Triggered:Connect(function(p,t)
		local splitted = t:split(" ")
		local doloop = {false,0}
		local args = (function()local t=table.clone(splitted)table.remove(t,1)return t end)()
		for _i,_v in v.Args do
			args[_i]=translate(args[_i],_v,game.Players:GetPlayerByUserId(p.UserId))
			if args[_i]=="all" and _v=="Player" then
				doloop={true,_i}
			end
			if args[_i]==nil and _v=="Player" then
				args[_i]=game.Players:GetPlayerByUserId(p.UserId)
			end
			if _v == "Text" then
				args[_i] = game.TextService:FilterStringAsync(table.concat(args," ",_i),p.UserId):GetNonChatStringForBroadcastAsync()
			end
		end
		
		if v.NoStudio then
			if game.RunService:IsStudio() then
				return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
					3,
					api.settings.CoreName,
					"NoStudio is enabled on this command, unable to run this command in test servers"
				)
			end
		end
		if api.serveradmins[p.UserId] < tonumber(v.Rank) then
			return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
				3,
				api.settings.CoreName,
				"Your rank priority is too low to use this command"
			)
		end
		if doloop[1] then
			for _,c in game.Players:GetPlayers() do
				local clonedargs = table.clone(args)
				clonedargs[doloop[2]]=c
				if v.RankLock then
					local index = doloop[2]
					if index then
						if api.serveradmins[clonedargs[index].UserId]>=api.serveradmins[p.UserId] then
							api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
								3,
								api.settings.CoreName,
								"RankLock is enabled on this command, unable to run this command on someone whoes rank is higher or equal to yours"
							)
						end
					end
				end
				if v.ExcludeCreator then
					local index = doloop[2]
					if index then
						if api.getOwner().UserId == clonedargs[index].UserId then
							return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
								3,
								api.settings.CoreName,
								"ExcludeCreator is enabled on this command, unable to run this command on the game owner"
							)
						end
					end
				end
				local s,success,result = pcall(v.Func,v,splitted[1]:sub(2,3)=="un",game.Players:GetPlayerByUserId(p.UserId),clonedargs)
				if success==true then
					api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
						1,
						api.settings.CoreName,
						result
					)
				elseif success==false then
					api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
						2,
						api.settings.CoreName,
						result
					)
				elseif s==false then
					warn("[SA ERROR CATCHED]",success)
					api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
						2,
						api.settings.CoreName,
						"An unexpected error happend in the command's function, check the developer console for more"
					)
				end
			end
		else
			if v.RankLock then
				local index = table.find(v.Args,"Player")
				if index then
					if api.serveradmins[args[index].UserId]>=api.serveradmins[p.UserId] then
						return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
							3,
							api.settings.CoreName,
							"RankLock is enabled on this command, unable to run this command on someone whoes rank is higher or equal to yours"
						)
					end
				end
			end
			if v.ExcludeCreator then
				local index = table.find(v.Args,"Player")
				if index then
					if api.getOwner().UserId == args[index].UserId then
						return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
							3,
							api.settings.CoreName,
							"ExcludeCreator is enabled on this command, unable to run this command on the game owner"
						)
					end
				end
			end
			local s,success,result = pcall(v.Func,v,splitted[1]:sub(2,3)=="un",game.Players:GetPlayerByUserId(p.UserId),args)
			if success==true then
				return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
					1,
					api.settings.CoreName,
					result
				)
			elseif success==false then
				return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
					2,
					api.settings.CoreName,
					result
				)
			elseif s==false then
				warn("[SA ERROR CATCHED]",success)
				return api.shared.SARemotes.NotifyClient:FireClient(game.Players:GetPlayerByUserId(p.UserId),
					2,
					api.settings.CoreName,
					"An unexpected error happend in the command's function, check the developer console for more"
				)
			end
		end
	end)
end

return true