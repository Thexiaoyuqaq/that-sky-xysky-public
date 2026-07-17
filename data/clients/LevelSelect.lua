-------------------------------------------------------------------------------
-- Notes:  All levels to load into the level chooser!
--
-- Author: Adam Lederer
-- Date C: 08-28-2014
-------------------------------------------------------------------------------

if _G["SKY_ENABLE_RETAIL_DEMO"] == nil then
	SKY_ENABLE_RETAIL_DEMO = os.getenv("SKY_ENABLE_RETAIL_DEMO")
end

function level( name, bundle, realm )
	local obj = {
		["name"] = name,
		["bundle"] = bundle,
		["realm"] = realm ~= nil and realm or bundle,
	}
	return obj
end

-- The level that is first loaded after starting
StartLevel = "CandleSpace"
EmptyLevel = "WorldEmpty"

-- The core levels that will appear in the Levels debug menu
-- Note that these will ship with GOLD builds!
ArcLevels = {
	level( "CandleSpace",				"",			"dawn" ),
	level( "Dawn",						"",			"dawn" ),
	level( "StormEvent_VoidSpace",		"",			"storm" ),
	-- Do not add levels to "" bundle without changing things in MakeResourceScripts.lua
	-- Combined assets can not exceed 150MB""

	-- Mainstreet Levels
	level( "MainStreet",				"dawn" ),
	level( "MainStreetFlyingIntro",		"dawn" ),
	level( "MainStreet_ShopOutfits",	"dawn" ),
	level( "MainStreet_ShopSpells",		"dawn" ),
	level( "MainStreet_ShopProps",		"dawn" ),
	level( "MainStreet_Apartment",		"dawn" ),
	level( "MainStreet_Cafe",			"dawn" ),
	level( "MainStreet_ConcertHall",	"dawn" ),
	level( "MainStreet_FunArmada",		"dawn" ),
	level( "MainStreet_Soundbath",  	"dawn" ),
	level( "MainStreet_Cafe_Wonderland","dawn" ),
	level( "MainStreet_StorySpace",		"dawn" ),
	level( "Nest_Shell", 				"dawn" ),
	level( "Event_Cinema",         		"dawn" ),
	level( "Night_IPHallway",			"dawn" ),
	
	level( "Prairie_ButterflyFields", 	"prairie" ),
	level( "Prairie_Cave", 				"prairie" ),
	level( "Prairie_NestAndKeeper", 	"prairie" ),
	level( "Prairie_Island", 			"prairie" ),
	level( "Prairie_Village", 			"prairie" ),
	level( "Prairie_WildLifePark", 		"prairie" ),
	level( "DayHubCave", 				"prairie" ),
	level( "DayEnd", 					"prairie" ),
	
	level( "Rain", 						"rain" ),
	level( "RainForest", 				"rain" ),
	level( "RainMid", 					"rain" ),
	level( "RainShelter", 				"rain" ),
	level( "Rain_Cave", 				"rain" ),
	level( "Rain_BaseCamp", 			"rain" ),
	level( "RainEnd", 					"rain" ),
	level( "Skyway", 					"rain" ),
	
	level( "Sunset", 					"sunset" ),
	level( "SunsetRace", 				"sunset" ),
	level( "Sunset_Citadel", 			"sunset" ),
	level( "Sunset_FlyRace", 			"sunset" ),
	level( "SunsetEnd", 				"sunset" ),
	level( "SunsetColosseum",           "sunset" ),
	level( "SunsetEnd2", 				"sunset" ),
	level( "SunsetVillage",             "sunset" ),
	level( "SunsetVillage_MusicShop",   "sunset" ),
	level( "Sunset_YetiPark",           "sunset" ),
	level( "Sunset_Theater",            "sunset" ),

	level( "DuskStart", 				"dusk" ),
	level( "Dusk", 						"dusk" ),
	level( "Dusk_Triangle", 			"dusk" ),
	level( "Dusk_TriangleEnd", 			"dusk" ),
	level( "DuskOasis", 				"dusk" ),
	level( "DuskGraveyard", 			"dusk" ),
	level( "Dusk_CrabField", 			"dusk" ),
	level( "DuskMid", 					"dusk" ),
	level( "DuskEnd",					"dusk" ),
	level( "Nintendo_CandleSpace",		"dusk" ),

	level( "Night",						"night" ),
	level( "NightArchive",				"night" ),
	level( "Night2",					"night" ),
	level( "NightEnd",					"night" ),
	level( "TGCOffice",					"night" ),
	level( "Event_Personality",         "night" ),
	level( "VoidSharedSpace"	,		"night" ),
	level( "Event_DaysOfMischief",		"night" ),
	level( "Event_DaysOfMischief_Escape","night" ),
	
	-- AP08 Prophecy
	level( "DawnCave",					"dawn" ),
	level( "Dawn_TrialsWater",			"dawn" ),
	level( "Dawn_TrialsEarth",			"dawn" ),
	level( "Dawn_TrialsAir",			"dawn" ),
	level( "Dawn_TrialsFire",			"dawn" ),

	-- AP11 Little Prince
	level( "NightDesert",				"night" ),
	level( "NightDesert_Planets",		"night" ),
	level( "NightDesert_Beach",			"night" ),
	level( "Night_InfiniteDesert",      "night" ),
	level( "Night_JarCave",				"night" ),
	level( "Night_Shelter",				"night" ),

	-- AP16 AURORA
	level( "Event_Arr_Runaway",         "sunset" ),
	level( "Event_Arr_SoftInside",      "sunset" ),
	level( "Event_Arr_Warrior",         "sunset" ),
	level( "Event_Arr_TheSeed",         "sunset" ),
	level( "Event_Arr_EyesOfAChild",    "sunset" ),
	level( "Event_Arr_ExhaleInhale",    "sunset" ),
	
	-- AP21 Nine Colored Deer
    level( "Night_PaintedWorld",        "night" ),
	level( "Event_DaysOfMoonlight_HugeMoon",      "night" ),
	
    -- AP24 Moomin
	level( "Season24Void1",         	"night" ),
	level( "Night_StoryBook",      	    "night" ),
	level( "Night_ValleyForest",        "night" ),
	level( "Night_ValleyHouse",         "night" ),
    level( "Night_ValleyHouseSky",      "night" ),
        
    -- AP26 Blue Bird
	level( "Rain_BlueBirdTheater", 		"rain" ),

	-- AP27 The Two Embers
	level( "DuskMid_Past", 				"dusk" ),
	level( "DuskMid_PastMarket", 		"dusk" ),
	level( "Dusk_HiddenTemple", 		"dusk" ),
	level( "DuskEnd_Past",				"dusk" ),

	-- AP29 Lightmending
	level( "Night_Jumble",      		"night" ),
	level( "Night_Workshop",			"night"	),
	
	-- AP31 Dear Van Gogh
	level( "Night_GO_City",				"night" ),
	level( "Night_GO_Farm",				"night" ),
	level( "Night_GO_Field",			"night" ),
	level( "Night_GO_Gallery",			"night" ),
	level( "Night_GO_Island",			"night" ),
	level( "Night_GO_Town",				"night" ),
	level( "Night_GO_Tree",				"night" ),
	
	level( "StormStart", 				"storm" ),
	level( "Storm", 					"storm" ),
	level( "StormEnd",					"storm" ),
	level( "OrbitMid", 					"storm" ),
	level( "OrbitEnd", 					"storm" ),
	level( "CandleSpaceEnd", 			"storm" ),
	level( "Credits", 					"storm" ),
	-- Any levels after Credits in this list will not be able to be resumed via return shrine. Only stick your level after this point if that is your intention.
	level( "AR_TestLevel",				"storm" ),
	level( "AR_WheatField",				"storm" ),
	level( "AR_Bedroom",				"storm" ),
	
}

function bundle( name, autoRequest, defaultPriority, next, text, prerequisites )
	local obj = { ["name"] = name, ["auto"] = autoRequest, ["prio"] = defaultPriority, ["next"] = next, ["text"] = text, ["prereq"] = prerequisites }
	return obj
end

ResourceBundles = {
	bundle( "audioExtra",	true,	4,	"",				"download_audio",		{} ),
	bundle( "prairie",		false,	2,	"rain",			"download_day",			{"images","meshes"} ),
	bundle( "rain",			false,	2,	"sunset",		"download_rain",		{"images","meshes"} ),
	bundle( "sunset",		false,	2,	"dusk",			"download_sunset",		{"images","meshes"} ),
	bundle( "dusk",			false,	2,	"night",		"download_dusk",		{"images","meshes"} ),
	bundle( "night",		false,	2,	"storm",		"download_night",		{"images","meshes"} ),
	bundle( "storm",		false,	2,	"",				"download_storm",		{"images","meshes"} ),
	bundle( "dawn",			false,	3,	"",				"download_dawncave",	{"images","meshes"} ),
	bundle( "images",		false,	3,	"",				"download_images",		{} ),
	bundle( "meshes",		false,	3,	"",				"download_meshes",		{} ),
	--bundle( "aviary",		false,	3,	"",				"download_aviary",		{"images","meshes"} ),
	--bundle( "ap08",		false,	3,	"",				"download_ap08",		{"images","meshes"} ),
	--bundle( "ap31",		false,	3,	"",				"download_ap31",		{"images","meshes"} ),
}

-- These levels will also be packaged with the Game, but will only appear in the LevelsHuge debug menu section.
-- Note that these are excluded from GOLD builds (only EmptyLevel is included).
ExtraLevels = {
	EmptyLevel,
	--"SunsetVillage_MusicShop",
	--"PrototypeSpiritQuestForFetch",
	--"S10MeshPropPrototype",
	--"SunsetAP9",
	--"Sunset_YetiPark",
	--"SunsetVillage3",
	--"TGCOffice",
	--"StormStart",
	--"CarryLand",
	--"CarryLand2",
	--"CarryLand3",
	--"TGCOffice",
	--"SlideTest",
	--"Skyway"
	--"DarkCreatureGym",
	--"CritterStartingRotTest",
	--"Nintendo_CandleSpace",
	--"BeyondLevel7",
	--"BST_Yoshi_TEST",
	--"MatchTest" -- Temporary for wax testing, don't ship - JEH 1/5/22
	"AR_WheatField",
	"AR_Bedroom",
	"S31_SandBox",
	"OceanTest", -- for performance testing
	"Test_TGCEmployees", -- for testing all of the TGCOffice NPCS
	-- AP32 Pearl
	"Dusk_PearlIsland",
	"Dusk_PearlSea",
	"Dusk_PearlSeaDeep"
}

-- Tutorial levels. The first level you get if you have no checkpoint data
TutorialStartLevel = "Dawn"

-- Home level. The level you start at if you have completed the tutorial
HomeLevel = "CandleSpace"

-- Current last level player can travel to
EndLevel = "Credits"

-- Where the credits play
CreditsLevel = "Credits"

if SKY_ENABLE_RETAIL_DEMO then
	ArcLevels = {
		level( "RetailDemo_Dawn",		"" ),
		level( "RetailDemo_Sunset",		"" ),
		level( "RetailDemo_Prairie",	"" ),
	}
	ResourceBundles = { }
	StartLevel = "RetailDemo_Dawn"
	TutorialStartLevel = StartLevel
	HomeLevel = StartLevel
end

-------------------------------------------------------------------------------
-- functions
-------------------------------------------------------------------------------
function GetArcLevelNames()
 	levelNames = {}
	for i, level in ipairs( ArcLevels ) do
		levelNames[i] = level.name;
	end
	return levelNames;
end

function GetArcLevelCount()
	local count = 0;
	for i, level in ipairs( ArcLevels ) do
		count = count + 1;
	end
	return count;
end

-- Returns unique bundle names in comma separated string of all level bundles
function GetArcBundleNames()
	uniqueBundleNames = {}
	bundleNameStr = "";

	for i, level in ipairs( ArcLevels ) do
		if ( level.bundle ~= "" and uniqueBundleNames[ level.bundle ] ~= 1 ) then
			bundleNameStr = bundleNameStr..level.bundle..","
			uniqueBundleNames[ level.bundle ] = 1;
		end
	end
	return bundleNameStr;
end

-- Returns levelName, bundleName, .., .., in comma separated string that includes all levels that have a bundle set
function GetLevelBundleInfo()
	retstr = "";

	for i, level in ipairs( ArcLevels ) do
		if ( level.bundle ~= "" ) then
			retstr = retstr..level.name..","..level.bundle..",";
		end
	end
	return retstr;
end

-- Returns name, next, prereq, .., .., in comma separated string
function GetResourceBundles()
	retstr = "";

	for i, bundle in ipairs( ResourceBundles ) do
		retstr = retstr .. bundle.name .. ",";
		if ( bundle.auto ) then
			retstr = retstr .. "true,";
		else
			retstr = retstr .. "false,";
		end
		retstr = retstr .. bundle.prio .. ",";
		retstr = retstr .. bundle.next .. ",";
		retstr = retstr .. bundle.text .. ",";
		retstr = retstr .. "[" .. table.concat(bundle.prereq,",") .. "],";
	end
	return retstr;
end

function PopulateLevelSelect( debugHud, debugTweak, metaSystem )
	for i, level in ipairs( ArcLevels ) do
		debugHud:AddLevelSelectTweak( debugTweak, metaSystem, "LevelSelectQueueLevel", "Levels", level.name )
	end
end

function FillTestBarnArcLevels( testBarn )
	for i, level in ipairs( ArcLevels ) do
		testBarn:AddArcLevel( level.name, level.bundle );
	end
end

-- Returns 1 if level1 is earlier than level2
-- Returns 2 if level1 is equal to level2
-- Returns 3 if level1 is later than level2
-- Returns -1 if level1 isn't in the arc
-- Returns -2 if level2 isn't in the arc
-- Returns -3 if level1 and level2 aren't in the arc
function LevelCmp( level1, level2 )
	local levelIndex1, levelIndex2
	for i, val in ipairs(ArcLevels) do
		if val.name == level1 then
			levelIndex1 = i
		end
		if val.name == level2 then
			levelIndex2 = i
		end
	end
	if levelIndex1 == nil then
		if levelIndex2 == nil then
			return -3
		else
			return -1
		end
	elseif levelIndex2 == nil then
		return -2
	elseif levelIndex1 < levelIndex2 then
		return 1
	elseif levelIndex1 > levelIndex2 then
		return 3
	elseif levelIndex1 == levelIndex2 then
		return 2
	else
		error('Unexpected')
	end
end

-- You can paste this uncommented in a file to test the LevelCmp function
-- assert(LevelCmp("Dawn", "Prairie_ButterflyFields") == 1)
-- assert(LevelCmp("Rain", "Rain") == 2)
-- assert(LevelCmp("Storm", "DayHubCave") == 3)
-- assert(LevelCmp("Foo", "DayHubCave") == -1)
-- assert(LevelCmp("DayEnd", "Foo") == -2)
-- assert(LevelCmp("Foo", "Bar") == -3)
-- print('ok')

function GetStartLevel() return StartLevel end
function GetEmptyLevel() return EmptyLevel end
function GetTutorialStartLevel() return TutorialStartLevel end
function GetHomeLevel() return HomeLevel end
function GetEndLevel() return EndLevel end
function GetCreditsLevel() return CreditsLevel end

function GetLevelBundle( levelName )
	local bundle = ""
	for i, level in ipairs( ArcLevels ) do
		if level.name == levelName then
			bundle = level.bundle
		end
	end
	if bundle == nil then
		return ""
	end
	return bundle
end

function GetLevelRealm( levelName )
	local realm = ""
	for i, level in ipairs( ArcLevels ) do
		if level.name == levelName then
			realm = level.realm
			break
		end
	end
	return realm
end

function PopulateNetLevelGroups( netLevelList )
-- deprecated
end

-- Used by `ccl rds populate` to know which levels are in the arc
function PrintArcLevels()
	for _, level in ipairs(ArcLevels) do
		print(level.name)
	end
end

function ValidateLevelSelect( collectibleBarn )
	local badLevels = {}

	for i, level in ipairs( ArcLevels ) do
		if not collectibleBarn:GetLevelIdHasLevel( level.name ) then
			table.insert( badLevels, level.name )
		end
	end

	-- For now don't require ExtraLevels to have a valid LevelId
	--[[
	for i, level in ipairs( ExtraLevels ) do
		if not collectibleBarn:GetLevelIdHasLevel( level ) then
			table.insert( badLevels, level )
		end
	end
	--]]

	print( table.concat( badLevels, ", " ) )
	return table.concat( badLevels, ", " )
end
