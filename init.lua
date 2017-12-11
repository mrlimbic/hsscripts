--[[

Instructions

Navigation:

	NOTE: All positioning is done via timecodes, so project positioning must be set to use frames at correct frame rate
	Some DAWs require some extra custom key mappings

Key bindings:

	Protools - default keys only
	StudioOne - default keys only
	Digital Performer - default keys only
	
	Logic Pro X - Map the following keys to actions
		cmd-shift-c -> "Copy section between locators (Global)"
		cmd-shift-[ -> "Set Left Locator Numerically"
		shift-/ 	-> "Go to Position"
--]]

local default_folder = "~/Desktop"
local delay = 1000000
local hourshift = 0

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function s1_goto(timecode)
	-- goto=CMD-T;#0;#1;TAB;#3;#4;TAB;#6;#7;TAB;#9;#10;ENTER
	local h = string.sub(timecode, 1, 2)
	local m = string.sub(timecode, 4, 5)
	local s = string.sub(timecode, 7, 8)
	local f = string.sub(timecode, 10, 11)
	hs.eventtap.keyStroke({"cmd"}, "t")
	hs.eventtap.keyStrokes(h)
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStrokes(m)
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStrokes(s)
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStrokes(f)
	hs.eventtap.keyStroke({}, "return")
end

function s1_loopStart()
	hs.eventtap.keyStroke({ "alt" }, "pad1")
end

function s1_loopEnd()
	hs.eventtap.keyStroke({ "alt" }, "pad2")
end

function s1_selectAllInLoop()
	hs.eventtap.keyStroke({"alt"}, "l")
end

function s1_splitLoop()
	hs.eventtap.keyStroke({"cmd", "shift"}, "x")
end

function s1_setMarker(name)
	hs.eventtap.keyStroke({"shift"}, "y")
	hs.eventtap.keyStrokes(name)
	hs.eventtap.keyStroke({}, "return")
end

function standard_copy()
	hs.eventtap.keyStroke({"cmd"}, "c", delay)
end

function standard_paste()
	hs.eventtap.keyStroke({"cmd"}, "v", delay)
end

function standard_selectAll() 
	hs.eventtap.keyStroke({"cmd"}, "a")
end

function s1_apply_move(srcIn, srcOut, destIn, destOut)
	-- select and split source range
	s1_goto(srcIn)
	s1_loopStart()
	s1_goto(srcOut)
	s1_loopEnd()
	s1_selectAllInLoop()
	s1_splitLoop()

	-- copy source range
	standard_copy()

	-- copy to new destination
	s1_goto(destIn)
	s1_setMarker(srcIn)
	standard_paste()

	-- create marker at end on new range
	--s1_goto(destOut)
	--s1_setMarker()
end

function pt_goto(timecode)
	hs.eventtap.keyStroke({}, "pad*")
	hs.eventtap.keyStrokes(timecode)
	hs.eventtap.keyStroke({}, "padenter")
end

function pt_setMarker(name)
	hs.eventtap.keyStroke({}, "padenter")
	hs.eventtap.keyStrokes(name)
	hs.eventtap.keyStroke({}, "padenter")
end

function pt_selectRange(tc_in, tc_out)
	hs.eventtap.keyStroke({"alt"}, "pad/")
	hs.eventtap.keyStrokes(tc_in)
	hs.eventtap.keyStroke({"alt"}, "pad/")
	hs.eventtap.keyStrokes(tc_out)
	hs.eventtap.keyStroke({}, "padenter")
end

function pt_apply_move(srcIn, srcOut, destIn, destOut)
	pt_selectRange(srcIn, srcOut)
	standard_copy()
	pt_goto(destIn)
	pt_setMarker(srcIn)
	standard_paste()
	pt_goto(destOut)
--	pt_setMarker(srcOut) -- for some reason this messes things up randomly
end

function dp_goto(timecode)
	-- by concidence DP has same goto timecode method as studio one
	s1_goto(timecode)
end

function dp_selectRange(tc_in, tc_out)
	-- select all
	standard_selectAll()
	-- goto
	dp_goto(tc_in)
	-- set selection start
	hs.eventtap.keyStroke({}, "f5")
	-- goto
	dp_goto(tc_out)
	-- set selection end
	hs.eventtap.keyStroke({}, "f6")
end

function dp_deselectAll()
	hs.eventtap.keyStroke({"cmd"}, "d")
end

function dp_setMarker(name)
	-- Not sure how to set a marker with a name using just the keyboard
	hs.eventtap.keyStroke({"ctrl"}, "m")
end

function dp_apply_move(srcIn, srcOut, destIn, destOut)
	dp_selectRange(srcIn, srcOut)
	standard_copy()
	dp_deselectAll()
	dp_goto(destIn)
	standard_paste()
	dp_setMarker(srcIn)
end

function lp_selectRange(tc_in, tc_out)
	hs.eventtap.keyStroke({"cmd", "shift"}, "[") -- custom key map
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStrokes(tc_in)
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStrokes(tc_out)
	hs.eventtap.keyStroke({}, "return")
end

function lp_goto(timecode)
	hs.eventtap.keyStroke({"shift"}, "/") -- custom key map
	hs.eventtap.keyStroke({}, "tab")
	hs.eventtap.keyStrokes(timecode)
	hs.eventtap.keyStroke({}, "return")
end

function lp_paste()
	hs.eventtap.keyStroke({"ctrl", "cmd"}, "v", delay)
end

function lp_setMarker(name)
	hs.eventtap.keyStroke({"alt"}, "'")
	hs.eventtap.keyStroke({"shift"}, "'")
	hs.eventtap.keyStrokes(name)
	hs.eventtap.keyStroke({}, "return")
end

function lp_apply_move(srcIn, srcOut, destIn, destOut)
	lp_selectRange(srcIn, srcOut)
	hs.eventtap.keyStroke({"cmd", "shift"}, "c", delay)
	lp_goto(destIn)
	lp_setMarker(srcIn)
	hs.eventtap.keyStroke({"ctrl", "cmd"}, "v", delay)
	hs.eventtap.keyStroke({}, "return", delay) -- just in case it popped up a dialog
end

function choose_vcl()
	local files = hs.dialog.chooseFileOrFolder("Choose Vordio Change List (*.vcl)", default_folder, true, false, false, {"vcl"})

	if files ~= nil then
		local url = nil
		for k, v in pairs(files) do
			url = v
		end

		return hs.http.urlParts(url)["fileSystemRepresentation"]
	else
		return nil
	end
end

function addHours(timecode, hours)
	local h = tonumber(string.sub(timecode, 1, 2)) + hours
	local hh = string.format("%02d", h)
	return hh .. string.sub(timecode, 3, 11)
end

function apply_vcl(name, bundle, apply_move_fn)
	local app = hs.application.find(bundle)

	if not app then
		hs.alert.show(name .. " not running")
		return
	end

	local file = choose_vcl()

	if file then
		app:activate(false)

		hs.timer.doAfter(1, 
			function() 
				local moves = {}

				local high_src = nil -- highest source hour
				local low_dest = nil -- lowest destination hour

				-- find and analyse all moves in the file
				for line in io.lines(file) do
					local words = split(line, "%s+")

					if words then
						local command = words[1]
						if command == "MOVE" then
							local move = { srcIn = words[2], srcOut = words[3], destIn = words[4], destOut = words[5] }
							table.insert(moves, move)

							local s = tonumber(string.sub(move.srcOut, 1, 2))
							local d = tonumber(string.sub(move.destIn, 1, 2))

							if high_src == nil then
								high_src = s
							else
								if s > high_src then
									high_src = s
								end
							end

							if low_dest == nil then
								low_dest = d
							else
								if d < low_dest then
									low_dest = d
								end
							end
						end
					end
				end

				if moves then
					-- avoid copy/paste conflicts by applying an hour shift if necessary
					hour_shift = high_src - low_dest + 1

					hs.alert.show("hour shift = " .. tostring(hour_shift))

					-- now apply all the moves
					for k, m in pairs(moves) do 
						-- add hour shift to destination to avoid potential conflicts
						apply_move_fn(m.srcIn, m.srcOut, addHours(m.destIn, hour_shift), addHours(m.destOut, hour_shift))
					end
				end				
			end
		)
	end
end                  

function init()
	hs.accessibilityState(true)

	menu_change_list = hs.menubar.new()
	menu_change_list:setTitle("Vordio Change Lists")

	menu_pt_apply_vcl = { title = "Protools", fn = function() apply_vcl("ProTools", "com.avid.ProTools", pt_apply_move) end } 
	menu_s1_apply_vcl = { title = "Studio One", fn = function() apply_vcl( "Studio One", "com.presonus.studioone2", s1_apply_move) end  } 
	menu_dp_apply_vcl = { title = "Digital Performer", fn = function() apply_vcl("Digital Performer", "com.motu.DigitalPerformer", dp_apply_move) end } 
	menu_lp_apply_vcl = { title = "Logic Pro X", fn = function() apply_vcl("Logic Pro X", "com.apple.logic10", lp_apply_move) end }

	menu_table = { menu_pt_apply_vcl, menu_s1_apply_vcl, menu_dp_apply_vcl, menu_lp_apply_vcl }

	menu_change_list:setMenu(menu_table)
end

init()