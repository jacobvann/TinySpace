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

#import "BulletCache.h"
#import "Bullet.h"

@interface BulletCache (PrivateMethods)
-(bool) isBulletCollidingWithRect:(CGRect)rect usePlayerBullets:(bool)usePlayerBullets;
@end


@implementation BulletCache

-(id) init
{
	if ((self = [super init]))
	{
		// get any bullet image from the Texture Atlas we're using
		CCSpriteFrame* bulletFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet_1.png"];
		// use the bullet's texture (which will be the Texture Atlas used by the game)
		batch = [CCSpriteBatchNode batchNodeWithTexture:bulletFrame.texture];
		[self addChild:batch];
		
		// Create a number of bullets up front and re-use them whenever necessary.
		for (int i = 0; i < 200; i++)
		{
			Bullet* bullet = [Bullet bullet];
			bullet.visible = NO;
			[batch addChild:bullet];
		}
	}
	
	return self;
}

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString*)frameName bulletType:(int)type isPlayerBullet:(bool)isPlayerBullet
{
	CCArray* bullets = [batch children];
	CCNode* node = [bullets objectAtIndex:nextInactiveBullet];
	NSAssert([node isKindOfClass:[Bullet class]], @"not a Bullet!");
	
	Bullet* bullet = (Bullet*)node;
	[bullet shootBulletAt:startPosition velocity:velocity frameName:frameName bulletType:type isPlayerBullet:isPlayerBullet];
	
	nextInactiveBullet++;
	if (nextInactiveBullet >= [bullets count])
	{
		nextInactiveBullet = 0;
	}
}

-(int) isPlayerBulletCollidingWithRect:(CGRect)rect
{
	//return NO;
    return [self isBulletCollidingWithRect:rect usePlayerBullets:YES];
}

-(int) isEnemyBulletCollidingWithRect:(CGRect)rect
{
	//return NO;
    return [self isBulletCollidingWithRect:rect usePlayerBullets:YES];
}

-(int) isBulletCollidingWithRect:(CGRect)rect usePlayerBullets:(bool)usePlayerBullets
{
	bool isColliding = NO;
	
	Bullet* bullet;
	CCARRAY_FOREACH([batch children], bullet)
	{
		if (bullet.visible && usePlayerBullets == bullet.isPlayerBullet)
		{
			if (CGRectIntersectsRect(bullet.moveRect, rect)) {
			
				isColliding = YES;
				//NSLog(@"CoLLision bitch");
				// remove the bullet
				bullet.visible = NO;
				break;
			}
		}
	}

	return (isColliding? 1 : 0);
}

@end
