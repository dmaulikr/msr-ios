//
//  Missile.h
//  msr-ios
//
//  Created by Macgill on 4/22/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"

@interface Missile : CCNode

@property CCSprite *missile;
@property Player *player;

-(id)initPlayer: (Player *)_martian andWorld:(CCPhysicsNode *)_physicsWorld andScene: (GameScene *)_scene andImgName:(NSString *)png;


@end
