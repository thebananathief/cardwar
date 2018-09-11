include("shared.lua")

surface.CreateFont("Calibri128",{
    font = "calibri",
    size = 128,
    weight = 200,
    antialias = true,
})
surface.CreateFont("Calibri128_blur",{
    font = "calibri",
    size = 128,
    weight = 200,
    antialias = true,
    blursize = 4,
})

surface.CreateFont("Calibri32",{
  font = "calibri",
  size = 64,
  weight = 200,
  antialias = true,
})
surface.CreateFont("Calibri32_blur",{
  font = "calibri",
  size = 64,
  weight = 200,
  antialias = true,
  blursize = 4,
})

surface.CreateFont("Calibri16",{
  font = "calibri",
  size = 72,
  weight = 200,
  antialias = true,
})
surface.CreateFont("Calibri16_blur",{
  font = "calibri",
  size = 72,
  weight = 200,
  antialias = true,
  blursize = 4,
})

function ENT:Draw()
  local ply = LocalPlayer()
  local distance = ply:GetPos():Distance(self:GetPos())
  if distance >= 1024 then return else self:DrawModel() end

  local Pos = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 0)
  local planeNormal = Vector(0, 0, 0)
  local relativeEye = EyePos() - Pos
  local relativeEyeOnPlane = relativeEye - planeNormal * relativeEye:Dot(planeNormal)
  local textAng = relativeEyeOnPlane:AngleEx(planeNormal)

  textAng:RotateAroundAxis(textAng:Up(), 90)
  textAng:RotateAroundAxis(textAng:Forward(), 90)

  cam.Start3D2D(Pos, textAng, 0.02)
      surface.SetDrawColor(0, 0, 0, 200)
      surface.DrawRect(-250, -350, 500, 750)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(-230, -330, 460, 100)
    draw.DrawText(self:GetcwName(), "Calibri16_blur", 0, -320, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
    draw.DrawText(self:GetcwName(), "Calibri16", 0, -320, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
      surface.SetDrawColor(255, 255, 255, 255)
      surface.DrawRect(-210, -220, 420, 320)
    surface.SetTexture(surface.GetTextureID(self:GetcwIcon()))
    surface.DrawTexturedRect(-200, -210, 400, 300)
      surface.SetDrawColor(255, 255, 255, 255)
      surface.DrawRect(-230, 110, 460, 275)
      draw.DrawText(self:GetcwDesc(), "Calibri32_blur", -225, 100, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT)
      draw.DrawText(self:GetcwDesc(), "Calibri32", -225, 100, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT)
  cam.End3D2D()
end

function CardHover()
	local ply = LocalPlayer()
	local trace = ply:GetEyeTrace().Entity
	local text = ""
	if trace:IsValid() and trace:GetClass() == "cw_card" and trace:GetPos():Distance(ply:GetPos()) < 130 then
    if trace:GetcwHold() then
      draw.DrawText("Place this on a shelf or pedestial.", "ChatFont", (ScrW()/2), (ScrH()/2) + -110, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    else
      draw.DrawText("Press E to pick up this card.", "ChatFont", (ScrW()/2), (ScrH()/2) + -110, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end
	end
end
hook.Add("HUDPaint", "CardHover", CardHover)