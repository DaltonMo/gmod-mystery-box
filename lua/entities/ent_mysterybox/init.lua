AddCSLuaFile()
include("shared.lua")

ENT.InUse = false
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

  if self.InUse then 
    activator:ChatPrint("The mystery box is already in use.")
    return 
  end
  self.InUse = true
  self:GiveRandomWeapon(activator)
end

function ENT:AnimateWeaponRoll(ply)
    local weaponsList = self.Weapons
    local rollDuration = 5.0 -- total time for roll
    local interval = 0.2 -- how fast to cycle models
    local totalSteps = math.floor(rollDuration / interval)
    local startTime = CurTime()

    local startPos = self:GetPos() + Vector(0, 0, 10)
    local endPos   = self:GetPos() + Vector(0, 0, 35)

    -- Create floating model entity
    local modelEnt = ents.Create("prop_dynamic")
    modelEnt:SetModel("models/weapons/w_pistol.mdl") -- placeholder
    modelEnt:SetPos(startPos)
    modelEnt:SetAngles(Angle(0, 0, 0))
    modelEnt:Spawn()
    modelEnt:SetParent(nil)

    local step = 0
    local chosenWeapon = nil
    local riseTimer = "MysteryBoxRoll_" .. self:EntIndex()

    timer.Create(riseTimer, interval, totalSteps, function()
        if not IsValid(modelEnt) then return end

        step = step + 1

        -- Random weapon (until the last step)
        local weaponClass
        if step < totalSteps then
            weaponClass = table.Random(weaponsList)
        else
            weaponClass = table.Random(weaponsList)
            chosenWeapon = weaponClass
        end

        -- Update model
        local swep = weapons.GetStored(weaponClass)
        if swep and swep.WorldModel then
            modelEnt:SetModel(swep.WorldModel)
        end

        -- Spin and Rise logic
        local frac = math.Clamp((CurTime() - startTime) / rollDuration, 0, 1)
        -- Position interpolation
        local pos = LerpVector(frac, startPos, endPos)
        modelEnt:SetPos(pos)

        -- Keep model flat and aligned with box
        local boxAng = self:GetAngles()
        local displayAng = Angle(0, boxAng.yaw - 90, 0)
        modelEnt:SetAngles(displayAng)

        -- Final delivery
        if step >= totalSteps then
            timer.Simple(0.5, function()
                if IsValid(ply) then
                    ply:Give(chosenWeapon)
                    ply:SelectWeapon(chosenWeapon)
                    self:EmitSound("items/ammo_pickup.wav")
                end
                if IsValid(modelEnt) then modelEnt:Remove() end
                if IsValid(self) then self.InUse = false end
                
            end)
        end
    end)
end


function ENT:GiveRandomWeapon(ply)
  self:AnimateWeaponRoll(ply)
end
