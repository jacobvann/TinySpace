//
//  HUDLayer.m
//  SideScrollerTest
//
//  Created by ANONYMOUS ANONYMOUS on 5/3/12.
//  Copyright 2012 Apple. All rights reserved.
//

#import "HUDLayer.h"
#import "GameLayer.h"
#import "ShipEntity.h"



@implementation HUDLayer



-(id) init
{
	if ((self = [super init]))
	{
        
        [self initBulletLEDs];
        
		//[self scheduleUpdate];
	}
	
	return self;
}


-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[bulletLEDs release];
	bulletLEDs = nil;
	
	[super dealloc];
#endif // KK_ARC_ENABLED
}


-(void) initBulletLEDs {
    bulletLEDs = [[CCArray alloc] initWithCapacity:kMaxBullets];

    CGRect screenRect = [GameLayer screenRect];
    int screenWidth = screenRect.size.width;
    int screenHeight = screenRect.size.height;
    
    for (int i = 0; i < kMaxBullets; i++) {
        // create an LED sprite
        CCSprite *led = [[CCSprite alloc] initWithSpriteFrameName:@"led_off.png"];
        
        int positionx = screenWidth - led.contentSize.width * 2;
        int positiony = screenHeight - led.contentSize.height * (i+1);
        
        [bulletLEDs addObject:led];
        [led setPosition:CGPointMake(positionx, positiony)];
        
        [self addChild:led];
    }
}

-(void) updateBulletLEDs:(int)count bulletType:(int)type {
    
    if (count > kMaxBullets) {
        count = kMaxBullets;
    }

    NSString *frameName = @"led_off.png";
    
    for (int i = 0; i < count; i++) {
        CCSprite *led = [bulletLEDs objectAtIndex:i];
        
        switch (type) {
            case ShipWeaponNormal:
                frameName = @"led_on_cyan.png";
                break;
            default:
                frameName = @"led_on_magenta.png";
        }
        
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        
        [led setDisplayFrame:frame];
    }
    
    
    // now update the rest to be "off"
    for (int i = count; i < kMaxBullets; i++) {
        CCSprite *led = [bulletLEDs objectAtIndex:i];

        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"led_off.png"];
        
        [led setDisplayFrame:frame];
    }
}


@end
