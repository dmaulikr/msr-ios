//
//  Wind.h
//  msr-ios
//
//  Created by Macgill on 4/28/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

@interface Wind : CCNode

@property CCSprite *_windSprite;
@property int *_windType;

-(id)initWorld:(CCPhysicsNode *)_physicsWorld andScene: (GameScene *)_scene andType:(int)_type;

@end
