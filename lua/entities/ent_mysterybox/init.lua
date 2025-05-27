AddCSLuaFile()
include("shared.lua")

ENT.BoxCost = 0
ENT.Weapons = {
  "weapon_pistol",
  "weapon_smg1",
  "weapon_shotgun",
  "weapon_ar2",
  "weapon_crossbow",
  "weapon_rpg"
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
  local wep = table.Random(self.Weapons)
  ply:Give(wep)
  ply:SelectWeapon(wep)
  self:EmitSound("items/ammo_pickup.wav")
end 