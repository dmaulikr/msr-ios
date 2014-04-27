//
//  Powerup.h
//  msr-ios
//
//  Created by Macgill on 4/25/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

@interface Powerup : CCNode

@property CCSprite *_sprite;

-(id)initWithPhysicsWorld:(CCPhysicsNode *)_physicsWorld andGameScene:(GameScene *)_scene;

@end
