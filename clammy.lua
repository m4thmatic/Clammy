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
addon.version  = '0.1';

require ('common');
local imgui = require('imgui');



local clammingItems = {
	{ item="Bibiki slug",				weight=3,	gil=7},
	{ item="bibiki urchin", 			weight=6,	gil=750},
	{ item="broken willow fishing rod",	weight=6,	gil=0},
	{ item="coral fragment",			weight=6,	gil=1735},
	{ item="high-quality crab shell",	weight=6,	gil=3312},
	{ item="crab shell",				weight=6,	gil=392},
	{ item="elshimo coconut", 			weight=6,	gil=44},
	{ item="elm log", 					weight=6,	gil=390},
	{ item="fish scales",				weight=3,	gil=23},
	{ item="Goblin armor",				weight=6,	gil=0}, --200
	{ item="Goblin mail", 				weight=6,	gil=0}, --1000
	{ item="goblin mask", 				weight=6,	gil=0}, --500
	{ item="Hobgoblin bread", 			weight=6,	gil=91},
	{ item="Hobgoblin pie", 			weight=6,	gil=153},
	{ item="igneous rock", 				weight=35,	gil=178},
	{ item="jacknife", 					weight=11,	gil=35},
	{ item="lacquer tree log", 			weight=6,	gil=3578},
	{ item="maple log", 				weight=6,	gil=15},
	{ item="nebimonite", 				weight=6,	gil=53},
	{ item="oxblood", 					weight=6,	gil=13250},
	{ item="pamamas", 					weight=6,	gil=20},
	{ item="pamtam kelp", 				weight=6,	gil=7},
	{ item="pebble", 					weight=7,	gil=1},
	{ item="petrified log", 			weight=6,	gil=2193},
	{ item="quality pugil scales",		weight=6,	gil=253},
	{ item="pugil scales", 				weight=3,	gil=23},
	{ item="rock salt",					weight=6,	gil=3},
	{ item="seashell", 					weight=6,	gil=29},
	{ item="shall shell",				weight=6,	gil=307},
	{ item="titanictus shell", 			weight=6,	gil=357},
	{ item="tropical clam", 			weight=20,	gil=5100},
	{ item="turtle shell", 				weight=6,	gil=1190},
	{ item="uragnite shell", 			weight=6,	gil=1455},
	{ item="vongola clam", 				weight=6,	gil=192},
	{ item="white sand",				weight=7,	gil=250},
};

local bucketSize = 50;
local weight = 0;
local money  = 0;
local bucket = {};
local cooldown = 0;

local function emptyBucket()
	bucketSize = 50;
	weight = 0;
	money = 0;

	for idx,citem in ipairs(clammingItems) do
		bucket[idx] = 0;
	end
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
			end
		end

    end
    imgui.End();
end);