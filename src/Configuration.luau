return {
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
	Prefix = ";";
	
	--// Now for the explaination.
	--/// Yes, this is an almost exact configuration copy of ZUtilities's configuration settings
	--/// Now before you put me in an electric chair, i MADE that
	--/// They shared creators, simple
	--/// Alright enjoy
}