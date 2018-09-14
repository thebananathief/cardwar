include("shared.lua")

//language.Add("ENTER NAME", "ENTER NAME")

function ENT:Draw()
  self:DrawModel()
end
function ENT:HUDPaint()
  cam.Start3D2D(self.GetPos() + Vector(0, 0, 70), Angle(0, 0, 0), 50)
    surface.SetDrawColor(Color(0, 0, 0, 50))
    surface.DrawRect(0, 0, 200, 5)
    surface.SetDrawColor(Color(255, 0, 0, 200))
    surface.DrawRect(0, 0, 200, 5)
  cam.End3D2D()
end
