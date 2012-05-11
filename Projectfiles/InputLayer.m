/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import "InputLayer.h"
#import "GameLayer.h"
#import "ShipEntity.h"
#import "HUDLayer.h"

#import "SimpleAudioEngine.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
-(void) addJoystick;
//JCV//
-(void) addFlyButton;
@end

@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{

        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        // make our "fly touch" rect the first "quarter" of the screen
        flyTouchRect = CGRectMake(0, 0, screenSize.width / 4, screenSize.height);
        //NSLog (@"FlyTouchRect = %f, %f, %f, %f", flyTouchRect.origin.x, flyTouchRect.origin.y, flyTouchRect.size.width, flyTouchRect.size.height);
        
        flyTouchAcceleration = 0;
        
        numShots = 0;
        
        // create the fire button
		[self addFireButton];

		[self scheduleUpdate];
	}
	
	return self;
}

-(void) addFireButton
{
	float buttonRadius = 50;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	fireButton = [SneakyButton button];
	fireButton.isHoldable = YES;
	
	SneakyButtonSkinnedBase* skinFireButton = [SneakyButtonSkinnedBase skinnedButton];
	skinFireButton.position = CGPointMake(screenSize.width - buttonRadius, buttonRadius);
    skinFireButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"fire_button.png"];
    skinFireButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"fire_button_pressed.png"];
	skinFireButton.button = fireButton;
	[self addChild:skinFireButton];
}

-(void) update:(ccTime)delta 
{
	totalTime += delta;
    
    // Moving the ship with the thumbstick.
	GameLayer* game = [GameLayer sharedGameLayer];
	ShipEntity* ship = [game defaultShip];
    
    // checking all touches
    // so far we only care about touches in the "fly" area.
    CCArray* touches = [KKInput sharedInput].touches;
    KKTouch* touch;
    CCARRAY_FOREACH(touches, touch) {
        // new touch began in fly area
        if (flyTouchID == 0 && !CGRectContainsPoint(flyTouchRect, touch.location)) {
            // rule out all new touches that aren't in the designated area
        } else if (touch.phase == KKTouchPhaseBegan && CGRectContainsPoint(flyTouchRect, touch.location)) {
            if (flyTouchID == 0) {
                // a new touch to start tracking!
                flyTouchID = touch.touchID;
                flyTouchAnchorPoint = CGPointMake(touch.location.x, touch.location.y);
                NSLog(@"New touch at position %f, %f width ID %d [%d]", touch.location.x, touch.location.y, touch.touchID, touch.phase);
            } else {
                // ignore me since we are already
                // tracking a touch
            }
        } else if (touch.phase == KKTouchPhaseEnded || touch.phase == KKTouchPhaseLifted || touch.phase == KKTouchPhaseCancelled) {
            if (flyTouchID == touch.touchID) {
                flyTouchID = 0;
                NSLog(@"touch ID ended %d [%d]", touch.touchID, touch.phase);  
                [ship updateAcceleration:0.0];
            }
        } else if (touch.phase == KKTouchPhaseMoved || touch.phase == KKTouchPhaseStationary) {
            // TODO: why is it logging the touches as "stationary" when the touch moved?
            // calculate distance between ship and the touch
            int ydiff = touch.location.y - (ship.position.y);
            // if our distance is small enough, just snap to the new position
            if (abs(ship.playerVelocity.y) < kShipSnapSpeedThreshold && abs(ydiff) < kShipSnapDistanceThreshold) {
                
                //NSLog(@"SNAP %d", (int)ship.playerVelocity.y);
                
                [ship adjustPosition:CGPointMake(0, ydiff)];
                flyTouchAcceleration = 0;
                
                // park the ship on the finger
                [ship updateVelocity:0];
            } 
            // if we are heading in the opposite direction of the touch
            // (e.g., we ran right past it), increase the acceleration
            // this helps prevent "orbiting" of the touch point
            else if ((ydiff > 0 && ship.playerVelocity.y < 0) || (ydiff < 0 && ship.playerVelocity.y > 0)) {
                flyTouchAcceleration = kShipTurnAroundSpeed * (abs(ydiff) / ydiff);
                //NSLog(@"TURN AROUND");
            }
            // set the acceleration based on the direction of the touch point
            else if (ydiff != 0) {
                // should return -1 if ydiff < 0 or 1 if ydiff > 0
                flyTouchAcceleration = (abs(ydiff) / ydiff); 
                //NSLog(@"CHASE IT %d => %d", ydiff, (int)flyTouchAcceleration);
            }
            
            //update the ship's acceleration
            [ship updateAcceleration:flyTouchAcceleration];
        }
    }
     
    // Hit the Fire Button
    // TODO: 
    // make this take into account whether the player has the
    // auto-fire powerup
	if (fireButton.active && totalTime > nextShotTime && numShots < kMaxBullets)
	{
		nextShotTime = totalTime + 0.3f;

		GameLayer* game = [GameLayer sharedGameLayer];
		ShipEntity* ship = [game defaultShip];
		
        // fire the weapon
        [ship fireWeapon];
        
        numShots++;
        // reset the cooldown if we still have bullets
        if (numShots == kMaxBullets) {
            // punish the player for hitting the maxBullets
            shotCooldown += kBulletCooldownNormal * kBulletCooldownAtMax;
        } else {
            shotCooldown = kBulletCooldownNormal;
        }
        
        HUDLayer *hud = [GameLayer sharedGameLayer].hud;
        
        [hud updateBulletLEDs:numShots bulletType:ShipWeaponNormal];
        
	} else if (numShots > 0 && shotCooldown > 0) {
        shotCooldown -= delta;
        
        if (shotCooldown <= 0) {
            numShots--;
            HUDLayer *hud = [GameLayer sharedGameLayer].hud;
            [hud updateBulletLEDs:numShots bulletType:ShipWeaponNormal];
            
            if (numShots > 0) {
                shotCooldown += kBulletCooldownNormal;
            }
        }
    }
	
	// player let go of button, so reset the shoot delay
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}
    
    
    // update the state of the player ship
    [ship updatePhysics];
    
    
}

@end
