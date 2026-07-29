AddCSLuaFile()

pk_pills.register("sirenhead", {
    printName = "Siren Head",
    side = "wild",
    type = "ply",
    model = "models/ametryx/master.mdl",
    default_rp_cost = 15000,
    health = 750,
    modelScale = .35,
    -- Tune these to the model: hull is the collision box size, duckBy is how much it shrinks when ducking.
    hull = Vector(28, 28, 62),
    duckBy = 26,
    stepSize = 30,
    camera = {
        offset = Vector(0, 0, 150),
        dist = 260
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
        -- Swapped in by rage mode, see reload below. Idle stays upright so he
        -- only crawls while actually moving.
        rage = {
            idle = "idle",
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
        walk = SirenHead.Walk,
        run = SirenHead.Run,
        ducked = 120
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
        SirenHead.StartRage(ply, ent)
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
