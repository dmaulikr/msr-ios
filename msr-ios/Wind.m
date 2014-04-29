//
//  Wind.m
//  msr-ios
//
//  Created by Macgill on 4/28/14.
//  Copyright 2014 o2bt. All rights reserved.
//

#import "Wind.h"


@implementation Wind

@synthesize _windSprite;
@synthesize _windType;

-(id)initWorld:(CCPhysicsNode *)_physicsWorld andScene: (GameScene *)_scene andType:(int)_type {
    self = [super init];
    
    _windType = _type;
    //type 0 = horizontal wind, right to left
    //type 1 = horizontal wind, left to right
    //type 2 = vertical wind, bottom to top
    if(_type == 0) {
        _windSprite = [CCSprite spriteWithImageNamed:@"windHorizontalSmall.png"];
        
        // Make appear at a random Y coordinate
        int minY = _windSprite.contentSize.height / 2;
        int maxY = _scene.contentSize.height - _windSprite.contentSize.height / 2;
        int rangeY = maxY - minY;
        int randomY = (arc4random() % rangeY) + minY;
        
        int minDuration = 2.0;
        int maxDuration = 7.0;
        int rangeDuration = maxDuration - minDuration;
        int randomDuration = (arc4random() % rangeDuration) + minDuration;
        
        _windSprite.position = CGPointMake(0, randomY);
        //NOTE: make body bigger than the wind itself
        _windSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _windSprite.contentSize} cornerRadius:0];
        _windSprite.physicsBody.collisionGroup = @"windGroup";
        _windSprite.physicsBody.collisionType  = @"windCollision";
        [_physicsWorld addChild:_windSprite z:-1];
        
        CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(_scene.contentSize.width + _windSprite.contentSize.width, randomY)];
        CCAction *actionRemove = [CCActionRemove action];
        [_windSprite runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    } else if (_type == 1) {
        _windSprite = [CCSprite spriteWithImageNamed:@"windHorizontalSmall.png"];
        
        // Make appear at a random Y coordinate
        int minY = _windSprite.contentSize.height / 2;
        int maxY = _scene.contentSize.height - _windSprite.contentSize.height / 2;
        int rangeY = maxY - minY;
        int randomY = (arc4random() % rangeY) + minY;
        
        int minDuration = 2.0;
        int maxDuration = 7.0;
        int rangeDuration = maxDuration - minDuration;
        int randomDuration = (arc4random() % rangeDuration) + minDuration;
        
        _windSprite.position = CGPointMake(_scene.contentSize.width + _windSprite.contentSize.width, randomY);;
        //NOTE: make body bigger than the wind itself
        _windSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _windSprite.contentSize} cornerRadius:0];
        _windSprite.physicsBody.collisionGroup = @"aerialGroup";
        _windSprite.physicsBody.collisionType  = @"windCollision";
        [_physicsWorld addChild:_windSprite z:-1];
        
        CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(-(_windSprite.contentSize.width), randomY)];
        CCAction *actionRemove = [CCActionRemove action];
        [_windSprite runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
        
    } else {
        //vertical type 2        
        _windSprite = [CCSprite spriteWithImageNamed:@"windVertical.png"];

        // Make appear at a random X coordinate
        int minX = _windSprite.contentSize.width / 2;
        int maxX = _scene.contentSize.width - _windSprite.contentSize.width / 2;
        int rangeX = maxX - minX;
        int randomX = (arc4random() % rangeX) + minX;
        
        int minDuration = 2.0;
        int maxDuration = 7.0;
        int rangeDuration = maxDuration - minDuration;
        int randomDuration = (arc4random() % rangeDuration) + minDuration;
        
        _windSprite.position = CGPointMake(randomX, 0);//-(self.contentSize.height + missile.contentSize.height));
        _windSprite.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _windSprite.contentSize} cornerRadius:0];
        _windSprite.physicsBody.collisionGroup = @"windGroup";
        _windSprite.physicsBody.collisionType  = @"windCollision";
        [_physicsWorld addChild:_windSprite z:-1];
        
        CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, _scene.contentSize.height + _windSprite.contentSize.height)];
        CCAction *actionRemove = [CCActionRemove action];
        [_windSprite runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
        
    }
    return self;

}


/********************************* belongs in GameScene.m ****************************************/
/*#import "Wind.h"*/

/*[self schedule:@selector(addWind:) interval:5];*/

/*Wind *_wind;*/


/*// -----------------------------------------------------------------------
 #pragma mark - Add Wind
 // -----------------------------------------------------------------------
 -(void)addWind:(CCTime)delta
 {
 //random type
 int _type = arc4random() % 3;
 _wind = [[Wind alloc] initWorld:_physicsWorld andScene:self andType:_type];
 }*/




/*// -----------------------------------------------------------------------
 #pragma mark - Collision Detection for Wind and player
 // -----------------------------------------------------------------------
 - (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair windCollision:(CCNode *)wind playerCollision:(CCNode *)player {
 
 return YES;
 }
 // -----------------------------------------------------------------------
 #pragma mark - Collision Detection for Wind and Powerup
 // -----------------------------------------------------------------------
 - (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair windCollision:(CCNode *)wind powerupCollision:(CCNode *)player {
 
 return YES;
 }*/
/********************************* belongs in GameScene.m ****************************************/



@end
