include("shared.lua")

function ENT:Draw()
  local ply = LocalPlayer()
  local distance = ply:GetPos():Distance(self:GetPos())
  if distance >= 1024 then return else self:DrawModel() end
end

function ShelfHover()
	local ply = LocalPlayer()
	local trace = ply:GetEyeTrace().Entity
	local text = "Place a card on this."
	if trace:IsValid() and trace:GetClass() == "cw_shelf" and trace:GetPos():Distance(ply:GetPos()) < 130 then
    draw.DrawText(text, "ChatFont", (ScrW()/2), (ScrH()/2) + -110, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	end
end
hook.Add("HUDPaint", "ShelfHover", ShelfHover)