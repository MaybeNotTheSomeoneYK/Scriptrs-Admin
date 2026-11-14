local dsservice = game:GetService("DataStoreService")
local ds
if game.PlaceId < 1 then
	local localds = {}
	ds = {
		GetAsync = function(self,key)
			return localds[key]
		end,
		UpdateAsync = function(self,key,func)
			localds[key] = func(localds[key])
		end,
	}
else
	local s,dss = pcall(function()return dsservice:GetDataStore("SADataStore")end)
	if not s then
		local localds = {}
		ds = {
			GetAsync = function(self,key)
				return localds[key]
			end,
			UpdateAsync = function(self,key,func)
				localds[key] = func(localds[key])
			end,
		}
	else
		ds = dss
	end
end 
local api = _G.ScriptrsAdminMain
local cache = {}
local valid = { -- Key = {Type};
	Name = {typeof"string"};
	Display = {typeof"string"};
	LastActive = {typeof(0)};
	LastServer = {typeof"string"};
}
local function makeNewDataInCaseOfPDataCorruption(p)
	return {
		Name = p.Name;
		Display = p.DisplayName;
		LastActive = os.time();
		LastServer = game.JobId;
	}
end
local function validifyData(qdata,player)
	local data = table.clone(qdata)
	local removelist = {}
	for i,v in data do
		if not valid[i] then
			removelist[i]=true
		end
	end
	for i,_ in removelist do
		data[i] = nil
	end
	local missing = table.clone(valid)
	for i,v in data do
		if valid[i] and typeof(v)==valid[i][1] then
			missing[i]=nil
		end
	end
	for i,_ in missing do
		if i=="Name" then
			data[i] = player.Name
		elseif i=="Display" then
			data[i] = player.DisplayName
		elseif i=="LastActive" then
			data[i] = os.time()
		elseif i=="LastServer" then
			data[i] = game.JobId
		end
	end
	return data
end

return table.freeze({
	Get = function(nocache:boolean,player:Player)
		local data,success
		if nocache or not cache[tostring(player.UserId)] then
			local rsuccess,rdata = pcall(function()return ds:GetAsync(tostring(player.UserId))end)
			success,data=rsuccess,rdata
		elseif cache[tostring(player.UserId)] then
			data = cache[tostring(player.UserId)]
			success = true
		end
		
		if not success then
			return nil
		end
		
		if not (typeof(data)=="table") then
			data = makeNewDataInCaseOfPDataCorruption(player)
		end
		
		data = validifyData(data,player)
		
		cache[tostring(player.UserId)] = data
		
		return data
	end,
	Set = function(player:Player,keys:{string},value:{any})
		local data
		local success = pcall(function()
			ds:UpdateAsync(tostring(player.UserId),function(olddata)
				if not (typeof(olddata)=="table") then
					olddata = makeNewDataInCaseOfPDataCorruption(player)
				end
				
				data = validifyData(olddata,player)
				for index,key in keys do
					if valid[key] and typeof(value[index])==valid[key][1] then
						data[key]=value[index]
					end
				end
				
				return data 
			end)
		end)
		
		if success then 
			cache[tostring(player.UserId)] = data
		end
		
		return success,data
	end,
})