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
                  self.Entity:SetModel("models/weapons/w_eq_smokegrenade_thrown.mdl")
                  self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
                  self.Entity:SetSolid(SOLID_VPHYSICS)
                  self.Entity:PhysicsInit(SOLID_VPHYSICS)
                  self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
         end
         self.Collide = 0
         self.Smoke = 0
         self.SmokeTimer = CurTime()
         self.Explode = 0
         self.ExplodeTimer = CurTime() + 2
end

function ENT:Think()
         if self.Explode == 0 and self.ExplodeTimer <= CurTime() and self.Entity:GetVelocity():Length() < 50 then
                  if SERVER then
                           self.Entity:EmitSound("BaseSmokeEffect.Sound")
                  end
                  self.Smoke = 1
                  self.SmokeTimer=CurTime() + 20
                  self.Explode = 1
         end
         if self.Smoke == 1 and self.SmokeTimer > CurTime() then
                  EffectData():SetOrigin(self:GetPos())
                  util.Effect("env_particlesmokegrenade", EffectData())
         end
end

function ENT:PhysicsCollide(data)
         if SERVER and data.Speed > 150 then
                  self.Entity:EmitSound("SmokeGrenade.Bounce")
         end
end