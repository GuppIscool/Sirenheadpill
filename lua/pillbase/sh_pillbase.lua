PillBase = PillBase or {}
PillBase.Pills = PillBase.Pills or {}

-- Every field a pill definition may set, and what it falls back to.
PillBase.Defaults = {
	Name = "Unnamed Pill",
	Category = "Pills",
	Author = "",
	Model = "models/player/kleiner.mdl",		-- model the player turns into
	PillModel = "models/healthvial.mdl",		-- model of the spawnable pill entity
	Skin = 0,
	Bodygroups = nil,							-- { [0] = 1, [2] = 3 }
	ModelScale = 1,
	Colour = nil,								-- Color(255, 255, 255)

	Health = nil,								-- nil keeps the player's current health
	Armour = nil,
	WalkSpeed = nil,
	RunSpeed = nil,
	CrouchSpeedMultiplier = nil,
	JumpPower = nil,
	Gravity = nil,
	StepSize = nil,

	Hull = nil,									-- { Vector(-16, -16, 0), Vector(16, 16, 72) }
	HullDuck = nil,
	ViewOffset = nil,							-- Vector(0, 0, 64)
	ViewOffsetDucked = nil,

	ThirdPerson = true,							-- force third person while transformed
	ThirdPersonDistance = 120,
	ThirdPersonOffset = Vector(0, 0, 0),

	StripWeapons = false,						-- take the player's weapons while transformed
	TransformSound = nil,
	RevertSound = nil,

	OnTransform = nil,							-- function(pill, ply)
	OnRevert = nil,								-- function(pill, ply)
}

--- Registers a pill so it can be spawned in game.
-- @param id unique identifier, also used for the entity class ("pill_<id>")
-- @param pill table of options, see PillBase.Defaults
function PillBase.Register(id, pill)
	id = string.lower(id)

	pill = pill or {}
	pill.ID = id

	setmetatable(pill, { __index = PillBase.Defaults })

	PillBase.Pills[id] = pill

	return pill
end

function PillBase.Get(id)
	return id and PillBase.Pills[string.lower(id)] or nil
end

function PillBase.GetByClass(class)
	return PillBase.Get(string.match(class or "", "^pill_(.+)$"))
end

function PillBase.IsTransformed(ply)
	return IsValid(ply) and ply:GetNWBool("PillBase_Transformed", false)
end

function PillBase.GetActivePill(ply)
	if not PillBase.IsTransformed(ply) then return nil end

	return PillBase.Get(ply:GetNWString("PillBase_Pill", ""))
end

-- Creates one spawnable entity per registered pill, all sharing lua/entities/pill_base.
function PillBase.RegisterEntities()
	local function Register()
		for id, pill in pairs(PillBase.Pills) do
			local ENT = {
				Type = "anim",
				Base = "pill_base",
				PrintName = pill.Name,
				Author = pill.Author,
				Category = pill.Category,
				Spawnable = true,
				AdminOnly = false,
				Model = pill.PillModel,
				PillID = id,
			}

			scripted_ents.Register(ENT, "pill_" .. id)
		end
	end

	-- lua/entities is not guaranteed to have been loaded yet when autorun runs.
	if scripted_ents.GetStored("pill_base") then
		Register()
	else
		hook.Add("Initialize", "PillBase.RegisterEntities", Register)
	end
end
