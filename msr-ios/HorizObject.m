//
//  HorizObject.m
//  msr-ios
//
//  Created by Macgill on 5/3/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import "HorizObject.h"


@implementation HorizObject

@synthesize _objectSprite;
@synthesize _objectType;

-(id)initWorld:(CCPhysicsNode *)_physicsWorld andScene: (GameScene *)_scene andType:(int *)_type andImgName:(NSString *)png{
    self = [super init];
    
    _objectType = _type;
    //type 0 = horizontal wind, right to left
    //type 1 = horizontal wind, left to right
    //type 2 = vertical wind, bottom to top
    if(_type == 0) {
        _objectSprite = [CCSprite spriteWithImageNamed:png];
        
        // Make appear at a random Y coordinate
        int minY = _objectSprite.contentSize.height / 2;
        int maxY = _scene.contentSize.height - _objectSprite.contentSize.height / 2;
        int rangeY = maxY - minY;
        int randomY = (arc4random() % rangeY) + minY;
        
        int minDuration = 2.0;
        int maxDuration = 7.0;
        int rangeDuration = maxDuration - minDuration;
        int randomDuration = (arc4random() % rangeDuration) + minDuration;
        
        _objectSprite.position = CGPointMake(0, randomY);
        //NOTE: make body bigger than the wind itself
        _objectSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _objectSprite.contentSize} cornerRadius:0];
        _objectSprite.physicsBody.collisionGroup = @"aerialGroup";
        _objectSprite.physicsBody.collisionType  = @"windCollision";
        [_physicsWorld addChild:_objectSprite z:-1];
        
        CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(_scene.contentSize.width + _objectSprite.contentSize.width, randomY)];
        CCAction *actionRemove = [CCActionRemove action];
        [_objectSprite runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    } else {
        _objectSprite = [CCSprite spriteWithImageNamed:png];
        
        // Make appear at a random Y coordinate
        int minY = _objectSprite.contentSize.height / 2;
        int maxY = _scene.contentSize.height - _objectSprite.contentSize.height / 2;
        int rangeY = maxY - minY;
        int randomY = (arc4random() % rangeY) + minY;
        
        int minDuration = 2.0;
        int maxDuration = 7.0;
        int rangeDuration = maxDuration - minDuration;
        int randomDuration = (arc4random() % rangeDuration) + minDuration;
        
        _objectSprite.position = CGPointMake(_scene.contentSize.width + _objectSprite.contentSize.width, randomY);;
        //NOTE: make body bigger than the wind itself
        //_objectSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _objectSprite.contentSize} cornerRadius:0];
        //_objectSprite.physicsBody.collisionGroup = @"aerialGroup";
        //_objectSprite.physicsBody.collisionType  = @"windCollision";
        [_physicsWorld addChild:_objectSprite z:-1];
        
        CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(-(_objectSprite.contentSize.width), randomY)];
        CCAction *actionRemove = [CCActionRemove action];
        [_objectSprite runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
        
    }
    return self;
    
}


@end
