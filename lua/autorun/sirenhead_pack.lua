AddCSLuaFile()

-- Requires Parakeet's Pill Pack Base (Revised): https://github.com/Setnour6/PillPackBaseRevised
if not file.Exists("includes/modules/pk_pills.lua", "LUA") then
	print("[Siren Head Pills] Pill Pack Base is not installed, the pack will not load.")

	return
end

require("pk_pills")

pk_pills.packStart("Siren Head", "sirenhead", "pills/sirenhead.png")

include("sirenhead_include/pill_sirenhead.lua")
