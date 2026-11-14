local api = _G.ScriptrsAdminMain
local remotes = api.shared.SARemotes

local actions = {
	GetOwner = api.getOwner,
	RequestPlayerData = function(p)
		return {
			global = table.clone(require(api.server.SAModules.DataStore).Get(false,p)),
			["local"] = api.serveradmins[p.UserId]
		}
	end,
}

for _,i in remotes:GetChildren() do
	if i:IsA("RemoteEvent") and actions[i.Name] then
		i.OnServerEvent:Connect(function(...)actions[i.Name](...)end)
	elseif i:IsA("RemoteFunction") and actions[i.Name] then
		i.OnServerInvoke = (function(...)actions[i.Name](...)end)
	end
end

return true