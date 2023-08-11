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
                  self.Entity:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
                  self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
                  self.Entity:SetSolid(SOLID_VPHYSICS)
                  self.Entity:PhysicsInit(SOLID_VPHYSICS)
                  self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
         end
         self.ExplodeTimer = CurTime() + 2
end

function ENT:Think()
         if SERVER and self.ExplodeTimer<=CurTime() then
                  self.Entity:Remove()
         end
end

function ENT:PhysicsCollide(data)
         if SERVER and data.Speed>150 then
                  self.Entity:EmitSound("Flashbang.Bounce")
         end
end

function ENT:OnRemove()
         if SERVER then
                  self.Entity:EmitSound("Flashbang.Explode")
         end
         if CLIENT then
                  local light = DynamicLight(self:EntIndex())
                  light.Pos=self:GetPos()
                  light.r = 255
                  light.g = 255
                  light.b = 255
                  light.Brightness = 5
                  light.Size = 512
                  light.Decay = 1000
                  light.DieTime=CurTime() + 0.1
         end
         for _, pl in pairs(player.GetAll()) do
                  local tracedata={}
                  tracedata.start=self:GetPos()
                  tracedata.endpos=pl:GetShootPos()
                  tracedata.filter=pl
                  local tr=util.TraceLine(tracedata)
                  if !tr.HitWorld then
                           local timer = 4096 / pl:GetShootPos():Distance(self:GetPos())
                           if timer > 7 then
                                    timer = 7
                           end
                           if timer < 1 then
                                    timer = 0
                           end
                           pl:SetNWFloat("FlashTimer", CurTime()+timer)
                  end
         end
end

if CLIENT then
         function Flash()
                  if LocalPlayer():GetNWFloat("FlashTimer") > CurTime() then
                           DrawMotionBlur(0, 1 - (CurTime() - LocalPlayer():GetNWFloat("FlashTimer") + 7) / 7, 0)
                           local alpha
                           if LocalPlayer():GetNWFloat("FlashTimer") - CurTime() >= 7 then
                                    alpha = 255
                           end
                           if LocalPlayer():GetNWFloat("FlashTimer")-CurTime()<7 then
                                    alpha = (1 - (CurTime() - LocalPlayer():GetNWFloat("FlashTimer") + 7) / 7) * 255
                           end
                           surface.SetDrawColor(255, 255, 255, math.Round(alpha))
                           surface.DrawRect(0, 0, ScrW(), ScrH())
                  end
         end
         hook.Add("HUDPaint", "Flash", Flash)
end