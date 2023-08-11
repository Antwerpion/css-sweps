if CLIENT then
         SWEP.BounceWeaponIcon = false
         SWEP.DrawWeaponInfoBox = false
         surface.CreateFont( "CSSelectIcons",
         {
                  font = "counter-strike",
                  size = 144,
                  weight = 0
         } )
         surface.CreateFont( "CSKillIcons",
         {
                  font = "csd",
                  size = 48,
                  weight = 0
         } )
         killicon.AddFont( "knife", "CSKillIcons", "j", Color( 255, 80, 0, 255 ) )
end

SWEP.PrintName = "Knife"
SWEP.Category = "Counter-Strike: Source"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 0
SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.UseHands = true
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.Swing = 0
SWEP.SwingTimer = CurTime()
SWEP.Melee = 0
SWEP.MeleeTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.WalkSpeed = 200
SWEP.RunSpeed = 400

SWEP.Primary.Sound = Sound( "Weapon_Knife.Slash" )
SWEP.Primary.ClipSize = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 20
SWEP.Primary.DamageAlt = 15
SWEP.Primary.Spread = 0.02
SWEP.Primary.SpreadMin = 0.02
SWEP.Primary.SpreadMove = 0.05
SWEP.Primary.SpreadAir = 0.1
SWEP.Primary.SpreadRecoveryTime = 0.3
SWEP.Primary.SpreadRecoveryTimer = CurTime()
SWEP.Primary.Delay = 0.4
SWEP.Primary.Force = 1

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Damage = 65
SWEP.Secondary.DamageAlt = 195
SWEP.Secondary.Delay = 1
SWEP.Secondary.Force = 2

function SWEP:Initialize()
         self:SetWeaponHoldType( self.HoldType )
         self.Idle = 0
         self.IdleTimer = CurTime() + 1
end

function SWEP:DrawWeaponSelection( x, y, wide, tall )
         draw.SimpleText( "J", "CSSelectIcons", x + wide / 2, y + tall / 2, Color( 255, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function SWEP:Deploy()
         self:SetWeaponHoldType( self.HoldType )
         if SERVER then
                  self.Owner:EmitSound( "Weapon_Knife.Deploy" )
         end
         self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self.Swing = 0
         self.SwingTimer = CurTime()
         self.Melee = 0
         self.MeleeTimer = CurTime()
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         self.Owner:SetWalkSpeed( self.WalkSpeed )
         self.Owner:SetRunSpeed( self.RunSpeed )
         return true
end

function SWEP:Holster()
         if ( self.Owner:IsNPC() ) then return end
         self.Swing = 0
         self.SwingTimer = CurTime()
         self.Melee = 0
         self.MeleeTimer = CurTime()
         self.Idle = 0
         self.IdleTimer = CurTime()
         self.Owner:SetWalkSpeed( 200 )
         self.Owner:SetRunSpeed( 400 )
         return true
end

function SWEP:PrimaryAttack()
         self:EmitSound( self.Primary.Sound )
         self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
         self:ShootEffects()
         self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
         self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
         self.SwingTimer = CurTime() + self.Primary.Delay * 2
         self.Melee = 1
         self.MeleeTimer = CurTime() + 0.1
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:SecondaryAttack()
         local tr = util.TraceLine( {
                  start = self.Owner:GetShootPos(),
                  endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56,
                  filter = self.Owner,
                  mask = MASK_SHOT_HULL
         } )
         if !IsValid( tr.Entity ) then
                  tr = util.TraceHull( {
                           start = self.Owner:GetShootPos(),
                           endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56,
                           filter = self.Owner,
                           mins = Vector( -16, -16, 0 ),
                           maxs = Vector( 16, 16, 0 ),
                           mask = MASK_SHOT_HULL
                  } )
         end
         if SERVER then
                  if IsValid( tr.Entity ) then
                           local dmg = DamageInfo()
                           local attacker = self.Owner
                           if !IsValid( attacker ) then
                                    attacker = self
                           end
                           dmg:SetAttacker( attacker )
                           dmg:SetInflictor( self )
                           local angle = self.Owner:GetAngles().y - tr.Entity:GetAngles().y
                           if angle < -180 then
                                    angle = 360 + angle
                           end
                           if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
                                    if angle <= 90 and angle >= -90 then
                                             dmg:SetDamage( self.Secondary.DamageAlt )
                                    else
                                             dmg:SetDamage( self.Secondary.Damage )
                                    end
                           else
                                    dmg:SetDamage( self.Secondary.Damage )
                           end
                           dmg:SetDamageType( DMG_CLUB )
                           dmg:SetDamageForce( self.Owner:GetForward() * self.Secondary.Force )
                           tr.Entity:TakeDamageInfo( dmg )
                  end
                  if tr.Hit then
                           if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
                                    self.Owner:EmitSound( "Weapon_Knife.Stab" )
                           else
                                    self.Owner:EmitSound( "Weapon_Knife.HitWall" )
                                    local trace = util.TraceLine( {
                                             start = self.Owner:GetShootPos(),
                                             endpos = self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 56,
                                             filter = self.Owner
                                    } )
                                    util.Decal( "ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal )
                           end
                  end
         end
         if !tr.Hit then
                  self:EmitSound( self.Primary.Sound )
                  self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
         end
         if tr.Hit then
                  self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
         end
         self:ShootEffects()
         self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
         self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:ShootEffects()
         self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Reload()
end

function SWEP:Think()
         if self.Swing == 1 and self.SwingTimer <= CurTime() then
                  self.Swing = 0
         end
         if self.Melee == 1 and self.MeleeTimer <= CurTime() then
                  local tr = util.TraceLine( {
                           start = self.Owner:GetShootPos(),
                           endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
                           filter = self.Owner,
                           mask = MASK_SHOT_HULL
                  } )
                  if !IsValid( tr.Entity ) then
                           tr = util.TraceHull( {
                                    start = self.Owner:GetShootPos(),
                                    endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 72,
                                    filter = self.Owner,
                                    mins = Vector( -16, -16, 0 ),
                                    maxs = Vector( 16, 16, 0 ),
                                    mask = MASK_SHOT_HULL
                           } )
                  end
                  if SERVER then
                           if IsValid( tr.Entity ) then
                                    local dmg = DamageInfo()
                                    local attacker = self.Owner
                                    if !IsValid( attacker ) then
                                             attacker = self
                                    end
                                    dmg:SetAttacker( attacker )
                                    dmg:SetInflictor( self )
                                    if self.Swing <= 0 then
                                             dmg:SetDamage( self.Primary.Damage )
                                    end
                                    if self.Swing == 1 then
                                             dmg:SetDamage( self.Primary.DamageAlt )
                                    end
                                    dmg:SetDamageType( DMG_CLUB )
                                    dmg:SetDamageForce( self.Owner:GetForward() * self.Primary.Force )
                                    tr.Entity:TakeDamageInfo( dmg )
                           end
                           if tr.Hit then
                                    if tr.Entity:IsNPC() || tr.Entity:IsPlayer() then
                                             self.Owner:EmitSound( "Weapon_Knife.Hit" )
                                    else
                                             self.Owner:EmitSound( "Weapon_Knife.HitWall" )
                                             local trace = util.TraceLine( {
                                                      start = self.Owner:GetShootPos(),
                                                      endpos = self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 72,
                                                      filter = self.Owner
                                             } )
                                             util.Decal( "ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal )
                                    end
                           end
                  end
                  if self.SwingTimer > CurTime() then
                           self.Swing = 1
                  end
                  self.Melee = 0
         end
         if self.Owner:IsOnGround() then
                  if self.Owner:GetVelocity():Length() <= 100 then
                           if self.Primary.SpreadRecoveryTimer <= CurTime() then
                                    self.Primary.Spread = self.Primary.SpreadMin
                           end
                           if self.Primary.Spread > self.Primary.SpreadMin then
                                    self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.Spread
                           end
                  end
                  if self.Owner:GetVelocity():Length() > 100 then
                           self.Primary.Spread = self.Primary.SpreadMove
                           self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
                           if self.Primary.Spread > self.Primary.SpreadMin then
                                    self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.SpreadMove
                           end
                  end
         end
         if !self.Owner:IsOnGround() then
                  self.Primary.Spread = self.Primary.SpreadAir
                  self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
                  if self.Primary.Spread > self.Primary.SpreadMin then
                           self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.SpreadAir
                  end
         end
         if self.IdleTimer <= CurTime() then
                  if self.Idle == 0 then
                           self.Idle = 1
                  end
                  if SERVER and self.Idle == 1 then
                           self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
                  end
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
end