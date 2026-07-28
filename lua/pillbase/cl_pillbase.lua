local thirdPerson = CreateClientConVar("pillbase_thirdperson", "1", true, false, "Use third person while transformed by a pill.")

net.Receive("PillBase_Notify", function()
	chat.AddText(Color(255, 120, 120), "[Pills] ", Color(255, 255, 255), net.ReadString())
end)

hook.Add("CalcView", "PillBase.ThirdPerson", function(ply, origin, angles, fov)
	if not thirdPerson:GetBool() then return end
	if not PillBase.IsTransformed(ply) then return end
	if not ply:GetNWBool("PillBase_ThirdPerson", false) then return end

	local distance = ply:GetNWFloat("PillBase_ThirdPersonDistance", 120)

	local trace = util.TraceHull({
		start = origin,
		endpos = origin - angles:Forward() * distance,
		filter = ply,
		mins = Vector(-4, -4, -4),
		maxs = Vector(4, 4, 4),
		mask = MASK_SOLID_BRUSHONLY,
	})

	return {
		origin = trace.HitPos + trace.HitNormal * 4,
		angles = angles,
		fov = fov,
		drawviewer = true,
	}
end)

-- The world model is drawn in third person, so hide the view model.
hook.Add("PreDrawViewModel", "PillBase.HideViewModel", function(_, ply)
	if not thirdPerson:GetBool() then return end
	if not PillBase.IsTransformed(ply) then return end
	if not ply:GetNWBool("PillBase_ThirdPerson", false) then return end

	return true
end)
