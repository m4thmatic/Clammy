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

addon.author   = 'MathMatic';
addon.name     = 'Clammy';
addon.desc     = 'Clamming calculator: displays bucket weight, items in bucket, & approximate value.';
addon.version  = '0.2';

require ('common');
local imgui = require('imgui');
local settings = require('settings');

local clammingItems = {
	{ item="Bibiki slug",				weight=3,	gil=7},
	{ item="Bibiki urchin", 			weight=6,	gil=750},
	{ item="Broken willow fishing rod",	weight=6,	gil=0},
	{ item="Coral fragment",			weight=6,	gil=1735}, --AH=~3000
	{ item="High-quality crab shell",	weight=6,	gil=3312}, --AH=~4500
	{ item="Crab shell",				weight=6,	gil=392},  --Make sure HQ version is listed above NQ for proper registering of item
	{ item="Elshimo coconut", 			weight=6,	gil=44},
	{ item="Elm log", 					weight=6,	gil=4000}, --AH*, NPC=390
	{ item="Fish scales",				weight=3,	gil=23},
	{ item="Goblin armor",				weight=6,	gil=200},  --AH*, NPC=0
	{ item="Goblin mail", 				weight=6,	gil=1000}, --AH*, NPC=0
	{ item="Goblin mask", 				weight=6,	gil=500},  --AH*, NPC=0
	{ item="Hobgoblin bread", 			weight=6,	gil=91},
	{ item="Hobgoblin pie", 			weight=6,	gil=153},
	{ item="Igneous rock", 				weight=35,	gil=178},
	{ item="Jacknife", 					weight=11,	gil=35},
	{ item="Lacquer tree log", 			weight=6,	gil=6000}, --AH*, NPC=3578
	{ item="Maple log", 				weight=6,	gil=15},
	{ item="Nebimonite", 				weight=6,	gil=53},
	{ item="Oxblood", 					weight=6,	gil=13250},
	{ item="Pamamas", 					weight=6,	gil=20},
	{ item="Pamtam kelp", 				weight=6,	gil=7},
	{ item="Pebble", 					weight=7,	gil=1},
	{ item="Petrified log", 			weight=6,	gil=2193}, --AH=~3500
	{ item="Quality pugil scales",		weight=6,	gil=253},  --AH~=1000 --Note: For some reason using "High-quality" doesn't register properly for pugil scales, leave as "Quality" (unsure why)
	{ item="Pugil scales", 				weight=3,	gil=23},   --Make sure HQ version is listed above NQ for proper registering of item
	{ item="Rock salt",					weight=6,	gil=3},
	{ item="Seashell", 					weight=6,	gil=29},
	{ item="Shall shell",				weight=6,	gil=307},
	{ item="Titanictus shell", 			weight=6,	gil=357},  --AH=~600
	{ item="Tropical clam", 			weight=20,	gil=5100},
	{ item="Turtle shell", 				weight=6,	gil=1190},
	{ item="Uragnite shell", 			weight=6,	gil=1455},
	{ item="Vongola clam", 				weight=6,	gil=192},
	{ item="White sand",				weight=7,	gil=250},
};

local defaultConfig = T{
	log = false,
}
local config = settings.load(defaultConfig);


local bucketSize = 50;
local weight = 0;
local money  = 0;
local bucket = {};
local cooldown = 0;
--local file = nil;

local fileName = ('log_%s.txt'):fmt(os.date('%Y_%m_%d__%H_%M_%S'));
local fileDir = ('%s\\addons\\Clammy\\logs\\'):fmt(AshitaCore:GetInstallPath());
local filePath = fileDir .. fileName;

--------------------------------------------------------------------
local function emptyBucket()
	bucketSize = 50;
	weight = 0;
	money = 0;

	for idx,citem in ipairs(clammingItems) do
		bucket[idx] = 0;
	end
end

--------------------------------------------------------------------
function openLogFile()
	if (ashita.fs.create_directory(fileDir) ~= false) then
		file = io.open(filePath, 'a');

		if (file == nil) then
			print("Clammy: Could not open log file.")
		else
			return file;
		end
	end
end

--------------------------------------------------------------------
function closeLogFile(file)
	if (file ~= nil) then
		io.close(file)
	end
end

--------------------------------------------------------------------
function writeLogFile(item)
	local file = openLogFile();

	if (file ~= nil) then
		fdata = ('%s, %s\n'):fmt(os.date('%Y-%m-%d %H:%M:%S'), item);
		file:write(fdata);
	end

	closeLogFile(file);
end

--------------------------------------------------------------------
ashita.events.register('load', 'load_cb', function()
	emptyBucket();

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

	--[[ --DEBUG COMMANDS
	if (#args == 2 and args[2]:any('reset')) then --manually empty the bucket
		emptyBucket();
        return;
    end

    if (#args == 3 and args[2]:any('weight')) then --manually overide the bucket's weight
        weight = tonumber(args[3]);
        return;
    end

	if (#args == 3 and args[2]:any('additem')) then --manually add item
		print("adding item: " .. args[3]);
        writeLogFile(args[3]);
        return;
    end
	]]

	if (#args == 3 and args[2]:any('log')) then --turns loggin on/off
        if (args[3] == "true") then
			config.log = true;
		else
			config.log = false;
		end

		settings.save();
        return;
    end
end);

--------------------------------------------------------------------
ashita.events.register('text_in', 'Clammy_HandleText', function (e)
    if (e.injected == true) then
        return;
    end

	if (string.match(e.message, "You return the")) then
		emptyBucket();
		return;
	end

	--Your clamming capacity has increased to XXX ponzes!
	if (string.match(e.message, "Your clamming capacity has increased to")) then
		bucketSize = bucketSize + 50;
		return;
	end

	if (string.match(e.message, "All your shellfish are washed back into the sea")) then
		emptyBucket();
		return;
	end

	if (string.match(e.message, "You find a")) then
		for idx,citem in ipairs(clammingItems) do
			if (string.match(string.lower(e.message), string.lower(citem.item)) ~= nil) then
				--print("Item: " .. citem.item);
				weight = weight + citem.weight;
				money = money + citem.gil;
				bucket[idx] = bucket[idx] + 1;
				cooldown =  os.clock() + 10.5;

				if (config.log == true) then
					writeLogFile(citem.item);
				end

				return;
			end
		end
		print(e.message);
	end
end);


--------------------------------------------------------------------
--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    local player = GetPlayerEntity();
	if (player == nil) then -- when zoning
		return;
	end

	local windowSize = 300;
    imgui.SetNextWindowBgAlpha(0.8);
    imgui.SetNextWindowSize({ windowSize, -1, }, ImGuiCond_Always);
	if (imgui.Begin('Clammy', true, bit.bor(ImGuiWindowFlags_NoDecoration))) then

		imgui.Text("Bucket Weight: " .. weight .. " / " .. bucketSize);
		imgui.SameLine();
		imgui.SetCursorPosX(imgui.GetCursorPosX() + imgui.GetColumnWidth() - imgui.GetStyle().FramePadding.x - imgui.CalcTextSize("[999]"));
		local cdTime = math.floor(cooldown - os.clock());
		if (cdTime < 0) then
			cdTime = 0;
		end
		imgui.Text("  [" .. cdTime .. "]");
		
		imgui.Text("Total Gil [npc]: " .. money);

		imgui.Separator();

		for idx,citem in ipairs(clammingItems) do
			if (bucket[idx] ~= 0) then
				imgui.Text(" - " .. clammingItems[idx].item .. " [" .. bucket[idx] .. "]");
				imgui.SameLine();
				local valTxt = "(" .. clammingItems[idx].gil * bucket[idx] .. ")"
				local x, _  = imgui.CalcTextSize(valTxt);
				imgui.SetCursorPosX(imgui.GetCursorPosX() + imgui.GetColumnWidth() - x - imgui.GetStyle().FramePadding.x);
				imgui.Text(valTxt);

			end
		end

    end
    imgui.End();
end);