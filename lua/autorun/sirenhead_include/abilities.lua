AddCSLuaFile()

SirenHead = SirenHead or {}

SirenHead.PillName = "sirenhead"

SirenHead.Walk = 220
SirenHead.Run = 650

SirenHead.RageDuration = 12
SirenHead.RageCooldown = 40
SirenHead.RageWalk = 400
SirenHead.RageRun = 1000

SirenHead.SonarGrowth = 260		-- units per second the ring expands
SirenHead.SonarMaxRadius = 3000	-- ring stops growing (and the sonar ends) here
SirenHead.SonarCooldown = 30
SirenHead.SonarHighlight = 10	-- seconds a detected target stays highlighted

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

    -- Rage --------------------------------------------------------------

    function SirenHead.StopRage(ply, ent, skipCooldown)
        if not ply.SirenRageEnd then return end

        ply.SirenRageEnd = nil

        if IsValid(ent) then
            ent.forceAnimSet = nil
        end

        if not IsValid(ply) then return end

        ply:SetNWFloat("SirenRageEnd", 0)

        if not skipCooldown then
            ply.SirenRageCooldown = CurTime() + SirenHead.RageCooldown
            ply:SetNWFloat("SirenRageCooldown", ply.SirenRageCooldown)
        end

        ply:SetWalkSpeed(SirenHead.Walk)
        ply:SetRunSpeed(SirenHead.Run)
    end

    function SirenHead.StartRage(ply, ent)
        if ply.SirenRageEnd then return end
        if (ply.SirenRageCooldown or 0) > CurTime() then return end

        ply.SirenRageEnd = CurTime() + SirenHead.RageDuration
        ent.forceAnimSet = "rage"
        ent:PillSound("rage")
        ply:SetNWFloat("SirenRageEnd", ply.SirenRageEnd)
        ply:SetWalkSpeed(SirenHead.RageWalk)
        ply:SetRunSpeed(SirenHead.RageRun)
    end

    -- Sonar -------------------------------------------------------------

    function SirenHead.StopSonar(ply, skipCooldown)
        if not ply.SirenSonar then return end

        ply.SirenSonar = nil

        if not IsValid(ply) then return end

        ply:Freeze(false)
        ply:SetNWFloat("SirenSonarStart", 0)

        if not skipCooldown then
            ply.SirenSonarCooldown = CurTime() + SirenHead.SonarCooldown
            ply:SetNWFloat("SirenSonarCooldown", ply.SirenSonarCooldown)
        end

        SendState(ply, false)
    end

    function SirenHead.StartSonar(ply, ent)
        if ply.SirenSonar then
            SirenHead.StopSonar(ply)

            return
        end

        if (ply.SirenSonarCooldown or 0) > CurTime() then return end

        ply.SirenSonar = {
            start = CurTime(),
            origin = ply:GetPos(),
            found = {},
            nextScan = 0
        }

        ply:Freeze(true)
        ply:SetNWFloat("SirenSonarStart", CurTime())
        ent:PillSound("siren")
        SendState(ply, true, ply:GetPos())
    end

    local function IsTarget(ent, ply)
        if ent == ply or not IsValid(ent) then return false end

        if ent:IsPlayer() then
            return ent:Alive() and not SirenHead.IsSiren(ent)
        end

        return ent:IsNPC() or ent:IsNextBot()
    end

    local function Scan(ply, sonar, radius)
        local found = {}

        for _, target in ipairs(ents.FindInSphere(sonar.origin, radius)) do
            if IsTarget(target, ply) and not sonar.found[target] then
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

    -- Keys / think --------------------------------------------------------

    hook.Add("KeyPress", "SirenHead.AbilityKeys", function(ply, key)
        if key ~= IN_USE then return end
        if not SirenHead.IsSiren(ply) then return end

        SirenHead.StartSonar(ply, pk_pills.getMappedEnt(ply))
    end)

    hook.Add("Think", "SirenHead.AbilityThink", function()
        for _, ply in ipairs(player.GetAll()) do
            local ent = pk_pills.getMappedEnt(ply)
            local siren = SirenHead.IsSiren(ply) and ply:Alive()

            if ply.SirenRageEnd then
                if not siren or CurTime() >= ply.SirenRageEnd then
                    SirenHead.StopRage(ply, ent, not siren)
                else
                    -- The base rewrites speeds on its own, so keep forcing ours.
                    ply:SetWalkSpeed(SirenHead.RageWalk)
                    ply:SetRunSpeed(SirenHead.RageRun)
                end
            end

            local sonar = ply.SirenSonar

            if sonar then
                local radius = (CurTime() - sonar.start) * SirenHead.SonarGrowth

                if not siren or radius >= SirenHead.SonarMaxRadius then
                    SirenHead.StopSonar(ply)
                elseif CurTime() >= sonar.nextScan then
                    sonar.nextScan = CurTime() + .25

                    Scan(ply, sonar, radius)
                end
            end
        end
    end)

    local function Cleanup(ply)
        SirenHead.StopSonar(ply, true)
        SirenHead.StopRage(ply, pk_pills.getMappedEnt(ply), true)
    end

    hook.Add("PlayerDeath", "SirenHead.AbilityCleanup", Cleanup)
    hook.Add("PlayerSpawn", "SirenHead.AbilityCleanup", Cleanup)

    hook.Add("PlayerDisconnected", "SirenHead.AbilityCleanup", function(ply)
        ply.SirenSonar = nil
        ply.SirenRageEnd = nil
    end)

    return
end

-- Client ------------------------------------------------------------------

local sonar = nil

SirenHead.Highlighted = SirenHead.Highlighted or {}

local highlighted = SirenHead.Highlighted

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

--- Current sonar ring radius, or nil when no sonar is running.
function SirenHead.SonarRadius()
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

    local radius = SirenHead.SonarRadius()

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
            render.DrawBeam(prev, point, 16, 0, 1, colour)
        end

        prev = point
    end
end)

--- Live list of highlighted targets, pruned of dead/expired entries.
function SirenHead.HighlightTargets()
    local targets = {}

    for target, expiry in pairs(highlighted) do
        if not IsValid(target) or CurTime() > expiry then
            highlighted[target] = nil
        else
            table.insert(targets, target)
        end
    end

    return targets
end

hook.Add("PreDrawHalos", "SirenHead.SonarHalos", function()
    local targets = SirenHead.HighlightTargets()

    if #targets == 0 then return end

    halo.Add(targets, Color(255, 60, 60), 6, 6, 2, true, false)
end)

hook.Add("HUDPaint", "SirenHead.SonarMarkers", function()
    for _, target in ipairs(SirenHead.HighlightTargets()) do
        local pos = (target:WorldSpaceCenter() + Vector(0, 0, 40)):ToScreen()

        if pos.visible then
            local dist = math.Round(LocalPlayer():GetPos():Distance(target:GetPos()) / 16)
            local name = target:IsPlayer() and target:Nick() or target:GetClass()

            draw.SimpleTextOutlined(name .. "  " .. dist .. "m", "DermaDefaultBold", pos.x, pos.y, Color(255, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        end
    end
end)
