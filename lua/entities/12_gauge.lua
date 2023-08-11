AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "12 Gauge"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Counter-Strike: Source"
ENT.AmmoType = "12 Gauge"
ENT.AmmoAmount = "8"
ENT.AmmoModel = "models/items/boxbuckshot.mdl"

function ENT:Initialize()
         if SERVER then
                  self:SetModel(self.AmmoModel)
                  self:PhysicsInit(SOLID_VPHYSICS)
                  self:SetMoveType(MOVETYPE_VPHYSICS)
                  self:SetSolid(SOLID_VPHYSICS)
                  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                  self:SetTrigger(true)
                  self:UseTriggerBounds(true, 24)
                  local phys=self:GetPhysicsObject()
                  if phys:IsValid() then
                           phys:Wake()
                           phys:SetBuoyancyRatio(0)
                  end
         end
end

if CLIENT then
         language.Add("12 Gauge_ammo", "12 Gauge")
end

function ENT:Use(activator, caller)
         if SERVER then
                  if activator:IsPlayer() then
                           if self.IsBeingHeld then
                                    activator:DropObject(self)
                                    self.IsBeingHeld = false
                           else
                                    activator:PickupObject(self)
                                    self.IsBeingHeld = true
                           end
                  end
         end
end

function ENT:Touch(activator)
         if (activator:IsPlayer()) then
                  activator:GiveAmmo(self.AmmoAmount, self.AmmoType)
                  self:Remove()
         end
end

function ENT:Draw()
         if CLIENT then
                  self:DrawModel()
         end
end