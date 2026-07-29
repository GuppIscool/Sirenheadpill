AddCSLuaFile()

if SERVER then return end

surface.CreateFont("SirenHeadTitle", {
    font = "Roboto",
    size = 22,
    weight = 700
})

surface.CreateFont("SirenHeadText", {
    font = "Roboto",
    size = 18,
    weight = 500
})

local red = Color(200, 45, 45)
local dim = Color(150, 150, 150)
local white = Color(235, 235, 235)

--- Returns the label, its colour and how "charged" the ability is (0-1).
local function AbilityState(ply, endKey, cooldownKey, cooldownLength)
    local endsAt = endKey and ply:GetNWFloat(endKey, 0) or 0

    if endsAt > CurTime() then
        return "ACTIVE " .. math.ceil(endsAt - CurTime()) .. "s", red, 1
    end

    local ready = ply:GetNWFloat(cooldownKey, 0)

    if ready > CurTime() then
        local left = ready - CurTime()

        return math.ceil(left) .. "s", dim, 1 - left / cooldownLength
    end

    return "READY", white, 1
end

local function DrawRow(x, y, w, key, name, state, colour, fraction)
    draw.RoundedBox(4, x, y, 30, 22, Color(35, 35, 35, 230))
    draw.SimpleText(key, "SirenHeadText", x + 15, y + 11, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(name, "SirenHeadText", x + 38, y + 11, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(state, "SirenHeadText", x + w, y + 11, colour, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if fraction < 1 then
        draw.RoundedBox(0, x, y + 24, w, 2, Color(60, 60, 60, 200))
        draw.RoundedBox(0, x, y + 24, w * fraction, 2, red)
    end
end

hook.Add("HUDPaint", "SirenHead.AbilityHUD", function()
    local ply = LocalPlayer()

    if not SirenHead.IsSiren(ply) then return end

    local w, h = 260, 178
    local x, y = ScrW() - w - 24, ScrH() - h - 24

    draw.RoundedBox(6, x, y, w, h, Color(15, 15, 15, 200))
    draw.RoundedBox(0, x, y, w, 3, red)
    draw.SimpleText("SIREN HEAD", "SirenHeadTitle", x + 12, y + 22, red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local rowX, rowW = x + 12, w - 24
    local rageState, rageColour, rageFraction = AbilityState(ply, "SirenRageEnd", "SirenRageCooldown", SirenHead.RageCooldown)
    local radius = SirenHead.SonarRadius()
    local sonarState, sonarColour, sonarFraction

    if radius then
        sonarState, sonarColour, sonarFraction = "SCANNING " .. math.floor(radius / 16) .. "m", red, 1
    else
        sonarState, sonarColour, sonarFraction = AbilityState(ply, nil, "SirenSonarCooldown", SirenHead.SonarCooldown)
    end

    DrawRow(rowX, y + 46, rowW, "R", "Rage", rageState, rageColour, rageFraction)
    DrawRow(rowX, y + 78, rowW, "E", "Sonar", sonarState, sonarColour, sonarFraction)
    DrawRow(rowX, y + 110, rowW, "M1", "Melee", "", white, 1)
    DrawRow(rowX, y + 142, rowW, "M2", "Siren", "", white, 1)
end)
