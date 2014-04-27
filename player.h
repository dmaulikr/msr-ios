//
//  Player.h
//  msr-ios
//
//  Created by Macgill on 4/22/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

@interface Player : CCNode

@property CCSprite *_sprite;
@property float dx;
@property float dy;

-(id)initWorld: (CCPhysicsNode *)_phyicsWorld andScene:(GameScene *) _scene;

@end
