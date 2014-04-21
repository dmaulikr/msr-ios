//
//  GameScene.m
//  msr-ios
//
//  Created by barari on 4/19/14.
//  Copyright o2bt 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "GameScene.h"
#import "IntroScene.h"

// -----------------------------------------------------------------------
#pragma mark - GameScene
// -----------------------------------------------------------------------

@implementation GameScene
{
    CCSprite *_martian;
    CCSprite *_background;
    CCPhysicsNode *_physicsWorld;    
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (GameScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    //add image as background
    _background = [CCSprite spriteWithImageNamed:@"background.png"];
    [self addChild:_background z:-2];
    
    //set up the physics world
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    _physicsWorld.debugDraw = NO; //for debug put yes
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
    
    // Add martian
    _martian = [CCSprite spriteWithImageNamed:@"martian.png"];
    _martian.position  = ccp(self.contentSize.width/2,4*self.contentSize.height/5);
    [self addChild:_martian];
    
    // Animate sprite with action
    CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:2.5f angle:360];
    [_martian runAction:[CCActionRepeatForever actionWithAction:actionSpin]];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];

    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    [self schedule:@selector(moveBackground:) interval:0.03];
    [self schedule:@selector(addCloud:) interval:1.5];
    [self schedule:@selector(addMissile:) interval:2];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

- (void)addCloud:(CCTime)dt {
    CCSprite *cloud = [CCSprite spriteWithImageNamed:@"cloud.png"];
    
    // Set time and space bounds for cloud generation
    int maxX = self.contentSize.width;
    int randomX = (arc4random() % maxX);
    int minDuration = 1.0;
    int maxDuration = 3.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    cloud.position = CGPointMake(randomX, 0);
    [self addChild:cloud z:-1];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, self.contentSize.height + cloud.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    // Move our sprite to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.4f position:touchLoc];
    [_martian runAction:actionMove];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
#pragma mark - Move Scrolling Background
// -----------------------------------------------------------------------

-(void)moveBackground:(CCTime)delta
{
    CGPoint bgPos = _background.position;
    bgPos.y = bgPos.y + 4.0;
    
    if (bgPos.y > _background.contentSize.height - self.contentSize.height) {
        bgPos.y = 0;
    }
    _background.position = bgPos;
    CCLOG(@"background x,y is @ %@", NSStringFromCGPoint(bgPos));

}
// -----------------------------------------------------------------------
#pragma mark - Add Missile
// -----------------------------------------------------------------------
-(void)addMissile:(CCTime)delta
{
    CCSprite *missile = [CCSprite spriteWithImageNamed:@"missile.png"];
    
    // Make appear at a random X coordinate
    int minX = missile.contentSize.width / 2;
    int maxX = self.contentSize.width - missile.contentSize.width / 2;
    int rangeX = maxX - minX;
    int randomX = (arc4random() % rangeX) + minX;
    
    int minDuration = 2.0;
    int maxDuration = 7.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    missile.position = CGPointMake(randomX, 0);//-(self.contentSize.height + missile.contentSize.height));
    [self addChild:missile];

    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, self.contentSize.height + missile.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [missile runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
}

@end
