-- Drop your Siren Head player/NPC model in models/ and point PILL.Model at it.
-- Until it is installed the pill falls back to a stock model so it stays usable.
local MODEL = "models/sirenhead/sirenhead.mdl"
local FALLBACK = "models/player/combine_super_soldier.mdl"

local PILL = {}

PILL.Name = "Siren Head"
PILL.Author = "GuppIscool"
PILL.Category = "Pills"
PILL.Model = util.IsValidModel(MODEL) and MODEL or FALLBACK
PILL.PillModel = "models/healthvial.mdl"

PILL.Health = 500
PILL.WalkSpeed = 140
PILL.RunSpeed = 320
PILL.JumpPower = 250
PILL.StepSize = 40
PILL.ModelScale = 1

PILL.Hull = { Vector(-24, -24, 0), Vector(24, 24, 190) }
PILL.HullDuck = { Vector(-24, -24, 0), Vector(24, 24, 100) }
PILL.ViewOffset = Vector(0, 0, 180)
PILL.ViewOffsetDucked = Vector(0, 0, 90)

PILL.ThirdPerson = true
PILL.ThirdPersonDistance = 220

PILL.TransformSound = "ambient/atmosphere/city_beacon1.wav"
PILL.RevertSound = "ambient/levels/labs/electric_explosion1.wav"

function PILL:OnTransform(ply)
	ply:SetNoCollideWithTeammates(false)
end

PillBase.Register("sirenhead", PILL)
