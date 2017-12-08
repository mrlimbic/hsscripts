
local default_folder = "~/Desktop"
local delay = 1000000

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
	-- setLoopStart=ALT-NUMPAD1
	hs.eventtap.keyStroke({ "alt" }, "pad1")
end

function s1_loopEnd()
	-- setLoopEnd=ALT-NUMPAD2
	hs.eventtap.keyStroke({ "alt" }, "pad2")
end

function s1_selectAllInLoop()
	-- selectAllInLoop=ALT-L
	hs.eventtap.keyStroke({"alt"}, "l")
end

function s1_splitLoop()
	-- splitLoop=CMD-SHIFT-X
	hs.eventtap.keyStroke({"cmd", "shift"}, "x")
end

function s1_setMarker()
	-- setMarker=Y
	hs.eventtap.keyStrokes("y")
end

function standard_copy()
	-- copy=CMD-C
	hs.eventtap.keyStroke({"cmd"}, "c", delay)
end

function standard_paste()
	-- paste=CMD-V
	hs.eventtap.keyStroke({"cmd"}, "v", delay)
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
	s1_setMarker()
	standard_paste()

	-- create marker at end on new range
	--s1_goto(destOut)
	--s1_setMarker()
end

function pt_goto(timecode)
	hs.eventtap.keyStroke({}, "pad*")
	hs.eventtap.keyStrokes(timecode)
	hs.eventtap.keyStroke({}, "return")
end

function pt_selectRange(tc_in, tc_out)
	hs.eventtap.keyStroke({"alt"}, "pad/")
	hs.eventtap.keyStrokes(tc_in)
	hs.eventtap.keyStroke({"alt"}, "pad/")
	hs.eventtap.keyStrokes(tc_out)
	hs.eventtap.keyStroke({}, "return")
end

function pt_apply_move(srcIn, srcOut, destIn, destOut)
	pt_selectRange(srcIn, srcOut)
	standard_copy()
	pt_goto(destIn)
	standard_paste()
end

function choose_vcl()
	local files = hs.dialog.chooseFileOrFolder("Choose Vordio Change List (*.vcl)", default_folder, true, false, false, {"vcl"})

	if files ~= nil then
		local url = nil
		for k, v in pairs(files) do
			url = v
		end

		local file = hs.http.urlParts(url)["fileSystemRepresentation"]

		return file
	else
		return nil
	end
end

function s1_apply_vcl()
	local s1 = hs.application.find("com.presonus.studioone2")

	if not s1 then
		hs.alert.show("Studio One not running")
		return
	end

	local file = choose_vcl()

	if file then
		s1:activate(false) -- do we need all windows or just main?
		hs.timer.doAfter(1, function() apply_vcl(file, s1_apply_move) end)
	end
end

function pt_apply_vcl()
  	--com.avid.ProTools
  	local pt = hs.application.find("com.avid.ProTools")

	if not pt then
		hs.alert.show("Protools not running")
		return
	end

	local file = choose_vcl()

	if file then
		pt:activate(false)
		hs.timer.doAfter(1, function() apply_vcl(file, pt_apply_move) end)
	end

end

function apply_vcl(file, apply_move_fn)
	for line in io.lines(file) do
		local words = split(line, "%s+")
		if words then
			local command = words[1]
			if command == "MOVE" then
				hs.alert.show(line)
				srcIn = words[2]
				srcOut = words[3]
				destIn = words[4]
				destOut = words[5]
				apply_move_fn(srcIn, srcOut, destIn, destOut)
			end
		end
	end
end                  

function init()
	hs.accessibilityState(true)

	menu_change_list = hs.menubar.new()
	menu_change_list:setTitle("Vordio Change Lists")

	menu_pt_apply_vcl = { title = "Protools", fn = pt_apply_vcl } 
	menu_s1_apply_vcl = { title = "Studio One", fn = s1_apply_vcl } 

	menu_table = { menu_pt_apply_vcl, menu_s1_apply_vcl }

	menu_change_list:setMenu(menu_table)
end

init()



