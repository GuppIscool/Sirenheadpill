AddCSLuaFile()

SirenHead = SirenHead or {}

SirenHead.PillName = "sirenhead"
SirenHead.SonarGrowth = 220		-- units per second the ring expands
SirenHead.SonarMaxRadius = 2600	-- ring stops growing (and the sonar ends) here
SirenHead.SonarCooldown = 30
SirenHead.SonarHighlight = 8	-- seconds a detected player stays highlighted

--- True when the player is currently a Siren Head.
function SirenHead.IsSiren(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local ent = pk_pills.getMappedEnt(ply)

    return IsValid(ent) and ent.formTable and ent.formTable.name == SirenHead.PillName
end

if SERVER then
    util.AddNetworkString("sirenhead_sonar")
    util.AddNetworkString("sirenhead_sonar_ping")

    local function SendState(ply, active, origin)
        net.Start("sirenhead_sonar")
            net.WriteBool(active)

            if active then net.WriteVector(origin) end
        net.Send(ply)
    end

    function SirenHead.StopSonar(ply, skipCooldown)
        if not ply.SirenSonar then return end

        ply.SirenSonar = nil

        if IsValid(ply) then
            ply:Freeze(false)

            if not skipCooldown then
                ply.SirenSonarCooldown = CurTime() + SirenHead.SonarCooldown
            end

            SendState(ply, false)
        end
    end

    function SirenHead.StartSonar(ply, ent)
        if ply.SirenSonar then
            SirenHead.StopSonar(ply)

            return
        end

        local cooldown = (ply.SirenSonarCooldown or 0) - CurTime()

        if cooldown > 0 then
            ply:PrintMessage(HUD_PRINTCENTER, "Sonar ready in " .. math.ceil(cooldown) .. "s")

            return
        end

        ply.SirenSonar = {
            start = CurTime(),
            origin = ply:GetPos(),
            found = {},
            nextScan = 0
        }

        ply:Freeze(true)
        ent:PillAnim("idle")
        ent:PillSound("siren")
        SendState(ply, true, ply:GetPos())
    end

    local function Scan(ply, sonar, radius)
        local found = {}

        for _, target in ipairs(player.GetAll()) do
            local skip = target == ply or not target:Alive() or sonar.found[target] or SirenHead.IsSiren(target) or target:GetPos():Distance(sonar.origin) > radius

            if not skip then
                sonar.found[target] = true
                table.insert(found, target)
            end
        end

        if #found == 0 then return end

        net.Start("sirenhead_sonar_ping")
            net.WriteUInt(#found, 8)

            for _, target in ipairs(found) do
                net.WriteEntity(target)
            end
        net.Send(ply)
    end

    hook.Add("KeyPress", "SirenHead.SonarKey", function(ply, key)
        if key ~= IN_USE then return end
        if not SirenHead.IsSiren(ply) then return end

        SirenHead.StartSonar(ply, pk_pills.getMappedEnt(ply))
    end)

    hook.Add("Think", "SirenHead.SonarThink", function()
        for _, ply in ipairs(player.GetAll()) do
            local sonar = ply.SirenSonar

            if sonar then
                local radius = (CurTime() - sonar.start) * SirenHead.SonarGrowth

                if not ply:Alive() or not SirenHead.IsSiren(ply) or radius >= SirenHead.SonarMaxRadius then
                    SirenHead.StopSonar(ply)
                elseif CurTime() >= sonar.nextScan then
                    sonar.nextScan = CurTime() + .25

                    Scan(ply, sonar, radius)
                end
            end
        end
    end)

    hook.Add("PlayerDeath", "SirenHead.SonarCleanup", function(ply)
        SirenHead.StopSonar(ply, true)
    end)

    hook.Add("PlayerDisconnected", "SirenHead.SonarCleanup", function(ply)
        ply.SirenSonar = nil
    end)

    return
end

-- Client
local sonar = nil
local highlighted = {}

net.Receive("sirenhead_sonar", function()
    if not net.ReadBool() then
        sonar = nil

        return
    end

    sonar = {
        start = CurTime(),
        origin = net.ReadVector()
    }
end)

net.Receive("sirenhead_sonar_ping", function()
    local count = net.ReadUInt(8)

    for i = 1, count do
        local target = net.ReadEntity()

        if IsValid(target) then
            highlighted[target] = CurTime() + SirenHead.SonarHighlight
        end
    end

    surface.PlaySound("buttons/blip1.wav")
end)

local function GetRadius()
    if not sonar then return nil end

    local radius = (CurTime() - sonar.start) * SirenHead.SonarGrowth

    if radius >= SirenHead.SonarMaxRadius then
        sonar = nil

        return nil
    end

    return radius
end

hook.Add("PostDrawTranslucentRenderables", "SirenHead.SonarRing", function(depth, skybox)
    if depth or skybox then return end

    local radius = GetRadius()

    if not radius then return end

    local segments = 96
    local colour = Color(255, 90, 90, 255)

    render.SetColorMaterial()

    local prev = nil

    for i = 0, segments do
        local ang = math.rad(i / segments * 360)
        local point = sonar.origin + Vector(math.cos(ang) * radius, math.sin(ang) * radius, 8)

        -- Sit the ring on whatever ground is under it.
        local trace = util.QuickTrace(point + Vector(0, 0, 200), Vector(0, 0, -600))

        if trace.Hit then point.z = trace.HitPos.z + 4 end

        if prev then
            render.DrawBeam(prev, point, 12, 0, 1, colour)
        end

        prev = point
    end
end)

hook.Add("PreDrawHalos", "SirenHead.SonarHalos", function()
    local targets = {}

    for target, expiry in pairs(highlighted) do
        if not IsValid(target) or CurTime() > expiry then
            highlighted[target] = nil
        else
            table.insert(targets, target)
        end
    end

    if #targets == 0 then return end

    halo.Add(targets, Color(255, 60, 60), 3, 3, 1, true, true)
end)

hook.Add("HUDPaint", "SirenHead.SonarHUD", function()
    local radius = GetRadius()

    if not radius then return end

    draw.SimpleTextOutlined("SONAR " .. math.floor(radius), "DermaLarge", ScrW() * .5, ScrH() * .85, Color(255, 90, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
end)
