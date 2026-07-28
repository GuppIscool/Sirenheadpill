ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Pill"
ENT.Category = "Pills"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

-- Set on the generated child entities, see PillBase.RegisterEntities.
ENT.PillID = nil

function ENT:GetPill()
	return PillBase.Get(self.PillID) or PillBase.GetByClass(self:GetClass())
end
