//
//  SpaceRockCache.m
//  SideScrollerTest
//
//  Created by ANONYMOUS ANONYMOUS on 3/19/12.
//  Copyright 2012 Apple. All rights reserved.
//

#import "SpaceRockCache.h"
#import "spaceRock.h"
#import "GameLayer.h"
#include <stdlib.h>

@interface SpaceRockCache (PrivateMethods)
-(void) initRocks;
@end

@implementation SpaceRockCache

+(id) cache
{
	id cache = [[self alloc] init];
#ifndef KK_ARC_ENABLED
	[cache autorelease];
#endif // KK_ARC_ENABLED
	return cache;
}

-(id) init
{
	if ((self = [super init]))
	{
		// get any image from the Texture Atlas we're using
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"small_space_rock.png"];
		batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
		[self addChild:batch];
	
        numRocksSpawned = 0;
        numColumnsSpawned = 0;
        nextInactiveRock = 0;
        rockSpawnDelay = arc4random() % 7;
        
        for (int i = 0; i < kNumRockLanes; i++) {
            lastSpawnColumn[i] = -1;
        }
        
		[self initRocks];
		[self scheduleUpdate];
	
        spawnDistance = 0;
    }
    
	
	return self;
}

-(void) initRocks
{
	// create the rocks array
	rocks = [[CCArray alloc] initWithCapacity:kMaxNumRocks];
    
    for (int j = 0; j < kMaxNumRocks; j++)
    {
        SpaceRock* rock = [SpaceRock RockWithType:SmallRock];
        [batch addChild:rock z:1 tag:j];
        [rocks addObject:rock];
    }
    
}



-(void) checkForBulletCollisions
{
	SpaceRock* rock;
	CCARRAY_FOREACH([batch children], rock)
	{
		if (rock.visible)
		{
			BulletCache* bulletCache = [[GameLayer sharedGameLayer] bulletCache];
			CGRect bbox = [rock boundingBox];
			int dmg = [bulletCache isPlayerBulletCollidingWithRect:bbox];
            if (dmg > 0)
			{
				// This enemy got hit ...
                NSLog(@"HIT!!");
				[rock gotHit:dmg];
			}
		}
	}
}

-(void) update:(ccTime)delta
{
	updateCount++;
    
    //To Do: make this more random
    
    // calculate the distance of the last spawned rock
    spawnDistance += [GameLayer sharedGameLayer].scrollSpeed * delta;
    
    SpaceRock* rock = [rocks objectAtIndex:nextInactiveRock];
    
    // have we scrolled past the width of one rock?
    // this marks the "columns" for spawning rocks
    
    // NOTE:  I know what you're thinking: "3 for loops?"
    // hey, they aren't nested, and they serve a purpose.
    // the first, resets the curSpawnColumn to -1,
    // the second, does the actual spawning
    // the third, copies the curSpawnColumn to LastSpawnColumn
	if (spawnDistance >= rock.contentSize.width) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        float width = screenSize.width;
        float height = screenSize.height;
        // calculate how far past one column we have scrolled:
        float xdiff = spawnDistance = rock.contentSize.width;
        
        // remember what type of rock we spawned before
        int curSpawnType;
        int curSpawnColumn[kNumRockLanes];
        
        // copy the cur spawn column to the last spawn column
        for (int i = 0; i < kNumRockLanes; i++) {
            curSpawnColumn[i] = -1;
        }
    
        
        // spawn another set of 8 rocks
        for (int i = 0; i < kNumRockLanes; i++) {
            // if a large rock was spawned here last, just skip this row
            if (i > 0 && (curSpawnColumn[i-1] == LargeRock || curSpawnColumn[i-1] == LargeRockDark)) {
                // check for large rock on previous row
                //NSLog(@"just spawned large rock so skipping this row");
                curSpawnType = -1;
            } else if (lastSpawnColumn[i] == LargeRock || lastSpawnColumn[i] == LargeRockDark) {
                // check for large rock on previous column
                //NSLog(@"Skipping because of large rock");
                curSpawnType = -1;
            } else if (i > 0 && (lastSpawnColumn[i-1] == LargeRock || lastSpawnColumn[i-1] == LargeRockDark)) {
                // check for large rock on previous column
                //NSLog(@"Skipping because of large rock");
                curSpawnType = -1;
            } else if (lastSpawnColumn[i+1] == LargeRock || lastSpawnColumn[i+1] == LargeRockDark) {
                curSpawnType = -1;
            } else if (CCRANDOM_0_1()*kMaxRockDensity < [GameLayer sharedGameLayer].rockDensity) {
                // ok yay we can spawn a rock now!
                // determine our new spawn position
                float spawnPointX = width + (width / 8) - xdiff;
                float spawnPointY = height - (height / kNumRockLanes) * i - (height / (kNumRockLanes * 2));
                CGPoint spawnPos = CGPointMake(spawnPointX, spawnPointY);
                
                // ok, now what type of rock to spawn?
                curSpawnType = arc4random() % RockType_MAX;
                
                //curSpawnType = LargeRock;
                [self spawnRock:spawnPos rockType:curSpawnType];

                
                //NSLog(@"NEW ROCK TYPE: %d", newRockType);
            } else {
                //NSLog(@"Spawning Nothing");
                curSpawnType = -1;
            }
            
            curSpawnColumn[i] = curSpawnType;
            
        }
        
        // start measuring for a new column
        spawnDistance = 0;
        numColumnsSpawned++;
        
        //increase the rock density every once in a while
        if (numColumnsSpawned % kRockDensityAccel == 0) {
            [GameLayer sharedGameLayer].rockDensity++;
        }
    
        for (int i = 0; i < kNumRockLanes; i++) {
            lastSpawnColumn[i] = curSpawnColumn[i];
        }
	}
    
    [self checkForBulletCollisions];
	
}


-(void) spawnRock:(CGPoint)startPos rockType:(RockTypes)theType {
    
    CGPoint startVector;

    SpaceRock* rock = [rocks objectAtIndex:nextInactiveRock];
        
    //startVector = CGPointMake(-100 + (25 * CCRANDOM_0_1()), 2 - (4 * CCRANDOM_0_1()));
    startVector = CGPointMake(-100, 0);
    
        
    // find the first free rock and respawn it
    if (rock.visible == NO)
    {
        [rock spawn:startPos startSpeed:startVector rockType:(RockTypes)theType];
        numRocksSpawned++;
    } else {
        NSLog(@"Tried to spawn a space rock but the cached object was in use! [%u]", numRocksSpawned);
    }


    nextInactiveRock++;
    
    // did we just spawn the last rock from our cache?
	if (nextInactiveRock >= [rocks count])
	{
		nextInactiveRock = 0;
	}

    
}

@end
