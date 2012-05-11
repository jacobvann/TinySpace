/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "Entity.h"



// Re-implementation of the Ship class using Components
@interface ShipEntity : Entity
{
    
    //JCV//
    CGPoint playerVelocity;
    float   currentAcceleration;
    int     weaponLevel;
}

+(id) ship;

@property (readonly, nonatomic) CGPoint playerVelocity;

-(BOOL) isOutsideScreenArea;

//JCV//
-(void) flyButtonHit;
-(void) updatePhysics;
-(void) updateAcceleration:(float)newAccel;
-(void) updateVelocity:(float)newVel;
-(void) adjustPosition:(CGPoint)diff;
-(void) fireWeapon;



@end
