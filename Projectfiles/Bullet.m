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

#import "Bullet.h"
#import "GameLayer.h"

@interface Bullet (PrivateMethods)
-(id) initWithBulletImage;
@end


@implementation Bullet

@synthesize velocity;
@synthesize isPlayerBullet;
@synthesize bulletType;
@synthesize moveRect;

+(id) bullet
{
	id bullet = [[self alloc] initWithBulletImage];
#ifndef KK_ARC_ENABLED
	[bullet autorelease];
#endif // KK_ARC_ENABLED
	return bullet;
}

-(id) initWithBulletImage
{
	// Uses the Texture Atlas now.
	if ((self = [super initWithSpriteFrameName:@"bullet_1.png"]))
	{
	}
	
	return self;
}

// Re-Uses the bullet
-(void) shootBulletAt:(CGPoint)startPosition velocity:(CGPoint)vel frameName:(NSString*)frameName bulletType:(int)type isPlayerBullet:(bool)playerBullet
{
	self.velocity = vel;
	self.position = startPosition;
	self.visible = YES;
	self.isPlayerBullet = playerBullet;
    self.bulletType = type;
    updateCount = 0;

	// change the bullet's texture by setting a different SpriteFrame to be displayed
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
	[self setDisplayFrame:frame];
	
	[self unscheduleUpdate];
	[self scheduleUpdate];
	
    //JCV// -- don't rotate the bullet
	//JCV//CCRotateBy* rotate = [CCRotateBy actionWithDuration:1 angle:-360];
	//JCV//CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
	//JCV//[self runAction:repeat];
}

-(void) update:(ccTime)delta
{

    // keep a rectangle containing the previous position and the new position
    // that way if the bullet moves a lot between frames (e.g., low frame count)
    // that we can tell if it collided with anything inbetween.
    
    int oldX = self.position.x;
    int oldY = self.position.y;
    
	self.position = ccpAdd(self.position, ccpMult(velocity, delta));
    
    // calculate the movement rect
    moveRect = CGRectMake(oldX, oldY, (self.position.x + [self boundingBox].size.width) - oldX, [self boundingBox].size.height);
    
    updateCount++;
    if (updateCount % 5 == 0) {
        self.flipY = !(self.flipY);
        updateCount = 0;
    }
	
	// When the bullet leaves the screen, make it invisible
	if (CGRectIntersectsRect([self boundingBox], [GameLayer screenRect]) == NO)
	{
		self.visible = NO;
		[self stopAllActions];
		[self unscheduleUpdate];
	}
}

@end
