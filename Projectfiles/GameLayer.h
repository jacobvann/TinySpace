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

#import "BulletCache.h"
#import "ParallaxBackground.h"
#import "ShipEntity.h"
#import "HUDLayer.h"

// some global constants
#define kScrollSpeed                    80.0f   // beginning scroll speed of the level
#define kScrollSpeedLimit               1000.f   // scroll speed absolute limit
#define kScrollAcceleration             1.0f    // how fast the scroll speed increases

//JCV// define some constants for the ship
#define kShip_Vertical_Accelleration    1.6f    // how quickly the ship accelerates (up or down)
#define kShip_Gravity                   0.0f    // this is irrelevant
#define kShip_Max_Fall_Velocity         15.0f   // max down speed
#define kShip_Max_Vertical_Velocity     15.0f   // max up speed

#define kBulletSpeedNormal              800     // default bullet speed
#define kMaxBullets                     5       // maximum number of bullets before cooldown starts
#define kBulletCooldownNormal           0.1f   // time for the bullet cooldown
#define kBulletCooldownAtMax            5       // multiplier for cooldown when the player hits the max

typedef enum
{
	ShipWeaponNormal = 0,
	ShipWeaponAuto,
	ShipWeaponPassThrough,
    ShipWeaponSpread,
    ShipWeaponGodBeam
} WeaponLevels;

// some constants for the space rocks
#define kMaxNumRocks                    128     // max rocks to keep in the rock cache
#define kNumRockLanes                   8       // number of rows upon which to spawn rocks

#define kRockDensityStart               5    
#define kRockDensityAccel               24       // how often (number of columns spawned) do we increase density?
#define kMaxRockDensity                 100     // the number at which rock density is 100%
#define kRockDensityLimit               75      // the number at which we quit adding to the rock density


typedef enum
{
	GameSceneNodeTagBullet = 1,
	GameSceneNodeTagBulletSpriteBatch,
	GameSceneNodeTagBulletCache,
	GameSceneNodeTagEnemyCache,
	GameSceneNodeTagShip,
    GameSceneNodeTagSpaceRockCache
	
} GameSceneNodeTags;


@interface GameLayer : CCLayer 
{
    float scrollSpeed;
    float scrollAcceleration;
    float rockDensity;
    HUDLayer *hud;
    
}

+(GameLayer*) sharedGameLayer;

-(ShipEntity*) defaultShip;

@property (readonly, nonatomic) BulletCache* bulletCache;

@property (readonly, nonatomic) float scrollSpeed;
@property (readonly, nonatomic) float scrollAcceleration;
@property (readwrite, nonatomic) float rockDensity;
@property (readonly, nonatomic) HUDLayer *hud;

+(CGRect) screenRect;

@end

