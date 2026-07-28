AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	local pill = self:GetPill()

	self:SetModel(pill and pill.PillModel or "models/healthvial.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	if pill then
		util.PrecacheModel(pill.Model)
	end

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
	end
end

function ENT:Use(activator)
	if not activator:IsPlayer() then return end

	local pill = self:GetPill()

	if not pill then
		self:Remove()
		return
	end

	if PillBase.Transform(activator, pill.ID) then
		self:Remove()
	end
end
