--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.

--]]

addon.author   = 'MathMatic/DrifterX';
addon.name     = 'Clammy';
addon.desc     = 'Clamming calculator: displays bucket weight, items in bucket, & approximate value.';
addon.version  = '1.2.0';

require('common');
local const = require('constants');
local func = require('functions');
Settings = require('settings');


local defaultConfig = T{
	showItems = T{ true, },
	showValue = T{ true, },
	showSessionInfo = T{ true, },
	log = T{ false, },
	tone = T{ false, },
	useStopTone = T{ true, },
	trackMoonPhase = T{ true, },
	colorWeightBasedOnValue = T{ true, },
	hideInDifferentZone = T{ true, },
	autoResetLog = T{ true, },
	resetFullSession = T{ false, },
	minutesBeforeAutoReset = T{ 120, },
	highValue = T{ 5000 },
	midValue = T{ 1000 },
	lowValue = T{ 500 },
	items = const.clammingItems,
	splitItemsBySellType = T{ true, },
	subtractBucketCostFromGilEarned = T{ true, },
	showAverageTimePerBucket = T{ true, },
	showPercentChanceToBreak = T{ true, },
	legacyLog = T{ false, },
	alwaysStopAtThirdBucket = T{ true, },
	checkEquippedItem = T{ true, },
	windowScaling = T{ 1.0, },
}
Config = Settings.load(defaultConfig);

local clammy = T{
	bucketSize = 50,
	relativeWeight = 50,
	weight = 0,
	money  = 0,
	sessionValue = 0,
	sessionValueNPC = 0,
	sessionValueAH = 0,
	bucketsPurchased = 0,
	bucketsReceived = 0,
	bucket = {},
	trackingBucket = {},
	cooldown = 0,
	startingTime = os.clock(),
	bucketStartTime = 0,
	lastClammingAction = os.clock(),
	bucketAverageTime = 0,
	bucketTimeWith = 0,
	gilPerHour = 0,
	gilPerHourNPC = 0,
	gilPerHourAH = 0,
	gilPerHourMinusBucket = 0,
	trueSessionValue = 0,
	trueSessionValueNPC = 0,
	trueSessionValueAH = 0,
	hasBucket = false,
	bucketIsBroke = false,
	editorIsOpen = T{ false, },
	hasHQLegs = false,
	hasHQBody = false,
	bodyItemId = 0,
	legItemId = 0,
	moonTable = T{
		moonPhase = "",
		moonPercent = 0,
	},
	bucketColor = {1.0,1.0,1.0,1.0},
	stopSound = false,
	items = Config.items,
	hideInDifferentZone = Config.hideInDifferentZone,
	fileName = ('log_%s.txt'):fmt(os.date('%Y_%m_%d__%H_%M_%S')),
	fileNameBroken = ('log_broken_%s.txt'):fmt(os.date('%Y_%m_%d__%H_%M_%S')),
	fileDir = ('%s\\addons\\Clammy\\logs\\'):fmt(AshitaCore:GetInstallPath()),
	playTone = false,
	showItemSeparator = false,
}
clammy.filePath = clammy.fileDir .. clammy.fileName;
clammy.filePathBroken = clammy.fileDir .. clammy.fileNameBroken;

--------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function()
	clammy = func.emptyBucket(clammy, true, true);

end);

--------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function()

end);

--------------------------------------------------------------------
ashita.events.register('command', 'command_cb', function (e)
    -- Parse the command arguments..
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/clammy')) then
		return;
    end

    -- Block all related commands..
    e.blocked = true;

	clammy = func.handleChatCommands(args, clammy);
end);

--------------------------------------------------------------------
ashita.events.register('text_in', 'Clammy_HandleText', function (e)
    if (e.injected == true) then
        return;
    end

	clammy = func.handleTextIn(e, clammy);

end);

--------------------------------------------------------------------
--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    local player = GetPlayerEntity();
	local areaId = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
	if (clammy.editorIsOpen[1] == true) then
		clammy = func.renderEditor(clammy);
	end
	if (player == nil) or ((areaId ~= 4) and (Config.hideInDifferentZone[1] == true)) then -- when zoning or outside Bibiki Bay
		return;
	end
	clammy = func.renderClammy(clammy);
end);