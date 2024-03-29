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

@interface Bullet : CCSprite 
{
	CGPoint velocity;
    CGRect moveRect;
	bool isPlayerBullet;
    int bulletType;
    int updateCount;
}

@property (readwrite, nonatomic) CGPoint velocity;
@property (readwrite, nonatomic) bool isPlayerBullet;
@property (readwrite, nonatomic) int bulletType;
@property (readonly, nonatomic) CGRect moveRect;

+(id) bullet;

-(void) shootBulletAt:(CGPoint)startPosition velocity:(CGPoint)vel frameName:(NSString*)frameName bulletType:(int)bulletType isPlayerBullet:(bool)playerBullet;


@end
