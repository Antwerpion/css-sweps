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
         killicon.AddFont( "flashbang", "CSKillIcons", "P", Color( 255, 80, 0, 255 ) )
         killicon.AddFont( "flashbang_thrown", "CSKillIcons", "P", Color( 255, 80, 0, 255 ) )
end

SWEP.PrintName = "Flashbang"
SWEP.Category = "Counter-Strike: Source"
SWEP.Spawnable= true
SWEP.AdminSpawnable= true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_eq_flashbang.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 1
SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.UseHands = true
SWEP.HoldType = "grenade"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"

SWEP.Throw = 0
SWEP.ThrowTimer = CurTime()
SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.WalkSpeed = 200
SWEP.RunSpeed = 400

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.MaxAmmo = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Grenade"
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Spread = 0.02
SWEP.Primary.SpreadMin = 0.02
SWEP.Primary.SpreadMove = 0.05
SWEP.Primary.SpreadAir = 0.1
SWEP.Primary.SpreadRecoveryTime = 0.3
SWEP.Primary.SpreadRecoveryTimer = CurTime()
SWEP.Primary.Delay = 0.25
SWEP.Primary.Force = 1000

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
         self:SetWeaponHoldType( self.HoldType )
         self.Idle = 0
         self.IdleTimer = CurTime() + 1
end

function SWEP:DrawWeaponSelection( x, y, wide, tall )
         draw.SimpleText( "G", "CSSelectIcons", x + wide / 2, y + tall / 2, Color( 255, 255, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function SWEP:Deploy()
         self:SetWeaponHoldType( self.HoldType )
         self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
         self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
         self.Throw = 0
         self.ThrowTimer = CurTime()
         self.Idle = 0
         self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
         self.Owner:SetWalkSpeed( self.WalkSpeed )
         self.Owner:SetRunSpeed( self.RunSpeed )
         if self.Weapon:Ammo1() <= 0 then
                  if SERVER then
                           self.Owner:DropWeapon( self.Weapon )
                           self.Weapon:Remove()
                  end
         end
         return true
end

function SWEP:Holster()
         self.ThrowTimer = CurTime()
         self.Idle = 0
         self.IdleTimer = CurTime()
         self.Owner:SetWalkSpeed( 200 )
         self.Owner:SetRunSpeed( 400 )
         if self.Throw == 2 || self.Weapon:Ammo1() <= 0 then
                  if SERVER then
                           self.Owner:DropWeapon( self.Weapon )
                  end
                  self.Weapon:Remove()
         end
         return true
end

function SWEP:PrimaryAttack()
         if !( self.Throw == 0 ) then return end
         self.Weapon:SendWeaponAnim( ACT_VM_PULLPIN )
         self.Throw = 1
         self.ThrowTimer = CurTime() + self.Primary.Delay
         self.Idle = 2
end

function SWEP:SecondaryAttack()
end

function SWEP:ShootEffects()
         self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Reload()
end

function SWEP:Think()
         if self.Throw == 1 and self.ThrowTimer <= CurTime() and !self.Owner:KeyDown( IN_ATTACK ) then
                  if SERVER then
                           local entity = ents.Create( "flashbang_thrown" )
                           entity:SetOwner( self.Owner )
                           if IsValid( entity ) then
                                    entity:SetPos( self.Owner:GetShootPos() + self.Owner:EyeAngles():Forward() * 4 )
                                    entity:SetAngles( self.Owner:EyeAngles() )
                                    entity:Spawn()
                                    local phys = entity:GetPhysicsObject()
                                    phys:SetVelocity( self.Owner:GetAimVector() * self.Primary.Force )
                                    phys:AddAngleVelocity( Vector( math.Rand( -1000, 1000 ), math.Rand( -1000, 1000 ), math.Rand( -1000, 1000 ) ) )
                           end
                  end
                  self.Weapon:SendWeaponAnim( ACT_VM_THROW )
                  self:ShootEffects()
                  self:TakePrimaryAmmo( self.Primary.TakeAmmo )
                  self.Throw = 2
                  self.ThrowTimer = CurTime() + 0.5
                  self.Idle = 2
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
         if self.Weapon:Ammo1() > self.Primary.MaxAmmo then
                  self.Owner:SetAmmo( self.Primary.MaxAmmo, self.Primary.Ammo )
         end
         if self.Throw == 2 and self.ThrowTimer <= CurTime() then
                  if self.Weapon:Ammo1() > 0 then
                           self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
                           self:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                           self:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
                           self.Throw = 0
                           self.Idle = 0
                           self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
                  end
                  if self.Weapon:Ammo1() <= 0 then
                           self.Owner:SetWalkSpeed( 200 )
                           self.Owner:SetRunSpeed( 400 )
                           if SERVER then
                                    self.Owner:DropWeapon( self.Weapon )
                                    self.Weapon:Remove()
                           end
                  end
         end
end