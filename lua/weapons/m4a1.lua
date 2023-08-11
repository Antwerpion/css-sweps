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
         killicon.AddFont( "m4a1", "CSKillIcons", "w", Color( 255, 80, 0, 255 ) )
end

SWEP.PrintName = "Maverick M4A1 Carbine"
SWEP.Category = "Counter-Strike: Source"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 25
SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.UseHands = true
SWEP.HoldType = "ar2"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.Silencer = 0
SWEP.SilencerTimer = CurTime()
SWEP.ShotTimer = CurTime()
SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.Recoil = 0
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.WalkSpeed = 184
SWEP.RunSpeed = 368

SWEP.Primary.Sound = Sound( "Weapon_M4A1.Single" )
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 120
SWEP.Primary.MaxAmmo = 90
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45mm NATO"
SWEP.Primary.Damage = 33
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Spread = 0.0006
SWEP.Primary.SpreadMin = 0.0006
SWEP.Primary.SpreadMax = 0.1266
SWEP.Primary.SpreadKick = 0.007
SWEP.Primary.SpreadMove = 0.19532
SWEP.Primary.SpreadAir = 0.34151
SWEP.Primary.SpreadMinAlt = 0.00054
SWEP.Primary.SpreadMaxAlt = 0.1165
SWEP.Primary.SpreadMoveAlt = 0.18689
SWEP.Primary.SpreadAirAlt = 0.34846
SWEP.Primary.SpreadRecoveryTime = 0.37762
SWEP.Primary.SpreadRecoveryTimer = CurTime()
SWEP.Primary.Delay = 0.09
SWEP.Primary.Force = 1

SWEP.Secondary.Sound = Sound( "Weapon_M4A1.Silenced" )
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
         self:SetWeaponHoldType( self.HoldType )
         self.Silencer = 0
         self.Idle = 0
         self.IdleTimer = CurTime() + 1
end

function SWEP:DrawWeaponSelection( x, y, wide, tall )
         draw.SimpleText( "W", "CSSelectIcons", x + wide / 2, y + tall / 2, Color( 255, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function SWEP:Deploy()
         self:SetWeaponHoldType( self.HoldType )
         if self.Silencer == 0 then
                  self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         end
         if self.Silencer == 2 then
                  self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
         end
         self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         if self.Silencer == 1 then
                  self.Silencer = 0
         end
         if self.Silencer == 3 then
                  self.Silencer = 2
         end
         self.SilencerTimer = CurTime()
         self.ShotTimer = CurTime()
         self.Reloading = 0
         self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         self.Recoil = 0
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         self.Owner:SetWalkSpeed( self.WalkSpeed )
         self.Owner:SetRunSpeed( self.RunSpeed )
         return true
end

function SWEP:Holster()
         if self.Silencer == 1 then
                  self.Silencer = 0
         end
         if self.Silencer == 3 then
                  self.Silencer = 2
         end
         self.SilencerTimer = CurTime()
         self.ShotTimer = CurTime()
         self.Reloading = 0
         self.ReloadingTimer = CurTime()
         self.Recoil = 0
         self.Idle = 0
         self.IdleTimer = CurTime()
         self.Owner:SetWalkSpeed( 200 )
         self.Owner:SetRunSpeed( 400 )
         return true
end

function SWEP:PrimaryAttack()
         if ( self.Weapon:Clip1() <= 0 and self.Weapon:Ammo1() <= 0 ) || ( self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 ) then
                  if SERVER then
                           self.Owner:EmitSound( "Default.ClipEmpty_Rifle" )
                  end
                  self:SetNextPrimaryFire( CurTime() + 0.15 )
         end
         if self.Weapon:Clip1() <= 0 then
                  self:Reload()
         end
         if self.Weapon:Clip1() <= 0 || ( self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 ) then return end
         local bullet = {}
         bullet.Num = self.Primary.NumberofShots
         bullet.Src = self.Owner:GetShootPos()
         bullet.Dir = self.Owner:GetAimVector()
         bullet.Spread = Vector( self.Primary.Spread, self.Primary.Spread, 0 )
         bullet.Tracer = 0
         bullet.Distance = 8192
         bullet.Force = self.Primary.Force
         bullet.Damage = self.Primary.Damage
         bullet.AmmoType = self.Primary.Ammo
         self.Owner:FireBullets( bullet )
         if self.Silencer == 0 then
                  self:EmitSound( self.Primary.Sound )
         end
         if self.Silencer == 2 then
                  self:EmitSound( self.Secondary.Sound )
         end
         self:ShootEffects()
         self:TakePrimaryAmmo( self.Primary.TakeAmmo )
         self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
         self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
         if self.Silencer == 0 and self.Primary.Spread < self.Primary.SpreadMax then
                  self.Primary.Spread = self.Primary.Spread + self.Primary.SpreadKick
         end
         if self.Silencer == 2 and self.Primary.Spread < self.Primary.SpreadMaxAlt then
                  self.Primary.Spread = self.Primary.Spread + self.Primary.SpreadKick
         end
         self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
         self.ShotTimer = CurTime() + self.Primary.Delay
         self.ReloadingTimer = CurTime() + self.Primary.Delay
         if ( CLIENT || game.SinglePlayer() ) and IsFirstTimePredicted() then
                  if ( self.Owner:IsNPC() ) then return end
                  if self.Recoil > 3 and self.Recoil < 6 then
                           self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( self.Recoil - 6, 0, 0 ) )
                           self.Recoil = 6
                  end
                  if self.Recoil <= 3 then
                           self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( -3, 0, 0 ) )
                           self.Recoil = self.Recoil + 3
                  end
         end
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:SecondaryAttack()
         if self.Silencer == 0 then
                  self.Weapon:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
                  self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                  self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                  if IsFirstTimePredicted() then
                           self.Silencer = 1
                  end
                  self.SilencerTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                  self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                  self.Idle = 0
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         else
                  if self.Silencer == 2 then
                           self.Weapon:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
                           self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                           self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                           if IsFirstTimePredicted() then
                                    self.Silencer = 3
                           end
                           self.SilencerTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                           self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                           self.Idle = 0
                           self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                  end
         end
end

function SWEP:ShootEffects()
         if self.Silencer == 0 then
                  self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
         end
         if self.Silencer == 2 then
                  self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
         end
         self.Owner:SetAnimation( PLAYER_ATTACK1 )
         self.Owner:MuzzleFlash()
end

function SWEP:Reload()
         if self.Reloading == 0 and self.ReloadingTimer <= CurTime() and self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0 then
                  if self.Silencer == 0 then
                           self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
                  end
                  if self.Silencer == 2 then
                           self.Weapon:SendWeaponAnim( ACT_VM_RELOAD_SILENCED )
                  end
                  self.Owner:SetAnimation( PLAYER_RELOAD )
                  self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                  self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                  self.Reloading = 1
                  self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                  self.Idle = 0
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
end

function SWEP:GetCapabilities()
         -- The NPC capabilities.
         return bit.bor(CAP_WEAPON_RANGE_ATTACK1 , CAP_INNATE_RANGE_ATTACK1)
end

function SWEP:CanBePickedUpByNPCs()
         -- Weapon can be picked up by NPCs?
         return true
end

function SWEP:ShouldDropOnDie()
         -- Weapon should be dropped on death?
         return true
end

function SWEP:GetNPCRestTimes()

         -- Handles the time between bursts.
         -- First var is min, second var is max. (All in seconds)
         -- Rest time before the NPC shoots again.

         return 0.35, 0.5

end

function SWEP:GetNPCBurstSettings()

         -- Burst parameters
         -- 1st var is minimal burst number, 2nd var is maximal, 3rd var is the delay between each shots.
         -- The delay between each shots if weapon is automatic

         return 5, 15, self.Primary.Delay

end

function SWEP:GetNPCBulletSpread( proficiency )

         -- Determine the accuracy of the NPC holding the weapon. (We call that the Proficiency)
         -- The lower the var, the more accurate the NPC is. (Var in degrees)

         return 0.01

end

function SWEP:Think()
         if self.SilencerTimer <= CurTime() then
                  if self.Silencer == 1 then
                           self.Silencer = 2
                  end
                  if self.Silencer == 3 then
                           self.Silencer = 0
                  end
         end
         if ( CLIENT || game.SinglePlayer() ) and IsFirstTimePredicted() then
                  if ( self.Owner:IsNPC() ) then return end
                  if self.Recoil < 0 then
                           self.Recoil = 0
                  end
                  if self.Recoil > 0 then
                           self.Owner:SetEyeAngles( self.Owner:EyeAngles() + Angle( 0.25, 0, 0 ) )
                           self.Recoil = self.Recoil - 0.25
                  end
         end
         if self.ShotTimer > CurTime() then
                  self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
         end
         if self.Owner:IsOnGround() then
                  if self.Owner:GetVelocity():Length() <= 100 then
                           if self.Primary.SpreadRecoveryTimer <= CurTime() then
                                    if self.Silencer == 0 then
                                             self.Primary.Spread = self.Primary.SpreadMin
                                    end
                                    if self.Silencer == 2 then
                                             self.Primary.Spread = self.Primary.SpreadMinAlt
                                    end
                           end
                           if self.Primary.Spread > self.Primary.SpreadMin then
                                    self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.Spread
                           end
                  end
                  if self.Owner:GetVelocity():Length() <= 100 then
                           if self.Silencer == 0 and self.Primary.Spread > self.Primary.SpreadMax then
                                    self.Primary.Spread = self.Primary.SpreadMax
                           end
                           if self.Silencer == 2 and self.Primary.Spread > self.Primary.SpreadMaxAlt then
                                    self.Primary.Spread = self.Primary.SpreadMaxAlt
                           end
                  end
                  if self.Owner:GetVelocity():Length() > 100 then
                           if self.Silencer == 0 then
                                    self.Primary.Spread = self.Primary.SpreadMove
                                    if self.Primary.Spread > self.Primary.SpreadMin then
                                             self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.SpreadMove
                                    end
                           end
                           if self.Silencer == 2 then
                                    self.Primary.Spread = self.Primary.SpreadMoveAlt
                                    if self.Primary.Spread > self.Primary.SpreadMinAlt then
                                             self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.SpreadMoveAlt
                                    end
                           end
                           self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
                  end
         end
         if !self.Owner:IsOnGround() then
                  if self.Silencer == 0 then
                           self.Primary.Spread = self.Primary.SpreadAir
                           if self.Primary.Spread > self.Primary.SpreadMin then
                                    self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.SpreadAir
                           end
                  end
                  if self.Silencer == 2 then
                           self.Primary.Spread = self.Primary.SpreadAirAlt
                           if self.Primary.Spread > self.Primary.SpreadMinAlt then
                                    self.Primary.Spread = ( ( self.Primary.SpreadRecoveryTimer - CurTime() ) / self.Primary.SpreadRecoveryTime ) * self.Primary.SpreadAirAlt
                           end
                  end
                  self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
         end
         if self.Reloading == 1 and self.ReloadingTimer <= CurTime() then
                  if self.Weapon:Ammo1() > ( self.Primary.ClipSize - self.Weapon:Clip1() ) then
                           self.Owner:SetAmmo( self.Weapon:Ammo1() - self.Primary.ClipSize + self.Weapon:Clip1(), self.Primary.Ammo )
                           self.Weapon:SetClip1( self.Primary.ClipSize )
                  end
                  if ( self.Weapon:Ammo1() - self.Primary.ClipSize + self.Weapon:Clip1() ) + self.Weapon:Clip1() < self.Primary.ClipSize then
                           self.Weapon:SetClip1( self.Weapon:Clip1() + self.Weapon:Ammo1() )
                           self.Owner:SetAmmo( 0, self.Primary.Ammo )
                  end
                  self.Reloading = 0
         end
         if self.IdleTimer <= CurTime() then
                  if self.Idle == 0 then
                           self.Idle = 1
                  end
                  if SERVER and self.Idle == 1 then
                           if self.Silencer == 0 then
                                    self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
                           end
                           if self.Silencer == 2 then
                                    self.Weapon:SendWeaponAnim( ACT_VM_IDLE_SILENCED )
                           end
                  end
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
         if self.Weapon:Ammo1() > self.Primary.MaxAmmo then
                  self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
         end
end