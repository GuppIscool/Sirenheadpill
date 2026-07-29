AddCSLuaFile()

local WALK = 150
local RUN = 420

local RAGE_DURATION = 20
local RAGE_COOLDOWN = 45
local RAGE_WALK = 260
local RAGE_RUN = 700

pk_pills.register("sirenhead", {
    printName = "Siren Head",
    side = "wild",
    type = "ply",
    model = "models/ametryx/master.mdl",
    default_rp_cost = 15000,
    health = 750,
    modelScale = .7,
    -- Tune these to the model: hull is the collision box size, duckBy is how much it shrinks when ducking.
    hull = Vector(40, 40, 110),
    duckBy = 45,
    stepSize = 40,
    camera = {
        offset = Vector(0, 0, 300),
        dist = 430
    },
    seqInit = "idle",
    -- The model's own sequences: burn, crawl, ded, kill, shot, idle, injured, run, walk.
    anims = {
        default = {
            idle = "idle",
            walk = "walk",
            run = "run",
            crouch = "crawl",
            crouch_walk = "crawl",
            glide = "idle",
            jump = "idle",
            swim = "walk",
            melee = "kill",
            scream = "shot"
        },
        -- Swapped in by rage mode, see reload below.
        rage = {
            idle = "crawl",
            walk = "crawl",
            run = "crawl",
            crouch = "crawl",
            crouch_walk = "crawl",
            glide = "crawl",
            jump = "crawl",
            swim = "crawl",
            melee = "kill"
        }
    },
    moveSpeed = {
        walk = WALK,
        run = RUN,
        ducked = 90
    },
    jumpPower = 250,
    noFallDamage = true,
    attack = {
        mode = "trigger",
        delay = .45,
        range = 110,
        dmg = 45,
        func = function(ply, ent, tbl)
            if not ply:IsOnGround() then return end
            ent:PillAnim("melee", true)
            ent:PillSound("melee")

            timer.Simple(tbl.delay, function()
                if not IsValid(ent) or not IsValid(ply) then return end

                local hit = ply:TraceHullAttack(ply:GetShootPos(), ply:GetShootPos() + ply:EyeAngles():Forward() * tbl.range, Vector(-20, -20, -20), Vector(20, 20, 20), tbl.dmg, DMG_SLASH, 1, true)

                ent:PillSound(hit and "melee_hit" or "melee_miss")
                ent:PillAnim("idle")
            end)
        end
    },
    attack2 = {
        mode = "trigger",
        delay = 4,
        func = function(ply, ent)
            ent:PillAnim("scream", true)
            ent:PillSound("siren")

            timer.Simple(2, function()
                if not IsValid(ent) then return end
                ent:PillAnim("idle")
            end)
        end
    },
    -- Rage mode: R drops Siren Head onto all fours and makes it much faster.
    reload = function(ply, ent)
        if ent.raging then return end

        local cooldown = (ent.rageCooldown or 0) - CurTime()

        if cooldown > 0 then
            ply:PrintMessage(HUD_PRINTCENTER, "Rage ready in " .. math.ceil(cooldown) .. "s")

            return
        end

        ent.raging = true
        ent.forceAnimSet = "rage"
        ent:PillAnim("idle")
        ent:PillSound("rage")
        ply:SetWalkSpeed(RAGE_WALK)
        ply:SetRunSpeed(RAGE_RUN)
        ply:PrintMessage(HUD_PRINTCENTER, "RAGE")

        timer.Simple(RAGE_DURATION, function()
            if not IsValid(ent) then return end

            ent.raging = nil
            ent.forceAnimSet = nil
            ent.rageCooldown = CurTime() + RAGE_COOLDOWN
            ent:PillAnim("idle")

            if not IsValid(ply) then return end

            ply:SetWalkSpeed(WALK)
            ply:SetRunSpeed(RUN)
            ply:PrintMessage(HUD_PRINTCENTER, "Rage over")
        end)
    end,
    sounds = {
        siren = "ambient/alarms/klaxon1.wav",
        rage = "npc/strider/striderx_alert2.wav",
        melee = "npc/strider/striderx_alert2.wav",
        melee_hit = pk_pills.helpers.makeList("npc/zombie/claw_strike#.wav", 3),
        melee_miss = pk_pills.helpers.makeList("npc/zombie/claw_miss#.wav", 2),
        step = pk_pills.helpers.makeList("npc/strider/strider_step#.wav", 6)
    }
})
