util.AddNetworkString("PillBase_Notify")

CreateConVar("pillbase_revert_key", tostring(KEY_G), { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Key code players press to revert a pill transformation.")
CreateConVar("pillbase_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Allow players to take pills.")

local function Notify(ply, text)
	net.Start("PillBase_Notify")
		net.WriteString(text)
	net.Send(ply)
end

PillBase.Notify = Notify

local function StoreState(ply, pill)
	local state = {
		Model = ply:GetModel(),
		Skin = ply:GetSkin(),
		Bodygroups = {},
		ModelScale = ply:GetModelScale(),
		Colour = ply:GetColor(),
		Health = ply:Health(),
		MaxHealth = ply:GetMaxHealth(),
		Armour = ply:Armor(),
		WalkSpeed = ply:GetWalkSpeed(),
		RunSpeed = ply:GetRunSpeed(),
		CrouchSpeedMultiplier = ply:GetCrouchedWalkSpeed(),
		JumpPower = ply:GetJumpPower(),
		Gravity = ply:GetGravity(),
		StepSize = ply:GetStepSize(),
		ViewOffset = ply:GetViewOffset(),
		ViewOffsetDucked = ply:GetViewOffsetDucked(),
		Hull = { ply:GetHull() },
		HullDuck = { ply:GetHullDuck() },
		Weapons = nil,
	}

	for _, bodygroup in ipairs(ply:GetBodyGroups()) do
		state.Bodygroups[bodygroup.id] = ply:GetBodygroup(bodygroup.id)
	end

	if pill.StripWeapons then
		state.Weapons = {}

		for _, wep in ipairs(ply:GetWeapons()) do
			table.insert(state.Weapons, wep:GetClass())
		end

		state.ActiveWeapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil

		ply:StripWeapons()
	end

	ply.PillBase_State = state
end

--- Turns a player into a pill's model.
function PillBase.Transform(ply, id)
	if not IsValid(ply) or not ply:Alive() then return false end

	if not GetConVar("pillbase_enabled"):GetBool() then
		Notify(ply, "Pills are disabled on this server.")
		return false
	end

	local pill = PillBase.Get(id)

	if not pill then
		Notify(ply, "Unknown pill: " .. tostring(id))
		return false
	end

	if not util.IsValidModel(pill.Model) then
		Notify(ply, "The model for " .. pill.Name .. " (" .. pill.Model .. ") is missing.")
		return false
	end

	if PillBase.IsTransformed(ply) then
		PillBase.Revert(ply, true)
	end

	StoreState(ply, pill)

	ply:SetModel(pill.Model)
	ply:SetSkin(pill.Skin)
	ply:SetModelScale(pill.ModelScale, 0)

	if pill.Bodygroups then
		for bodygroup, value in pairs(pill.Bodygroups) do
			ply:SetBodygroup(bodygroup, value)
		end
	end

	if pill.Colour then ply:SetColor(pill.Colour) end

	if pill.Health then
		ply:SetMaxHealth(pill.Health)
		ply:SetHealth(pill.Health)
	end

	if pill.Armour then ply:SetArmor(pill.Armour) end
	if pill.WalkSpeed then ply:SetWalkSpeed(pill.WalkSpeed) end
	if pill.RunSpeed then ply:SetRunSpeed(pill.RunSpeed) end
	if pill.CrouchSpeedMultiplier then ply:SetCrouchedWalkSpeed(pill.CrouchSpeedMultiplier) end
	if pill.JumpPower then ply:SetJumpPower(pill.JumpPower) end
	if pill.Gravity then ply:SetGravity(pill.Gravity) end
	if pill.StepSize then ply:SetStepSize(pill.StepSize) end

	if pill.Hull then
		ply:SetHull(pill.Hull[1], pill.Hull[2])
	end

	if pill.HullDuck then
		ply:SetHullDuck(pill.HullDuck[1], pill.HullDuck[2])
	end

	if pill.ViewOffset then ply:SetViewOffset(pill.ViewOffset) end
	if pill.ViewOffsetDucked then ply:SetViewOffsetDucked(pill.ViewOffsetDucked) end

	if pill.TransformSound then ply:EmitSound(pill.TransformSound) end

	ply:SetNWBool("PillBase_Transformed", true)
	ply:SetNWString("PillBase_Pill", pill.ID)
	ply:SetNWBool("PillBase_ThirdPerson", pill.ThirdPerson)
	ply:SetNWFloat("PillBase_ThirdPersonDistance", pill.ThirdPersonDistance)

	if isfunction(pill.OnTransform) then pill:OnTransform(ply) end

	hook.Run("PillBase_PlayerTransformed", ply, pill)

	Notify(ply, "You are now " .. pill.Name .. ". Press your revert key to change back (pill_revert).")

	return true
end

--- Restores everything Transform changed.
function PillBase.Revert(ply, silent)
	if not IsValid(ply) then return false end

	local state = ply.PillBase_State

	if not state then
		ply:SetNWBool("PillBase_Transformed", false)
		return false
	end

	local pill = PillBase.GetActivePill(ply)

	ply.PillBase_State = nil

	if ply:Alive() then
		ply:SetModel(state.Model)
		ply:SetSkin(state.Skin)
		ply:SetModelScale(state.ModelScale, 0)
		ply:SetColor(state.Colour)

		for id, value in pairs(state.Bodygroups) do
			ply:SetBodygroup(id, value)
		end

		ply:SetMaxHealth(state.MaxHealth)
		ply:SetHealth(math.min(ply:Health(), state.MaxHealth))
		ply:SetArmor(state.Armour)
		ply:SetWalkSpeed(state.WalkSpeed)
		ply:SetRunSpeed(state.RunSpeed)
		ply:SetCrouchedWalkSpeed(state.CrouchSpeedMultiplier)
		ply:SetJumpPower(state.JumpPower)
		ply:SetGravity(state.Gravity)
		ply:SetStepSize(state.StepSize)
		ply:SetViewOffset(state.ViewOffset)
		ply:SetViewOffsetDucked(state.ViewOffsetDucked)
		ply:SetHull(state.Hull[1], state.Hull[2])
		ply:SetHullDuck(state.HullDuck[1], state.HullDuck[2])

		if state.Weapons then
			for _, class in ipairs(state.Weapons) do
				ply:Give(class)
			end

			if state.ActiveWeapon then ply:SelectWeapon(state.ActiveWeapon) end
		end

		if pill and pill.RevertSound and not silent then ply:EmitSound(pill.RevertSound) end
	end

	ply:SetNWBool("PillBase_Transformed", false)
	ply:SetNWString("PillBase_Pill", "")
	ply:SetNWBool("PillBase_ThirdPerson", false)

	if pill and isfunction(pill.OnRevert) then pill:OnRevert(ply) end

	hook.Run("PillBase_PlayerReverted", ply, pill)

	return true
end

concommand.Add("pill_revert", function(ply)
	if not IsValid(ply) then return end

	if not PillBase.IsTransformed(ply) then
		Notify(ply, "You have not taken a pill.")
		return
	end

	PillBase.Revert(ply)
end)

hook.Add("PlayerButtonDown", "PillBase.RevertKey", function(ply, button)
	if button ~= GetConVar("pillbase_revert_key"):GetInt() then return end
	if not PillBase.IsTransformed(ply) then return end

	PillBase.Revert(ply)
end)

hook.Add("PlayerDeath", "PillBase.Revert", function(ply)
	if PillBase.IsTransformed(ply) then PillBase.Revert(ply, true) end
end)

hook.Add("PlayerSpawn", "PillBase.Cleanup", function(ply)
	ply.PillBase_State = nil
	ply:SetNWBool("PillBase_Transformed", false)
	ply:SetNWString("PillBase_Pill", "")
	ply:SetNWBool("PillBase_ThirdPerson", false)
end)

hook.Add("PlayerDisconnected", "PillBase.Cleanup", function(ply)
	ply.PillBase_State = nil
end)
