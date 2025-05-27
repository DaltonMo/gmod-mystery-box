include("shared.lua")

function ENT:Draw()
  self:DrawModel()

  local pos = self:GetPos() + Vector(0, 0, 30)
  local ang = Angle(0, CurTime() * 30 % 360, 90)

  cam.Start3D2D(pos, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
    draw.SimpleTextOutlined("Mystery Box\nPress 'E' to use", "DermaLarge", -90, 90, Color(0, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
  cam.End3D2D()
end
