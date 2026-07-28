AddCSLuaFile()
AddCSLuaFile("sirenhead_include/pill_sirenhead.lua")

local realm = SERVER and "server" or "client"

if SERVER then
	-- Clients joining a dedicated server need the menu icon.
	resource.AddSingleFile("materials/pills/sirenhead.png")
end

-- Requires Parakeet's Pill Pack Base (Revised): https://github.com/Setnour6/PillPackBaseRevised
local ok, err = pcall(require, "pk_pills")

if not ok or not istable(pk_pills) then
	print("[Siren Head Pills] Pill Pack Base not found on the " .. realm .. ", pack not loaded. " .. tostring(err))

	return
end

pk_pills.packStart("Siren Head", "sirenhead", "pills/sirenhead.png")

include("sirenhead_include/pill_sirenhead.lua")

print("[Siren Head Pills] Pack loaded on the " .. realm .. ".")
