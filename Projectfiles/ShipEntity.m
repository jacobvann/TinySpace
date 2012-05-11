/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "ShipEntity.h"
#import "GameLayer.h"
#import "BulletCache.h"

#import "SimpleAudioEngine.h"

@interface ShipEntity (PrivateMethods)
-(id) initWithShipImage;
//JCV//
-(void) initPhysics;
-(void) updateAcceleration;
-(void) adjustPosition;
-(void) fireWeapon;
@end


@implementation ShipEntity

@synthesize playerVelocity;


+(id) ship
{
	id ship = [[self alloc] initWithShipImage];
    [ship initPhysics];
#ifndef KK_ARC_ENABLED
	[ship autorelease];
#endif // KK_ARC_ENABLED
	return ship;
}

-(id) initWithShipImage
{
	// Loading the Ship's sprite using a sprite frame name (eg the filename)
	if ((self = [super initWithSpriteFrameName:@"ship.png"]))
	{
		// create an animation object from all the sprite animation frames
		CCAnimation* anim = [CCAnimation animationWithFrames:@"ship_anim_" frameCount:4 delay:0.12f];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[self runAction:repeat];
        
        weaponLevel = ShipWeaponNormal;
        
	}
	return self;
}

//JCV//
-(void) flyButtonHit
{
    NSLog(@"**** OBSOLETE FUNCTION!! ****");
    //self->playerVelocity.y += kShip_Vertical_Accelleration;
    // max out the velocity
    //if (self->playerVelocity.y > kShip_Max_Vertical_Velocity) {
    //    self->playerVelocity.y = kShip_Max_Vertical_Velocity;
    //}
}


//JCV//
-(void) initPhysics
{
    self->playerVelocity.x = 0;
    self->playerVelocity.y = 0;
    self->currentAcceleration = 0.0;
        
}

//JCV//
-(void) updatePhysics
{
        
    CGPoint newPos = self.position;
    
    //apply the acceleration
    self->playerVelocity.y += currentAcceleration;
    
    // max out the velocity
    if (self->playerVelocity.y < -kShip_Max_Fall_Velocity) {
        self->playerVelocity.y = -kShip_Max_Fall_Velocity;
    } else if (self->playerVelocity.y > kShip_Max_Vertical_Velocity) {
        self->playerVelocity.y = kShip_Max_Vertical_Velocity;
    }

    newPos.y += self->playerVelocity.y;
    [self setPosition:newPos];
}

-(void) updateAcceleration:(float)newAccel {
    
    self->currentAcceleration = newAccel;
    
}


-(void) updateVelocity:(float)newVel {
    
    self->playerVelocity.y = newVel;
    
}

-(void) adjustPosition:(CGPoint)diff {
    
    [self setPosition:CGPointMake(self.position.x + diff.x, self.position.y + diff.y)];
    
}


// moved back to ShipEntity ... the enemies currently don't need it and it gets in the way when
// resetting enemy positions during spawn

// override setPosition to keep entitiy within screen bounds
-(void) setPosition:(CGPoint)pos
{
	// If the current position is (still) outside the screen no adjustments should be made!
	// This allows entities to move into the screen from outside.
	if ([self isOutsideScreenArea])
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float halfWidth = self.contentSize.width * 0.5f;
		float halfHeight = self.contentSize.height * 0.5f;
		
		// Cap the position so the Ship's sprite stays on the screen
		if (pos.x < halfWidth)
		{
			pos.x = halfWidth;
		}
		else if (pos.x > (screenSize.width - halfWidth))
		{
			pos.x = screenSize.width - halfWidth;
		}
		
        // hit the bottom
		if (pos.y < halfHeight)
		{
            //JCV//reset velocity
            if (self->playerVelocity.y < 0) {
                self->playerVelocity.y = 0;
            }
			pos.y = halfHeight;
		}
        
        // hit the top
		else if (pos.y > (screenSize.height - halfHeight))
		{
            //JCV//reset velocity
            if (self->playerVelocity.y > 0) {
                self->playerVelocity.y = 0;
            }
			pos.y = screenSize.height - halfHeight;
		}
	}
	
	[super setPosition:pos];
}

// fire the ship's current weapon
-(void) fireWeapon {
    
    int bulletSpeed;
    NSString *bulletFrame;
    
    GameLayer* game = [GameLayer sharedGameLayer];
    BulletCache* bulletCache = [game bulletCache];
    
    // Set the position, velocity and spriteframe before shooting
    CGPoint shotPos = CGPointMake(self.position.x, self.position.y);
    
    switch (weaponLevel) {
        case ShipWeaponNormal:
        case ShipWeaponAuto:
        case ShipWeaponPassThrough:
        case ShipWeaponSpread:
        case ShipWeaponGodBeam:
            bulletSpeed = kBulletSpeedNormal;
            bulletFrame = @"bullet_1.png";
            break;
        default:
            NSLog(@"Unknown Weapon type! %d", weaponLevel);
    }
    
        
    CGPoint velocity = CGPointMake(bulletSpeed, 0);
    [bulletCache shootBulletFrom:shotPos velocity:velocity frameName:bulletFrame bulletType:weaponLevel isPlayerBullet:YES];
    
    float pitch = CCRANDOM_0_1() * 0.2f + 0.9f;
    [[SimpleAudioEngine sharedEngine] playEffect:@"shoot1.wav" pitch:pitch pan:0.0f gain:1.0f];
}

-(BOOL) isOutsideScreenArea
{
	return (CGRectContainsRect([GameLayer screenRect], [self boundingBox]));
}

@end
