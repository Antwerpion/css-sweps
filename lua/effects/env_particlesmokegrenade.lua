function EFFECT:Init(data)
         emitter = ParticleEmitter(data:GetOrigin())
         local particle=emitter:Add("particle/particle_smokegrenade1", data:GetOrigin())
         particle:SetDieTime(2)
         particle:SetStartAlpha(255)
         particle:SetEndAlpha(0)
         particle:SetStartSize(128)
         particle:SetEndSize(192)
         particle:SetVelocity(Vector(math.Rand(-96, 96), math.Rand(-96, 96), math.Rand(-96, 96)))
         particle:SetColor(150, 150, 150)
         particle:SetCollide(true)
         particle:SetBounce(1)
         emitter:Finish()
end

function EFFECT:Render()
end