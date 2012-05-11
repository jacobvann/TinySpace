//
//  SpaceRockCache.h
//  SideScrollerTest
//
//  Created by ANONYMOUS ANONYMOUS on 3/19/12.
//  Copyright 2012 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SpaceRock.h"
#import "Gamelayer.h"


@interface SpaceRockCache : CCNode {
    CCSpriteBatchNode* batch;
	CCArray* rocks;
    
    int          numRocksSpawned;
    int          numColumnsSpawned;
    int          lastSpawnColumn[kNumRockLanes];
    
    float        spawnDistance;
    NSUInteger   nextInactiveRock;
    int          rockSpawnDelay;
	
	int updateCount;
}

-(void) spawnRock:(CGPoint)startPos rockType:(RockTypes)theType;

@end
