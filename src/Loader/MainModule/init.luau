local defaultsettings = {
	--// Hi there! Thank you for using our admin system. Lets not waste time and let me introduce you to the settings!

	--// First thing first this is where you add your fellow friends and family as your admins!
	ranks = {
		--// To add a new rank, simply copy the "Player" rank and paste it at the end of the "ranks" list.
		--// Here, let me explain how these little guys works
		--// So to add admins you have to put your fellow friends username OR userid into the table part after rank name
		{5,	"Owner",				{"",0}	},
		{4,	"HeadAdministration",	{"",0}	},
		{3,	"Administrator",		{"",0}	},
		{2,	"Moderator",			{"",0}	},
		{1,	"MoreAccess",			{"",0}	},
		{0,	"Player",				{"",0}	},
	};

	--// Second, this is the default ranks configuration, just for the love of god sake please use the rankid and ill be very happy
	DefaultOwnerRank = 5;
	DefaultPlayerRank = 0;
	DefaultFriendsRank = 1;
	DefaultPSOwnerRank = 2;

	--// Third, this is the group ranks section, just type your group id and ur role id and let the magic happens!
	GroupRanks = {
		[0] = {
			[255] = 5;
		};
	};

	--// Forth, this is the system configuration, to changes how ScriptrsAdmin behave!
	CoreName = "Scriptr's Admin";
	Theme = Color3.fromRGB(0, 115, 255);
	Prefix = ";";
}
local places = {
	Server = game.ServerStorage;
	Client = game.StarterGui;
	Shared = game.ReplicatedStorage;
}
return setmetatable({},{
	__call = function(self,loaderfolder,automatedSettings:boolean?)
		local settings = loaderfolder:FindFirstChild("Configuration")
		local finalsettings
		local main = {}
		_G.ScriptrsAdminMain = main
		if automatedSettings then
			finalsettings = defaultsettings
		elseif not settings then
			finalsettings = defaultsettings
		elseif settings then
			if not settings:IsA("ModuleScript") then
				finalsettings = defaultsettings
			else
				local _,settings=pcall(require,settings)
				if not settings then
					finalsettings = defaultsettings
				else
					if not (typeof(settings)=="table") then
						finalsettings = defaultsettings
					else
						for i,v in defaultsettings do
							if settings[i]==nil then
								settings[i]=v
							end
						end
						local ignore = {}
						for i,_ in settings do
							if defaultsettings[i]==nil then
								table.insert(ignore,i)
							end
						end
						for _,i in ignore do
							settings[i] = nil
						end
						finalsettings = settings
					end
				end
			end
		end
		
		for _,i in script:GetChildren() do
			main[i.Name:lower()] = {}
			for _,v in i:GetChildren() do
				v.Parent = places[i.Name] or game.ReplicatedStorage
				main[i.Name:lower()][v.Name] = v
			end
			i:Destroy()
		end
		
		main.getOwner = function()
			if game.CreatorType == Enum.CreatorType.User then
				local _,name = pcall(function()return game.Players:GetNameFromUserIdAsync(game.CreatorId)end)
				return {UserId=game.CreatorId,Name=name or "???"}
			else	
				local _,info = pcall(function()return game.GroupService:GetGroupInfoAsync(game.CreatorId)end)
				if info and info.Owner then
					return {UserId=info.Owner.Id,Name=info.Owner.Name}
				else
					return {UserId=0,Name="???"}
				end
			end
		end
		
		main.settings = finalsettings
		main.serveradmins = {}
		main.commands = require(main.server.SAModules.BuiltinCommands)
		main.server.SAModules.BuiltinCommands.Parent = nil
		local cc = loaderfolder:FindFirstChild("Commands")
		if not cc then 
			cc={} 
		elseif not cc:IsA("ModuleScript") then 
			cc={} 
		elseif not (typeof(require(cc))=="table") then 
			cc={}
		else
			local sep = {}
			for i,v in require(cc) do
				sep[i:lower()]=v
			end
			cc=sep
		end
		local duplicates = {}
		for name:string,info:{any} in cc do
			if name:sub(1,2)=="un" then
				print("ignored",name,"| No command names starts with \"un\" allowed")
				continue
			end
			if table.find(duplicates,name:lower()) then
				print("ignored",name,"| Duplicated Command")
				continue
			end
			table.insert(duplicates,name:lower())
			if main.commands[name:lower()] then
				print("overwrote",name,"| A custom command have the same name as one of the command that already builtin")
			end
			main.commands[name:lower()] = info
		end

		table.sort(finalsettings.ranks,function(a,b)return a[1]>b[1]end)
		local finalizedcmds = {}
		for i,v in main.commands do
			v.Name = i
			table.insert(finalizedcmds,v)
		end
		main.commands = finalizedcmds
		table.sort(main.commands,function(a,b)return a.Rank<b.Rank end)
		
		script.Name = "ScriptrsAdminMain"
		script.Parent = game.ServerStorage
		
		table.freeze(main)
		
		loaderfolder:Destroy()
	
		for _,i in main.server do
			if i:IsA("ModuleScript") then
				require(i)
			end
		end
		
		return main
	end,
	__metatable = "",
	__index = function(self,key)return rawget(self,key)end,
	__newindex = function()return false end
})