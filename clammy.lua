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

--[[
* Bleuhazen: Added some very minor tweaks -- especially the purple one saves me a lot!
* - Bucket weight turns purple when you hand it in, because i always forgot to get a fresh one.
* - Bucket weight turns black when you break it, just to make it clear.
* - Changed [*] to GO!, and dim it a little when you start the dig.
--]]

addon.author   = 'MathMatic, with tweaks by Bleuhazen';
addon.name     = 'Clammy';
addon.desc     = 'Clamming calculator: displays bucket weight, items in bucket, & approximate value.';
addon.version  = '0.4';

require ('common');
local imgui = require('imgui');
local settings = require('settings');

local clammingItems = {
	{ item="Bibiki slug",				weight=3,	gil=11},
	{ item="Bibiki urchin", 			weight=6,	gil=750},
	{ item="Broken willow fishing rod",	weight=6,	gil=0},
	{ item="Coral fragment",			weight=6,	gil=1735},
	{ item="Quality crab shell",	    weight=6,	gil=3312}, --Note: For some reason using "High-quality" doesn't register properly, leave as "Quality" for the time being
	{ item="Crab shell",				weight=6,	gil=392},  --Make sure HQ version is listed above NQ for proper registering of item
	{ item="Elshimo coconut", 			weight=6,	gil=44},
	{ item="Elm log", 					weight=6,	gil=4000}, --Based on estimated AH value
	{ item="Fish scales",				weight=3,	gil=23},
	{ item="Goblin armor",				weight=6,	gil=70},   --Based on estimated AH value
	{ item="Goblin mail", 				weight=6,	gil=1000}, --Based on estimated AH value
	{ item="Goblin mask", 				weight=6,	gil=450},  --Based on estimated AH value
	{ item="Hobgoblin bread", 			weight=6,	gil=91},
	{ item="Hobgoblin pie", 			weight=6,	gil=165},
	{ item="Igneous rock", 				weight=35,	gil=178},
	{ item="Jacknife", 					weight=11,	gil=35},
	{ item="Lacquer tree log", 			weight=6,	gil=6000}, --Based on estimated AH value
	{ item="Maple log", 				weight=6,	gil=15},
	{ item="Nebimonite", 				weight=6,	gil=53},
	{ item="Oxblood", 					weight=6,	gil=13250},
	{ item="Pamamas", 					weight=6,	gil=20},
	{ item="Pamtam kelp", 				weight=6,	gil=7},
	{ item="Pebble", 					weight=7,	gil=1},
	{ item="Petrified log", 			weight=6,	gil=2193}, 
	{ item="Quality pugil scales",		weight=6,	gil=253},  --Note: For some reason using "High-quality" doesn't register properly, leave as "Quality" for the time being
	{ item="Pugil scales", 				weight=3,	gil=23},   --Make sure HQ version is listed above NQ for proper registering of item
	{ item="Rock salt",					weight=6,	gil=3},
	{ item="Seashell", 					weight=6,	gil=29},
	{ item="Shall shell",				weight=6,	gil=307},
	{ item="Titanictus shell", 			weight=6,	gil=357},
	{ item="Tropical clam", 			weight=20,	gil=5100},
	{ item="Turtle shell", 				weight=6,	gil=1190},
	{ item="Uragnite shell", 			weight=6,	gil=1455},
	{ item="Vongola clam", 				weight=6,	gil=192},
	{ item="White sand",				weight=7,	gil=250},
};

local weightColor = {
	{diff=200, color={1.0, 1.0, 1.0, 1.0}},
	{diff=35, color={1.0, 1.0, 0.8, 1.0}},
	{diff=20, color={1.0, 1.0, 0.4, 1.0}},
	{diff=11, color={1.0, 1.0, 0.0, 1.0}},
	{diff=7, color={1.0, 0.6, 0.0, 1.0}},
	{diff=6, color={1.0, 0.4, 0.0, 1.0}},
	{diff=3, color={1.0, 0.3, 0.0, 1.0}},
}
local bucketColor = {1.0,1.0,1.0,1.0};

local defaultConfig = T{
	showItems = true,
	showValue = true,
	log = false,
	tone = false,
}
local config = settings.load(defaultConfig);

local bucketSize = 50;
local weight = 0;
local money  = 0;
local bucket = {};
local cooldown = 0;

local fileName = ('log_%s.txt'):fmt(os.date('%Y_%m_%d__%H_%M_%S'));
local fileDir = ('%s\\addons\\Clammy\\logs\\'):fmt(AshitaCore:GetInstallPath());
local filePath = fileDir .. fileName;

local playTone = false;

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
function playSound()
	if (config.tone == true) and (playTone == true) then
		ashita.misc.play_sound(addon.path:append("clam.wav"));
		playTone = false;
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

	if (#args == 2 and args[2]:any('reset')) then --manually empty the bucket
		emptyBucket();
        return;
    end

    if (#args == 3 and args[2]:any('weight')) then --manually overide the bucket's weight
        weight = tonumber(args[3]);
        return;
    end

	--[[ For debug purposes
	if (#args == 3 and args[2]:any('additem')) then --manually add item
		print("adding item: " .. args[3]);
        writeLogFile(args[3]);
        return;
    end
	--]]

	if (#args == 3 and args[2]:any('showvalue')) then --turns loggin on/off
        if (args[3] == "true") then
			config.showValue = true;
		else
			config.showValue = false;
		end

		settings.save();
        return;
    end

	if (#args == 3 and args[2]:any('showitems')) then --turns loggin on/off
        if (args[3] == "true") then
			config.showItems = true;
		else
			config.showItems = false;
		end

		settings.save();
        return;
    end

	if (#args == 3 and args[2]:any('log')) then --turns loggin on/off
        if (args[3] == "true") then
			config.log = true;
		else
			config.log = false;
		end

		settings.save();
        return;
    end

	if (#args == 3 and args[2]:any('tone')) then --turns ready tone on/off
        if (args[3] == "true") then
			config.tone = true;
		else
			config.tone = false;
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
		-- bucketColor = {1.0, 1.0, 1.0, 1.0};
		bucketColor = {0.7, 0.0, 0.7, 1.0};
		return;
	end

	if (string.match(e.message, "Spoken like a true clammer!")) then
		bucketColor = {1.0, 1.0, 1.0, 1.0};
		return;
	end

	--Your clamming capacity has increased to XXX ponzes!
	if (string.match(e.message, "Your clamming capacity has increased to")) then
		bucketSize = bucketSize + 50;
		bucketColor = {1.0, 1.0, 1.0, 1.0};
		return;
	end

	if (string.match(e.message, "All your shellfish are washed back into the sea")) then
		emptyBucket();
		-- bucketColor = {1.0, 1.0, 1.0, 1.0};
		bucketColor = {0.0, 0.0, 0.0, 1.0};
		return;
	end

	if (string.match(e.message, "The area is littered with pieces of broken seashells")) then
		cooldown = 0;
	end

	if (string.match(e.message, "You find a")) then
		for idx,citem in ipairs(clammingItems) do
			if (string.match(string.lower(e.message), string.lower(citem.item)) ~= nil) then
				weight = weight + citem.weight;
				money = money + citem.gil;
				bucket[idx] = bucket[idx] + 1;
				cooldown =  os.clock() + 10.5;

				for _, item in ipairs(weightColor) do
					if ((bucketSize - weight) < item.diff) then
						bucketColor = item.color;
					end
				end

				playTone = true;

				if (config.log == true) then
					writeLogFile(citem.item);
				end

				return;
			end
		end
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


		imgui.Text("Bucket Weight [" .. bucketSize .. "]:");
		imgui.SameLine();
		imgui.SetWindowFontScale(1.3);
		imgui.SetCursorPosY(imgui.GetCursorPosY()-2);
		imgui.TextColored(bucketColor, tostring(weight));
		imgui.SetWindowFontScale(1.0);
		imgui.SameLine();
		imgui.SetCursorPosX(imgui.GetCursorPosX() + imgui.GetColumnWidth() - imgui.GetStyle().FramePadding.x - imgui.CalcTextSize("[999]"));

		if (cooldown == 0) then
			imgui.TextColored({ 0.5, 0.65, 0.5, 1.0 }, "  GO!");
		else
			local cdTime = math.floor(cooldown - os.clock());
			if (cdTime <= 0) then
				imgui.TextColored({ 0.5, 1.0, 0.5, 1.0 }, "  GO!");
				playSound()
			else
				imgui.TextColored({ 1.0, 1.0, 0.5, 1.0 }, "  [" .. cdTime .. "]");
			end
		end

		if (config.showValue == true) then
			imgui.Text("Estimated Value: " .. money);
		end

		if (config.showItems == true) then
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
    end
    imgui.End();
end);
