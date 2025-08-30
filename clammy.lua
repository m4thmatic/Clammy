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

addon.author   = 'MathMatic/DorifitoX(Drakeson)';
addon.name     = 'Clammy';
addon.desc     = 'Clamming calculator: displays bucket weight, items in bucket, & approximate value.';
addon.version  = '1.0';

require('common');
local const = require('constants');
local func = require('functions')
Imgui = require('imgui');
Settings = require('settings');
Chat = require('chat');

local defaultConfig = T{
	showItems = T{ true, },
	showValue = T{ true, },
	showSessionInfo = T{ true, },
	logAllResults = T{ true, },
	log = T{ false, },
	tone = T{ false, },
	trackMoonPhase = T{ true, },
	colorWeightBasedOnValue = T{ true, },
	hideInDifferentZone = T{ true, },
	highValue = T{ 5000 },
	midValue = T{ 1000 },
	lowValue = T{ 500 },
	items = const.clammingItems,
	splitItemsBySellType = T{ true, },
}
Config = Settings.load(defaultConfig);

local clammy = T{
	lowValue = Config.lowValue[1],
	midValue = Config.midValue[1],
	highValue = Config.highValue[1],
	bucketSize = 50,
	weight = 0,
	money  = 0,
	sessionValue = 0,
	sessionValueNPC = 0,
	sessionValueAH = 0,
	bucketsPurchased = 0,
	bucket = {},
	trackingBucket = {},
	cooldown = 0,
	startingTime = os.clock(),
	gilPerHour = 0,
	gilPerHourNPC = 0,
	gilPerHourAH = 0,
	trueSessionValue = 0,
	trueSessionValueNPC = 0,
	trueSessionValueAH = 0,
	hasBucket = false,
	bucketIsBroke = false,
	editorIsOpen = T{ false, },
	moonTable = T{
		moonPhase = "",
		moonPercent = 0,
	},
	bucketColor = {1.0,1.0,1.0,1.0},
	items = T{const.clammingItems},
	hideInDifferentZone = Config.hideInDifferentZone,
	fileName = ('log_%s.txt'):fmt(os.date('%Y_%m_%d__%H_%M_%S')),
	fileNameBroken = ('log_broken_%s.txt'):fmt(os.date('%Y_%m_%d__%H_%M_%S')),
	fileDir = ('%s\\addons\\Clammy\\logs\\'):fmt(AshitaCore:GetInstallPath()),
	playTone = false,
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

	clammy = func.handleTextIn(e, clammy)

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

	local windowSize = 300;
    Imgui.SetNextWindowBgAlpha(0.8);
    Imgui.SetNextWindowSize({ windowSize, -1, }, ImGuiCond_Always);
	if (Imgui.Begin('Clammy', true, bit.bor(ImGuiWindowFlags_NoDecoration))) then


		if (clammy.hasBucket == true) then
			Imgui.TextColored({0.0, 1.0, 0.0, 1.0}, "Bucket")
		elseif(clammy.bucketIsBroke == true) then
			Imgui.TextColored({0.1, 0.1, 0.1, 1.0}, "Bucket")
		else
			Imgui.TextColored({0.9, 0.9, 0.0, 1.0}, "Bucket")
		end
		if (Config.trackMoonPhase[1] == true) then
			clammy = func.getMoon(clammy);
		end
		Imgui.SameLine()
		Imgui.Text("Weight [" .. clammy.bucketSize .. "]:");
		Imgui.SameLine();
		Imgui.SetWindowFontScale(1.3);
		Imgui.SetCursorPosY(Imgui.GetCursorPosY()-2);
		Imgui.TextColored(clammy.bucketColor, tostring(clammy.weight));
		Imgui.SetWindowFontScale(1.0);
		Imgui.SameLine();
		Imgui.SetCursorPosX(Imgui.GetCursorPosX() + Imgui.GetColumnWidth() - Imgui.GetStyle().FramePadding.x - Imgui.CalcTextSize("[999]"));
		local cdTime = math.floor(clammy.cooldown - os.clock());
		clammy.trueSessionValue = clammy.sessionValue - (clammy.bucketsPurchased * 500);
		clammy.trueSessionValueNPC = clammy.sessionValueNPC - (clammy.bucketsPurchased * 500);
		clammy.trueSessionValueAH = clammy.sessionValueAH;
		if (cdTime <= 0) then
			Imgui.TextColored({ 0.5, 1.0, 0.5, 1.0 }, "  [*]");
			clammy = func.playSound(clammy);
		else
			Imgui.TextColored({ 1.0, 1.0, 0.5, 1.0 }, "  [" .. cdTime .. "]");
		end

		if (Config.showValue[1] == true) then
			Imgui.Text("Estimated Value: " .. func.formatInt(clammy.money));
		end

		if (Config.showSessionInfo[1] == true) then
			Imgui.Separator();
			Imgui.Text("Total clamming value: " .. func.formatInt(clammy.trueSessionValue));
			if (Config.splitItemsBySellType[1] == true) then
				Imgui.Text("Total NPC selling clamming value: " .. func.formatInt(clammy.trueSessionValueNPC));
				Imgui.Text("Total AH clamming value: " .. func.formatInt(clammy.trueSessionValueAH));
			end
			Imgui.Text("Gil earned per hour: " .. func.formatInt(clammy.gilPerHour));
			if (Config.splitItemsBySellType[1] == true) then
				Imgui.Text("Gil earned per hour(NPC): " .. func.formatInt(clammy.gilPerHourNPC));
				Imgui.Text("Gil earned per hour(AH): " .. func.formatInt(clammy.gilPerHourAH));
			end
			Imgui.Text("Buckets purchased: " .. clammy.bucketsPurchased);
			local now = os.clock();
			Imgui.Text("Session length: " .. func.formatTimestamp(now - clammy.startingTime));
		end
		if (Config.trackMoonPhase[1] == true) then
			Imgui.Separator();
			Imgui.Text("Current moon phase is: " .. clammy.moonTable.moonPhase);
			Imgui.Text("Current moon phase percentage is: " .. clammy.moonTable.moonPercent .. "%");
		end
		

		if (Config.showItems[1] == true) then
			Imgui.Separator();

			for idx,citem in ipairs(const.clammingItems) do
				if (clammy.bucket[idx] ~= 0) then
					Imgui.Text(" - " .. const.clammingItems[idx].item .. " [" .. clammy.bucket[idx] .. "]");
					Imgui.SameLine();
					local valTxt = "(" .. func.formatInt(const.clammingItems[idx].gil[1] * clammy.bucket[idx]) .. ")"
					local x, _  = Imgui.CalcTextSize(valTxt);
					Imgui.SetCursorPosX(Imgui.GetCursorPosX() + Imgui.GetColumnWidth() - x - Imgui.GetStyle().FramePadding.x);
					Imgui.Text(valTxt);

				end
			end
		end
    end
    Imgui.End();
end);