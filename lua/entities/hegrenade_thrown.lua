AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = ""
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Counter-Strike: Source"

function ENT:Draw()
         self.Entity:DrawModel()
end

function ENT:Initialize()
         if SERVER then
                  self.Entity:SetModel("models/weapons/w_eq_fraggrenade_thrown.mdl")
                  self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
                  self.Entity:SetSolid(SOLID_VPHYSICS)
                  self.Entity:PhysicsInit(SOLID_VPHYSICS)
                  self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
         end
         self.ExplodeTimer = CurTime() + 2
end

function ENT:Think()
         if SERVER and self.ExplodeTimer <= CurTime() then
                  self.Entity:Remove()
         end
end

function ENT:PhysicsCollide(data)
         if SERVER and data.Speed > 150 then
                  self.Entity:EmitSound("HEGrenade.Bounce")
         end
end

function ENT:OnRemove()
         if SERVER then
                  local explode=ents.Create("env_explosion")
                  explode:SetOwner(self.Owner)
                  explode:SetPos(self:GetPos())
                  explode:Spawn()
                  explode:Fire("Explode", 0, 0)
         end
         util.BlastDamage(self, self.Owner, self:GetPos(), 384, 98)
end