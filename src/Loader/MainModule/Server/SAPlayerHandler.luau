local api = _G.ScriptrsAdminMain

local con = {}

game.Players.PlayerAdded:Connect(function(p)
	local systemrank
	for _,i in api.settings.ranks do
		if p.UserId == api:getOwner().UserId then systemrank = api.settings.DefaultOwnerRank break end
		if systemrank then break end
		for _,v in i[3] do
			if systemrank then break end
			if (if typeof(v)=="string" then v:lower()==p.Name:lower() elseif typeof(v)=="number" then math.floor(v)==p.UserId else false) then
				systemrank = i[1] 
				break
			end
		end
	end
	
	if not systemrank then
		for i,v in api.settings.GroupRanks do
			if p:IsInGroupAsync(i) then
				for q,e in v do
					if p:GetRankInGroupAsync(i)==q then
						systemrank = e
						break
					end
				end
			end
		end
	end
	
	if not systemrank then
		if p.UserId == game.PrivateServerOwnerId then
			systemrank = api.settings.DefaultPSOwnerRank
		elseif p:IsFriendsWithAsync(api.getOwner().UserId) then
			systemrank = api.settings.DefaultFriendsRank
		else
			systemrank = api.settings.DefaultPlayerRank
		end
	end
	
	if not api.serveradmins[p.UserId] then
		api.serveradmins[p.UserId] = systemrank
	end
	
	if api.serveradmins[p.UserId] < systemrank then
		api.serveradmins[p.UserId] = systemrank
	end
	
	local last = api.serveradmins[p.UserId]
	con[p]=task.spawn(function()
		while true do
			if not (api.serveradmins[p.UserId]==last) then
				api.server.SABindables.RankChanged:Fire(p,api.serveradmins[p.UserId])
			end
			last = api.serveradmins[p.UserId]
			task.wait()
		end
	end)
	
	require(api.server.SAModules.DataStore).Set(p,{"LastServer","LastActive"},{game.JobId,os.time()})
end)

game.Players.PlayerRemoving:Connect(function(p)
	require(api.server.SAModules.DataStore).Set(p,{"LastServer","LastActive"},{game.JobId,os.time()})
	if not con[p] then return end
	task.cancel(con[p])
	con[p]=nil
end)

game:BindToClose(function()
	for _,i in game.Players:GetPlayers() do
		api.serveradmins[i.UserId] = nil
	end
end)

return true