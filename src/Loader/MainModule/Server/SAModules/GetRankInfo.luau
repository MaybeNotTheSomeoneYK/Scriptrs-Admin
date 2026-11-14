local api = _G.ScriptrsAdminMain
return function(n)
	for _,i in api.settings.ranks do
		if i[1] == n then return i end
	end
end