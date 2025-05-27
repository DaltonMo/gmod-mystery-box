AddCSLuaFile()
include("shared.lua")

ENT.BoxCost = 0
ENT.Weapons = {
  "bo2r_b23r",
  "bo2r_hamr",
  "bo2r_m27",
  "bo2r_mp7",
  "bo2r_peacekeeper",
  "bo2r_870mcs",
  "bo2r_svu"
}

function ENT:Initialize()
  self:SetModel("models/props_junk/wood_crate002a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)

  local phys = self:GetPhysicsObject()
  if IsValid(phys) then phys:Wake() end
end

function ENT:Use(activator)
  if not IsValid(activator) or not activator:IsPlayer() then return end

  self:GiveRandomWeapon(activator)
end

function ENT:GiveRandomWeapon(ply)
  if not IsValid(ply) then return end

  local pos = self:GetPos() + Vector(0, 0, 40)
  local spinTime = 2.0
  local interval = 0.1
  local rollCount = math.floor(spinTime / interval)

  local modelEnt = ents.Create("prop_dynamic")
  modelEnt:SetModel("models/weapons/w_pistol.mdl")
  modelEnt:SetPos(pos)
  modelEnt:Spawn()
  modelEnt:SetParent(self)

  local currentIndex = 0
  local weaponsList = self.Weapons
  local chosenWeapon = nil 

  local function SpinWeapon()
    currentIndex = currentIndex + 1
    local weaponClass = table.Random(weaponsList)
    chosenWeapon = weaponClass

    local swep = weapons.GetStored(weaponClass)
    if swep and swep.WorldModel then
      modelEnt:SetModel(swep.WorldModel)
    end

    local angle = self:GetAngles()
    angle:RotateAroundAxis(self:GetUp(), 270)
    modelEnt:SetAngles(angle)

    if currentIndex >= rollCount then
      timer.Remove("MysteryBoxSpin_" .. self:EntIndex())

      timer.Simple(0.5, function() 
        if IsValid(ply) then
          ply:Give(chosenWeapon)
          ply:SelectWeapon(chosenWeapon)
          self:EmitSound("items/ammo_pickup.wav")
        end
        if IsValid(modelEnt) then modelEnt:Remove() end
      end)
    end
  end

  timer.Create("MysteryBoxSpin_" .. self:EntIndex(), interval, rollCount, SpinWeapon)
end 