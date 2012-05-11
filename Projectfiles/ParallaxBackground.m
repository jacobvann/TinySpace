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

#import "ParallaxBackground.h"
#import "GameLayer.h"


@implementation ParallaxBackground

-(id) init
{
	if ((self = [super init]))
	{
		// The screensize never changes during gameplay, so we can cache it in a member variable.
		screenSize = [[CCDirector sharedDirector] winSize];
		
		// Get the game's texture atlas texture by adding it. Since it's added already it will simply return 
		// the CCTexture2D associated with the texture atlas.
		CCTexture2D* gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:@"space_game_art.pvr.ccz"];
		
		// Create the background spritebatch
		spriteBatch = [CCSpriteBatchNode batchNodeWithTexture:gameArtTexture];
		[self addChild:spriteBatch];

		numStripes = 3;
		
		// Add the 7 different stripes and position them on the screen
		for (NSUInteger i = 0; i < numStripes; i++)
		{
			NSString* frameName = [NSString stringWithFormat:@"bg%i.png", i];
			CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
			sprite.anchorPoint = CGPointMake(0, 0.5f);
			sprite.position = CGPointMake(0, screenSize.height / 2);
			[spriteBatch addChild:sprite z:i tag:i];
		}

		// Add 7 more stripes, flip them and position them next to their neighbor stripe
		for (NSUInteger i = 0; i < numStripes; i++)
		{
			NSString* frameName = [NSString stringWithFormat:@"bg%i.png", i];
			CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
			
			// Position the new sprite one screen width to the right
			sprite.anchorPoint = CGPointMake(0, 0.5f);
			sprite.position = CGPointMake(screenSize.width - 1, screenSize.height / 2);

			// Flip the sprite so that it aligns perfectly with its neighbor
			sprite.flipX = YES;
			
			// Add the sprite using the same tag offset by numStripes
			[spriteBatch addChild:sprite z:i tag:i + numStripes];
		}
		
		// Initialize the array that contains the scroll factors for individual stripes.
		speedFactors = [[CCArray alloc] initWithCapacity:numStripes];
		[speedFactors addObject:[NSNumber numberWithFloat:0.05f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.1f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.2f]];
		NSAssert([speedFactors count] == numStripes, @"speedFactors count does not match numStripes!");
		
        [self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[speedFactors release];
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) update:(ccTime)delta
{
	CCSprite* sprite;
	CCARRAY_FOREACH([spriteBatch children], sprite)
	{
		//CCLOG(@"tag: %i", sprite.tag);
		NSNumber* factor = [speedFactors objectAtIndex:sprite.zOrder];
		
        CGPoint velocity = CGPointMake(-[GameLayer sharedGameLayer].scrollSpeed * [factor floatValue], 0);
        
        CGPoint pos = ccpAdd(sprite.position, ccpMult(velocity, delta));
		
		// Reposition stripes when they're out of bounds
		if (pos.x < -screenSize.width)
		{
			pos.x += (screenSize.width * 2) - 2;
		}
		
		sprite.position = pos;
	}
    
    //JCV// accelerate scrolling -- moved to gamelayer.m
    //scrollSpeed += scrollAcceleration;
    
}

@end
