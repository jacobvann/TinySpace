//
//  HUDLayer.h
//  SideScrollerTest
//
//  Created by ANONYMOUS ANONYMOUS on 5/3/12.
//  Copyright 2012 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HUDLayer : CCLayer {
    CCArray *bulletLEDs;
}


-(void) initBulletLEDs;
-(void) updateBulletLEDs:(int)count bulletType:(int)type;

@end
