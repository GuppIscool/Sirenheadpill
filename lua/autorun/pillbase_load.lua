PillBase = PillBase or {}
PillBase.Version = "1.0.0"

local function LoadFile(path)
	local prefix = string.lower(string.GetFileFromFilename(path))

	if string.StartWith(prefix, "sv_") then
		if SERVER then include(path) end
	elseif string.StartWith(prefix, "cl_") then
		if SERVER then
			AddCSLuaFile(path)
		else
			include(path)
		end
	else
		if SERVER then AddCSLuaFile(path) end
		include(path)
	end
end

local function LoadDirectory(dir)
	local files, dirs = file.Find(dir .. "/*", "LUA")

	for _, name in ipairs(files) do
		if string.GetExtensionFromFilename(name) == "lua" then
			LoadFile(dir .. "/" .. name)
		end
	end

	for _, name in ipairs(dirs) do
		LoadDirectory(dir .. "/" .. name)
	end
end

LoadFile("pillbase/sh_pillbase.lua")
LoadFile("pillbase/sv_pillbase.lua")
LoadFile("pillbase/cl_pillbase.lua")

-- Every file in lua/pillbase/pills/ is a pill definition.
LoadDirectory("pillbase/pills")

PillBase.RegisterEntities()
