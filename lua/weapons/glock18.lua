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
         killicon.AddFont( "glock18", "CSKillIcons", "c", Color( 255, 80, 0, 255 ) )
end

SWEP.PrintName = "9x19mm Sidearm"
SWEP.Category = "Counter-Strike: Source"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.UseHands = true
SWEP.HoldType = "pistol"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.Burst = 0
SWEP.BurstTimer = CurTime()
SWEP.BurstText = 0
SWEP.BurstTextTimer = CurTime()
SWEP.ShotTimer = CurTime()
SWEP.Reloading = 0
SWEP.ReloadingTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.WalkSpeed = 200
SWEP.RunSpeed = 400

SWEP.Primary.Sound = Sound( "Weapon_Glock.Single" )
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 140
SWEP.Primary.MaxAmmo = 120
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9mm Parabellum"
SWEP.Primary.Damage = 25
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Spread = 0.004
SWEP.Primary.SpreadMin = 0.004
SWEP.Primary.SpreadMax = 0.03161
SWEP.Primary.SpreadKick = 0.01
SWEP.Primary.SpreadMove = 0.04826
SWEP.Primary.SpreadAir = 0.2775
SWEP.Primary.SpreadMaxAlt = 0.02217
SWEP.Primary.SpreadRecoveryTime = 0.26249
SWEP.Primary.SpreadRecoveryTimer = CurTime()
SWEP.Primary.Delay = 0.15
SWEP.Primary.DelayAlt = 0.5
SWEP.Primary.Force = 1

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.25

function SWEP:Initialize()
         self:SetWeaponHoldType( self.HoldType )
         self.Burst = 0
         self.Idle = 0
         self.IdleTimer = CurTime() + 1
end

function SWEP:DrawWeaponSelection( x, y, wide, tall )
         draw.SimpleText( "C", "CSSelectIcons", x + wide / 2, y + tall / 2, Color( 255, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function SWEP:DrawHUD()
         if CLIENT then
                  draw.SimpleText( self.Weapon:GetNWInt( "Burst", "" ), "CloseCaption_Bold", ScrW() * 0.5, ScrH() * 0.35, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
         end
end

function SWEP:Deploy()
         self:SetWeaponHoldType( self.HoldType )
         self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self.BurstTimer = CurTime()
         self.BurstText = 0
         self.BurstTextTimer = CurTime()
         self.ShotTimer = CurTime()
         self.Reloading = 0
         self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         self.Recoil = 0
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         self.Weapon:SetNWInt( "Burst", "" )
         self.Owner:SetWalkSpeed( self.WalkSpeed )
         self.Owner:SetRunSpeed( self.RunSpeed )
         return true
end

function SWEP:Holster()
         if ( self.Owner:IsNPC() ) then return end
         self.BurstTimer = CurTime()
         self.BurstText = 0
         self.BurstTextTimer = CurTime()
         self.ShotTimer = CurTime()
         self.Reloading = 0
         self.ReloadingTimer = CurTime()
         self.Recoil = 0
         self.Idle = 0
         self.IdleTimer = CurTime()
         self.Weapon:SetNWInt( "Burst", "" )
         self.Owner:SetWalkSpeed( 200 )
         self.Owner:SetRunSpeed( 400 )
         return true
end

function SWEP:PrimaryAttack()
         if ( self.Weapon:Clip1() <= 0 and self.Weapon:Ammo1() <= 0 ) || ( self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 ) then
                  if SERVER then
                           self.Owner:EmitSound( "Default.ClipEmpty_Pistol" )
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
         bullet.Distance = 4096
         bullet.Force = self.Primary.Force
         bullet.Damage = self.Primary.Damage
         bullet.AmmoType = self.Primary.Ammo
         self.Owner:FireBullets( bullet )
         self:EmitSound( self.Primary.Sound )
         self:ShootEffects()
         self:TakePrimaryAmmo( self.Primary.TakeAmmo )
         self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
         self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
         if self.Primary.Spread < self.Primary.SpreadMax then
                  self.Primary.Spread = self.Primary.Spread + self.Primary.SpreadKick
         end
         self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
         if self.Burst == 0 then
                  self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
                  self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
                  self.ReloadingTimer = CurTime() + self.Primary.Delay
         end
         if self.Burst == 1 then
                  self:SetNextPrimaryFire( CurTime() + self.Primary.DelayAlt )
                  self:SetNextSecondaryFire( CurTime() + self.Primary.DelayAlt )
                  self.ReloadingTimer = CurTime() + self.Primary.DelayAlt
         end
         if self.Burst == 1 then
                  if self.Weapon:Clip1() > 0 then
                           self.Burst = 2
                           self.BurstTimer = CurTime() + 0.05
                  end
                  if self.Weapon:Clip1() <= 0 then
                           self.Burst = 1
                  end
         end
         if ( self.Owner:IsNPC() ) then return end
         self.ShotTimer = CurTime() + self.Primary.Delay
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:SecondaryAttack()
         if self.Burst == 0 then
                  self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
                  if IsFirstTimePredicted() then
                           self.Burst = 1
                  end
                  self.BurstText = 1
                  self.BurstTextTimer = CurTime() + 2
                  self.Weapon:SetNWString( "Burst", "Switched to burst-fire mode" )
         else
                  if self.Burst == 1 then
                           self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
                           if IsFirstTimePredicted() then
                                    self.Burst = 0
                           end
                           self.BurstText = 2
                           self.BurstTextTimer = CurTime() + 2
                           self.Weapon:SetNWString( "Burst", "Switched to semi-automatic" )
                  end
         end
end

function SWEP:ShootEffects()
         if self.Weapon:Clip1() > 1 then
                  if self.Burst == 0 then
                           self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
                  end
                  if self.Burst == 1 then
                           self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
                  end
         end
         if self.Weapon:Clip1() <= 1 then
                  self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
         end
         self.Owner:SetAnimation( PLAYER_ATTACK1 )
         self.Owner:MuzzleFlash()
end

function SWEP:Reload()
         if self.Reloading == 0 and self.ReloadingTimer <= CurTime() and self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0 then
                  self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
                  self.Owner:SetAnimation( PLAYER_RELOAD )
                  self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                  self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                  self.Reloading = 1
                  self.ReloadingTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                  self.Idle = 0
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
end

function SWEP:Think()
         if self.BurstTextTimer <= CurTime() then
                  if self.BurstText == 1 then
                           self.BurstText = 0
                           self.Weapon:SetNWString( "Burst", "" )
                  end
                  if self.BurstText == 2 then
                           self.BurstText = 0
                           self.Weapon:SetNWString( "Burst", "" )
                  end
         end
         if self.Burst == 2 and self.BurstTimer <= CurTime() then
                  if ( self.Weapon:Clip1() <= 0 and self.Weapon:Ammo1() <= 0 ) || ( self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 ) then
                           if SERVER then
                                    self.Owner:EmitSound( "Default.ClipEmpty_Pistol" )
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
                  bullet.Distance = 4096
                  bullet.Force = self.Primary.Force
                  bullet.Damage = self.Primary.Damage
                  bullet.AmmoType = self.Primary.Ammo
                  self.Owner:FireBullets( bullet )
                  self:EmitSound( self.Primary.Sound )
                  self:ShootEffects()
                  self:TakePrimaryAmmo( self.Primary.TakeAmmo )
                  if self.Primary.Spread < self.Primary.SpreadMax then
                           self.Primary.Spread = self.Primary.Spread + self.Primary.SpreadKick
                  end
                  self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
                  if self.Weapon:Clip1() > 0 then
                           self.Burst = 3
                           self.BurstTimer = CurTime() + 0.05
                  end
                  if self.Weapon:Clip1() <= 0 then
                           self.Burst = 1
                  end
                  self.ShotTimer = CurTime() + self.Primary.Delay
                  self.Idle = 0
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
         if self.Burst == 3 and self.BurstTimer <= CurTime() then
                  if ( self.Weapon:Clip1() <= 0 and self.Weapon:Ammo1() <= 0 ) || ( self.FiresUnderwater == false and self.Owner:WaterLevel() == 3 ) then
                           if SERVER then
                                    self.Owner:EmitSound( "Default.ClipEmpty_Pistol" )
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
                  bullet.Distance = 4096
                  bullet.Force = self.Primary.Force
                  bullet.Damage = self.Primary.Damage
                  bullet.AmmoType = self.Primary.Ammo
                  self.Owner:FireBullets( bullet )
                  self:EmitSound( self.Primary.Sound )
                  self:ShootEffects()
                  self:TakePrimaryAmmo( self.Primary.TakeAmmo )
                  if self.Primary.Spread < self.Primary.SpreadMax then
                           self.Primary.Spread = self.Primary.Spread + self.Primary.SpreadKick
                  end
                  self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
                  self.Burst = 1
                  self.ShotTimer = CurTime() + self.Primary.Delay
                  self.Idle = 0
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
         if self.ShotTimer > CurTime() then
                  self.Primary.SpreadRecoveryTimer = CurTime() + self.Primary.SpreadRecoveryTime
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
                  if self.Owner:GetVelocity():Length() <= 100 and self.Primary.Spread > self.Primary.SpreadMax then
                           self.Primary.Spread = self.Primary.SpreadMax
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
                           self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
                  end
                  self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         end
         if self.Weapon:Ammo1() > self.Primary.MaxAmmo then
                  self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
         end
end