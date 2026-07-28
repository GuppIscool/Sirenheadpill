AddCSLuaFile()

pk_pills.register("sirenhead", {
    printName = "Siren Head",
    side = "wild",
    type = "ply",
    model = "models/ametryx/master.mdl",
    default_rp_cost = 15000,
    health = 750,
    modelScale = 1,
    -- Tune these to the model: hull is the collision box size, duckBy is how much it shrinks when ducking.
    hull = Vector(40, 40, 130),
    duckBy = 50,
    stepSize = 40,
    camera = {
        offset = Vector(0, 0, 260),
        dist = 400
    },
    -- Standard Garry's Mod player model animation set.
    anims = {
        default = {
            idle = "idle_magic",
            walk = "walk_magic",
            run = "run_magic",
            crouch = "cidle_magic",
            crouch_walk = "cwalk_magic",
            glide = "jump_magic",
            jump = "jump_magic",
            swim = "swimming_magic"
        }
    },
    aim = {
        xPose = "aim_yaw",
        yPose = "aim_pitch"
    },
    moveSpeed = {
        walk = 90,
        run = 280,
        ducked = 60
    },
    movePoseMode = "yaw",
    jumpPower = 250,
    noFallDamage = true,
    attack = {
        mode = "trigger",
        delay = .45,
        range = 110,
        dmg = 45,
        func = function(ply, ent, tbl)
            if not ply:IsOnGround() then return end
            ent:PillSound("melee")

            timer.Simple(tbl.delay, function()
                if not IsValid(ent) or not IsValid(ply) then return end

                local hit = ply:TraceHullAttack(ply:GetShootPos(), ply:GetShootPos() + ply:EyeAngles():Forward() * tbl.range, Vector(-20, -20, -20), Vector(20, 20, 20), tbl.dmg, DMG_SLASH, 1, true)

                ent:PillSound(hit and "melee_hit" or "melee_miss")
            end)
        end
    },
    attack2 = {
        mode = "trigger",
        delay = 4,
        func = function(ply, ent)
            ent:PillSound("siren")
        end
    },
    sounds = {
        siren = "ambient/alarms/klaxon1.wav",
        melee = "npc/strider/striderx_alert2.wav",
        melee_hit = pk_pills.helpers.makeList("npc/zombie/claw_strike#.wav", 3),
        melee_miss = pk_pills.helpers.makeList("npc/zombie/claw_miss#.wav", 2),
        step = pk_pills.helpers.makeList("npc/strider/strider_step#.wav", 6)
    }
})
