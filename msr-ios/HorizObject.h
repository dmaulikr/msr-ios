//
//  HorizObject.h
//  msr-ios
//
//  Created by Macgill on 5/3/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"

@interface HorizObject : CCNode

@property CCSprite *_objectSprite;
@property int *_objectType;

-(id)initWorld:(CCPhysicsNode *)_physicsWorld andScene: (GameScene *)_scene andType:(int *)_type andImgName:(NSString *)png;

    


@end
