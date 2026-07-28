include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	local ply = LocalPlayer()

	if not IsValid(ply) then return end

	local pos = self:GetPos()

	if pos:DistToSqr(ply:EyePos()) > 40000 then return end

	local pill = self:GetPill()

	if not pill then return end

	cam.Start3D2D(pos + Vector(0, 0, 12), Angle(0, ply:EyeAngles().y - 90, 90), 0.1)
		draw.SimpleTextOutlined(pill.Name, "DermaLarge", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
	cam.End3D2D()
end
