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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// SneakyInput headers
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

#define kShipSnapDistanceThreshold      8      /* when to snap the ship to the finger */
#define kShipSnapSpeedThreshold         16      /* when to snap the ship to the finger (the smaller the number the more "slippery" */
#define kShipTurnAroundSpeed            8      /* by what factor do we set the ship's acceleration when we need to turn around */

@interface InputLayer : CCLayer 
{
	SneakyButton* fireButton;
	SneakyJoystick* joystick;
    
    //JCV//
    SneakyButton* flyButton;
    
    // the touch Id for the finger that is "flying" the ship
    NSUInteger  flyTouchID;
    CGRect      flyTouchRect;
    CGPoint     flyTouchAnchorPoint;
    float       flyTouchAcceleration;
	
	ccTime totalTime;
	ccTime nextShotTime;
    ccTime shotCooldown;
    
    int     numShots;
}

@end
