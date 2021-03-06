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
#import "Player.h"
#import "Missile.h"
#import "Powerup.h"
#import "HorizObject.h"


// -----------------------------------------------------------------------
#pragma mark - GameScene
// -----------------------------------------------------------------------
const int MAX_MISSILES = 4;
const int BACKGROUND_SCROLL_SPEED = 4;
bool DEBUGbool = false;
bool gameRunning = false;
bool inIntroScene = true;
bool inTransition = false;
bool playerAlive = false;
bool imgLoop = false;
bool changingLevel = false;
bool onTransPhase1 = false;
//how much to increase score for powerups
const int POWERUP_INCREASE = 100;

int yVel = 0;

@implementation GameScene
{
    CCSprite *curr_transition_img;
    CCSprite *curr_loop_img_1;
    CCSprite *curr_loop_img_2;
    CCSprite *_ship;
    
    CCPhysicsNode *_physicsWorld;
    
    CCLabelTTF *_socialMediaMessage;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_introLabel;
    CCLabelTTF *_playGame;
    
    Player *_martian;
    Missile *_missile;
    NSDictionary *assets;
    Powerup *_powerup;
    CCLayoutBox *endMenu;
    HorizObject *_horizObject;
    NSUserDefaults *_defaults;
    
    int _score;
    int _currlevel;
    int _loopcounter;
    NSMutableArray * _missilesArray; //create an array of missiles,
    CCLabelTTF *highScoreLabel;
    
    CCSprite *transitionPic;
    
}

@synthesize manager;

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
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node + set up motion manager
    self.userInteractionEnabled = YES;
    self.manager = [[CMMotionManager alloc] init];
    [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(spriteUpdate:withDx:withDy:withDuration:) userInfo:nil repeats:YES];
    self.manager.accelerometerUpdateInterval = 0.05;
    [self.manager startAccelerometerUpdates];
    
    // Dictionary containing assets
    assets = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [NSArray arrayWithObjects:
                        @"3transition1.png", @"3transition2_two.png", @"3backgroundloop2_two.png", @"3backgroundloop2_two.png", nil], @"transitions",
                    [NSArray arrayWithObjects:
                        @"3backgroundloop1_two.png", @"3backgroundloop2_two.png", @"3backgroundloop2_two.png", @"3backgroundloop2_two.png", nil], @"backgrounds",
                    [NSArray arrayWithObjects:
                        @"comet3.png", @"rocket.png", @"rocket.png", @"rocket.png", nil], @"missiles",
                    [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:@"meteor1.png", @"meteor2.png", @"meteor3.png", @"meteor4.png", @"meteor5.png", nil], @"cloud_1.png",@"cloud_1.png", @"cloud_1.png", nil], @"clouds",
                    [NSArray arrayWithObjects:
                        @"satellite.png", @"plane_2.png", @"plane_2.png", @"plane_2.png", nil], @"horiz",
                    @"ArialRoundedMTBold", @"font",
              nil];
    _currlevel = 0;
    curr_loop_img_1 = [CCSprite spriteWithImageNamed:assets[@"backgrounds"][_currlevel]];
    curr_loop_img_2 = [CCSprite spriteWithImageNamed:assets[@"backgrounds"][_currlevel]];
    curr_transition_img = [CCSprite spriteWithImageNamed:assets[@"transitions"][_currlevel]];
    
    // first level setup
    curr_transition_img.position = CGPointMake(curr_transition_img.contentSize.width/2,self.contentSize.height - curr_transition_img.contentSize.height/2);
    [self addChild:curr_transition_img z:-3];
    
    curr_loop_img_1.position = CGPointMake(curr_transition_img.contentSize.width/2, curr_transition_img.position.y - curr_transition_img.contentSize.height/2 - curr_loop_img_2.contentSize.height/2 + 1);
    [self addChild:curr_loop_img_1 z:-4];
    
    curr_loop_img_2.position = CGPointMake(curr_loop_img_1.contentSize.width/2, curr_transition_img.position.y - curr_transition_img.contentSize.height/2 - curr_loop_img_1.contentSize.height/2 + 1);
    [self addChild:curr_loop_img_2 z:-4];
    
    [self schedule:@selector(introClouds:) interval:1.0]; // Animating sideways clouds
    
    // Spaceship
    CCAction *waverUp = [CCActionMoveTo actionWithDuration:0.8 position:CGPointMake(0.5f, 0.63f)];
    CCAction *waverDown = [CCActionMoveTo actionWithDuration:0.8 position:CGPointMake(0.5f, 0.58f)];
    _ship = [CCSprite spriteWithImageNamed:@"ufo.png"];
    _ship.positionType = CCPositionTypeNormalized;
    _ship.position = ccp(0.5f, 0.6f);
    [self addChild:_ship z:1];
    [_ship runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actionWithArray:@[waverDown, waverUp]]]];
    //turn intro scene bool on
    inIntroScene = true;
    inTransition = false;
    
    // Intro title
    _introLabel = [CCLabelTTF labelWithString: NSLocalizedString(@"Martian Fall", nil) fontName:assets[@"font"] fontSize:36.0f];
    [self fitLabeltoScreen:_introLabel];
    _introLabel.positionType = CCPositionTypeNormalized;
    _introLabel.color = [CCColor redColor];
    _introLabel.position = ccp(0.5f, 0.8f); // Middle of screen
    [self addChild: _introLabel];
    
    // Play button
    _playGame = [CCLabelTTF labelWithString:NSLocalizedString(@"Tap to begin", nil) fontName:assets[@"font"] fontSize:18.0f];
    [self fitLabeltoScreen:_playGame];
    _playGame.positionType = CCPositionTypeNormalized;
    _playGame.position = ccp(0.5f, 0.35f);
    [self addChild:_playGame];
    
	return self;
}

- (void)transition {
    inIntroScene = false;
    inTransition = true;
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(initGame) userInfo:nil repeats:NO];
    // Fade out buttons + clouds
    [self unschedule:@selector(introClouds:)];
    [_introLabel runAction:[CCActionFadeOut actionWithDuration:0.4]];
    [self removeChild:_playGame];
    
    // Initial missile
    CCSprite *missile = [CCSprite spriteWithImageNamed:@"comet3.png"];
    missile.positionType = CCPositionTypeNormalized;
    missile.position = ccp(0.5f, 0);
    [self addChild:missile];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:2.0 position:_ship.position];
    CCAction *actionRemove = [CCActionRemove action];
    [missile runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    
}

- (void)initGame {
    inTransition = false;
    
    // Initialize the highscore table
    
    _defaults = [NSUserDefaults standardUserDefaults];
    
    // Destroy ship
    //replace with bigger boom image
    CCSprite *boomer = [CCSprite spriteWithImageNamed:(@"bigboomer.png")];
    CGPoint new_pos = _ship.positionInPoints;
    new_pos.y = new_pos.y + 10;
    boomer.position  = new_pos;
    [self addChild:boomer z:3];
    [self removeChild:_ship];
    [[OALSimpleAudio sharedInstance] playBg:@"explosion2.wav" loop:NO];

    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.8];
    CCAction *actionRemove = [CCActionRemove action];
    [boomer runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    
     // Set up the physics world
     _physicsWorld = [CCPhysicsNode node];
     _physicsWorld.gravity = ccp(0,0);
     _physicsWorld.debugDraw = NO; //for debug put yes
     _physicsWorld.collisionDelegate = self;
     [self addChild:_physicsWorld z:-1];
    
    // Player
    _martian = [[Player alloc] initWorld:_physicsWorld withPosition: new_pos andScene:self];
    playerAlive = true;
    
     // Init and alloc mutable missile array
     _missilesArray = [[NSMutableArray alloc] init];
    
    // Create a info button for testing
    CCSpriteFrame *infoFrame = [CCSpriteFrame frameWithImageNamed:@"info.png"];
    CCButton *infoButton = [CCButton buttonWithTitle:@" " spriteFrame:infoFrame];
    infoButton.positionType = CCPositionTypeNormalized;
    infoButton.position = ccp(0.91f, 0.95f); // Top Right of screen
    [infoButton setTarget:self selector:@selector(onInfoButtonClick:)];
    [self addChild:infoButton];

    
    // Initialize the score & its label
    _score = 0;
    _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",_score] fontName:assets[@"font"] fontSize:14.0f];
    _scoreLabel.positionType = CCPositionTypeNormalized;
    _scoreLabel.color = [CCColor whiteColor];
    _scoreLabel.position = ccp(0.15f, 0.95f); // Top right corner
    [self addChild:_scoreLabel];
    
     // Schedule upwards clouds & sky
    [self schedule:@selector(addCloud:) interval:1.5];
    [self schedule:@selector(moveBackground:) interval:0.03];
    [self schedule:@selector(addHObject:) interval:5];
    
    //End of game menu, created now but added only at end of game
    // Create a playAgain button for end of game
    CCButton *playAgainButton = [CCButton buttonWithTitle:NSLocalizedString(@"[ Play ]", nil) fontName:assets[@"font"] fontSize:20.0f];
    [playAgainButton setTarget:self selector:@selector(onPlayAgainClick:)];
    
    //make twitter button
    CCSpriteFrame *weiboFrame = [CCSpriteFrame frameWithImageNamed:@"weibo2.png"];
    CCButton *weiboB = [CCButton buttonWithTitle:@" " spriteFrame:weiboFrame];
    [weiboB setTarget:self selector:@selector(onWeiboClick:)];

    //make facebook button
    CCSpriteFrame *facebookFrame = [CCSpriteFrame frameWithImageNamed:@"facebook.png"];
    CCButton *facebookB = [CCButton buttonWithTitle:@" " spriteFrame:facebookFrame];
    [facebookB setTarget:self selector:@selector(onFacebookClick:)];
    
    //make twitter button
    CCSpriteFrame *twitterFrame = [CCSpriteFrame frameWithImageNamed:@"twitterSmall.png"];
    CCButton *twitterB = [CCButton buttonWithTitle:@" " spriteFrame:twitterFrame];
    [twitterB setTarget:self selector:@selector(onTwitterClick:)];

    highScoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"High score:"] fontName:@"Verdana-Bold" fontSize:16.0f];
    [self fitLabeltoScreen:highScoreLabel];
    highScoreLabel.positionType = CCPositionTypeNormalized;
    highScoreLabel.color = [CCColor whiteColor];
    
    endMenu = [[CCLayoutBox alloc] init];
    endMenu.direction = CCLayoutBoxDirectionVertical;
    endMenu.spacing = 10.f;
    [endMenu setAnchorPoint:CGPointMake(.5, .5)];
    endMenu.position = CGPointMake(self.contentSize.width/2,self.contentSize.height/2);

    //only add weibo is language is chinese
    if ([[[NSLocale preferredLanguages] objectAtIndex:0]  isEqual: @"zh"]) {
        [endMenu addChild:weiboB];
    }
    [endMenu addChild:facebookB];
    [endMenu addChild:twitterB];
    [endMenu addChild:playAgainButton];
    [endMenu addChild:highScoreLabel];
    
    //start the gameRunning
    gameRunning = true;

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
    [self schedule:@selector(addMissile:) interval:2];
    [self schedule:@selector(incrementScore) interval:0.1];
    [self schedule:@selector(addPowerup:) interval:4.5];
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

- (void)introClouds:(CCTime)dt {
    NSArray *clouds = assets[@"clouds"][0];
    int randomCloud = (arc4random() % [clouds count]);
    CCSprite *cloud = [CCSprite spriteWithImageNamed:clouds[randomCloud]];
    [cloud setName:@"cloud"];

    // Set time and space bounds for cloud generation
    int maxY = self.contentSize.height;
    int randomY = (arc4random() % maxY);
    int minDuration = 1.8;
    int maxDuration = 2.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    cloud.position = CGPointMake(self.contentSize.width, randomY);
    [self addChild:cloud z:-2];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(0 - cloud.contentSize.width, randomY)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
}

- (void)addCloud:(CCTime)dt {
    CCSprite *cloud;
    if (_currlevel == 0) {
        NSArray *clouds = assets[@"clouds"][0];
        int randomCloud = (arc4random() % [clouds count]);
        cloud = [CCSprite spriteWithImageNamed:clouds[randomCloud]];
    }
    else {
        cloud = [CCSprite spriteWithImageNamed: assets[@"clouds"][_currlevel]];
    }
        
    // Set time and space bounds for cloud generation
    int maxX = self.contentSize.width;
    int randomX = (arc4random() % maxX);
    int minDuration = 1.8;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int randomDuration = (arc4random() % rangeDuration) + minDuration;
    
    cloud.position = CGPointMake(randomX, 0);
    [self addChild:cloud z:-2];
    
    CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration position:CGPointMake(randomX, self.contentSize.height + cloud.contentSize.height)];
    CCAction *actionRemove = [CCActionRemove action];
    [cloud runAction:[CCActionSequence actionWithArray:@[actionMove,actionRemove]]];
    
}
-(void)addHObject:(CCTime)dt {
    //random type
    int *_type = arc4random() % 2;
    _horizObject = [[HorizObject alloc] initWorld:_physicsWorld andScene:self andType:_type andImgName:assets[@"horiz"][_currlevel]];
}

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Scoring
// -----------------------------------------------------------------------

- (void)incrementScore
{
    if (gameRunning == true) {
        _score++;
        [_scoreLabel setString:[NSString stringWithFormat:NSLocalizedString(@"Score: %03d", nil), _score]];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //make it so if you tap anywhere on screen while on intro scene and the game begins
    if (inIntroScene == true) {
        [self transition];
    }
    
    else if (!inTransition) {
        // A touch gives an acceleration in the y-direction

        [self spriteUpdate:nil withDx:0 withDy:100.0 withDuration:0.22];
        
        //play jump sound
        if (playerAlive) {
            [[OALSimpleAudio sharedInstance] playBg:@"jump.wav" loop:NO];
        }
    }
}
// -----------------------------------------------------------------------
#pragma mark - Accelerometer movement
// -----------------------------------------------------------------------
-(void) spriteUpdate:(NSTimer *) timer withDx:(float) dx withDy:(float) dy withDuration:(float) dur{
    
    
    /* NOTE: Issue: Still little collisions with invisbile wall. Not sure how to fix */
    
    //NSLog(@"%f", dur);
    float accelX = self.manager.accelerometerData.acceleration.x;
    //float accelY = self.manager.accelerometerData.acceleration.y;
    
    //NSLog(@"Falling at %f", accelY);
    
    CGPoint newAccel = CGPointMake(accelX * 15 + dx, dy - 2.8);
    
    CGPoint newVel = CGPointMake(_martian.physicsBody.surfaceVelocity.x + newAccel.x,
                                 _martian.physicsBody.surfaceVelocity.y + newAccel.y);
    
    CGPoint moveLoc = CGPointMake (_martian._sprite.position.x + newVel.x,
                                   _martian._sprite.position.y + newVel.y);
    
    moveLoc = [self playerBoundBox:moveLoc];
    
    /* If this task was scheduled... */
    if (dur <= 1) {
        dur = 0.10f;
    }
    
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:dur position:moveLoc];
    
    [_martian._sprite runAction:actionMove];
}

// -----------------------------------------------------------------------
#pragma mark - Bounding box for player function - make sure player stays on screen
// -----------------------------------------------------------------------
-(CGPoint)playerBoundBox:(CGPoint) playerLoc {
    int padding = _martian.contentSize.width + 5;
    float extra = 0;
    //check x coordinates
    if (playerLoc.x > (self.contentSize.width + padding)) {
        extra = playerLoc.x - (self.contentSize.width + padding);
        playerLoc.x = playerLoc.x - extra;
    } else if (playerLoc.x < -10) {
        playerLoc.x = -10;
    }

    //check y coordinates, keep y coords in top 2/3 of screen
    if (playerLoc.y > (self.contentSize.height + padding)) {
        extra = playerLoc.y - (self.contentSize.height + padding);
        playerLoc.y = playerLoc.y - extra;
    } else if (playerLoc.y < (self.contentSize.height/3)) {
        playerLoc.y = (self.contentSize.height/3);
    }
    
    return playerLoc;
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
- (void)onPlayAgainClick:(id)sender
{
    //transition to begin of this scene again
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
     withTransition:[CCTransition transitionCrossFadeWithDuration:0.3f]];

}
// -----------------------------------------------------------------------
#pragma mark - Social Media Sharing Functions
// -----------------------------------------------------------------------

- (void)onTwitterClick:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:NSLocalizedString(@"I just scored %d in #MartianFall. Play for yourself at ", nil), _score];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText: shareMessage];
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        CCLabelTTF *twitterMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"No Twitter account found.",nil) fontName:@"Verdana-Bold" fontSize:18.0f];
        [self fitLabeltoScreen:twitterMessage];
        twitterMessage.positionType = CCPositionTypeNormalized;
        twitterMessage.position = ccp(0.5f, 0.8f); // Middle of screen
        [self addChild: twitterMessage];
        CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
        CCAction *actionRemove = [CCActionRemove action];
        _socialMediaMessage = twitterMessage;
        [_socialMediaMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    }
}

- (void)onFacebookClick:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:NSLocalizedString(@"I just scored %d in #MartianFall. Play for yourself at ", nil), _score];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [tweetSheet setInitialText: shareMessage];
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        CCLabelTTF *fbMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"No Facebook account found.", nil) fontName:@"Verdana-Bold" fontSize:18.0f];
        [self fitLabeltoScreen:fbMessage];
        fbMessage.positionType = CCPositionTypeNormalized;
        fbMessage.position = ccp(0.5f, 0.8f); // Middle of screen
        [self addChild: fbMessage];
        CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
        CCAction *actionRemove = [CCActionRemove action];
        _socialMediaMessage = fbMessage;
        [_socialMediaMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    }
}

- (void)onWeiboClick:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:NSLocalizedString(@"I just scored %d in #MartianFall. Play for yourself at ", nil), _score];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]){
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        [tweetSheet setInitialText: shareMessage];
        [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        CCLabelTTF *weiboMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"No Weibo account found.", nil) fontName:@"Verdana-Bold" fontSize:18.0f];
        [self fitLabeltoScreen:weiboMessage];
        weiboMessage.positionType = CCPositionTypeNormalized;
        weiboMessage.position = ccp(0.5f, 0.8f); // Middle of screen
        [self addChild: weiboMessage];
        CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
        CCAction *actionRemove = [CCActionRemove action];
        _socialMediaMessage = weiboMessage;
        [_socialMediaMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Tutorial button
// -----------------------------------------------------------------------

-(void)onInfoButtonClick:(id)sender {
    
    //[[CCDirector sharedDirector] pause];
    
    //CCSprite *tutorialPic =
    
    
    CCLabelTTF *infoMessage = [CCLabelTTF labelWithString:NSLocalizedString(@"Tap to move up, turn to move left and right.", nil) fontName:@"Verdana-Bold" fontSize:18.0f];
    [self fitLabeltoScreen:infoMessage];
    infoMessage.positionType = CCPositionTypeNormalized;
    infoMessage.position = ccp(0.5f, 0.2f); // Middle of screen
    [self addChild: infoMessage];
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.8];
    CCAction *actionRemove = [CCActionRemove action];
    [infoMessage runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];

}
// -----------------------------------------------------------------------
#pragma mark - Move Scrolling Background
// -----------------------------------------------------------------------
-(void)moveBackground:(CCTime)delta{
    CGPoint bgPos_trans = curr_transition_img.position;
    CGPoint bgPos2 = curr_loop_img_1.position;
    CGPoint bgPos3 = curr_loop_img_2.position;
    bgPos_trans.y = bgPos_trans.y + BACKGROUND_SCROLL_SPEED;
    bgPos2.y = bgPos2.y + BACKGROUND_SCROLL_SPEED;
    bgPos3.y = bgPos3.y + BACKGROUND_SCROLL_SPEED;
    
    //NSLog(@"We are in moveBackground %i", _loopcounter);
    
    
    if (bgPos2.y  - curr_loop_img_1.contentSize.height/2 > 0.0) { // first loop image about to leave screen
        if (imgLoop == false){
            imgLoop = true;
            _loopcounter++;
        }
        
        //time to enter a transition if loop counter is whatever and the first image is above second image
        //unschedule movebackground, the whole screen is filled by image one
        if (_loopcounter == 1) {
            //[self unschedule:@selector(moveBackground:)];
            bgPos_trans = [self changeLevel];
            NSLog(@"back from change level");
        }
        
        bgPos3.y = bgPos2.y - curr_loop_img_1.contentSize.height/2 - curr_loop_img_2.contentSize.height/2 + 1;
    }
    if (bgPos3.y - curr_loop_img_2.contentSize.height/2 > 0.0) { // second loop image about to leave screen
        imgLoop = false;
        bgPos2.y = bgPos3.y - curr_loop_img_2.contentSize.height/2 - curr_loop_img_1.contentSize.height/2 + 1;
    }
    
    bgPos_trans.y = (int)bgPos_trans.y;
    bgPos2.y = (int)bgPos2.y;
    bgPos3.y = (int)bgPos3.y;
    //setting of curr_loop_img_1 to the x of curloopimg2 because the x was off, dont know why
    bgPos2.x = (int)bgPos3.x;
    curr_transition_img.position = bgPos_trans; //this is chagning it back to the old positoin
    curr_loop_img_1.position = bgPos2;
    curr_loop_img_2.position = bgPos3;
    
    
}
// -----------------------------------------------------------------------
#pragma mark - Level transitions
// -----------------------------------------------------------------------

//NOTE: this is off by like 10 pixels
-(CGPoint)changeLevel {
    CGPoint bgPos1 = curr_loop_img_1.position;
    CGPoint bgPos2 = curr_loop_img_2.position;
    CGPoint bgPos_trans;
    //CGPoint bgPos3 = curr_transition_img.position;

    //reschedule move background, up this to 2?
    if (_currlevel < 3) {
        _currlevel++; //we need to only do this once
    } else {
        _currlevel = 2;
    }
    _loopcounter = 0;
    
    NSLog(@"cur level new %d ", _currlevel);

    //remove old images
    [self removeChild:curr_loop_img_1];
    [self removeChild:curr_loop_img_2];
    [self removeChild:curr_transition_img];
    
    curr_loop_img_1 = [CCSprite spriteWithImageNamed:assets[@"backgrounds"][_currlevel]];
    curr_loop_img_2 = [CCSprite spriteWithImageNamed:assets[@"backgrounds"][_currlevel]];
    curr_transition_img = [CCSprite spriteWithImageNamed:assets[@"transitions"][_currlevel]];

    //[curr_transition_img setAnchorPoint:CGPointMake(.5, 0)];
    //need to get cur_transition_img_posiotn y right
    bgPos_trans = bgPos1;
    bgPos_trans.y = bgPos_trans.y - (curr_loop_img_1.contentSize.height/2);
    curr_transition_img.position = bgPos_trans;//= bgPos1;
    curr_loop_img_1.position = bgPos1;
    curr_loop_img_2.position = bgPos2;

    bgPos1.y = (int)bgPos1.y;
    bgPos2.y = (int)bgPos2.y;
    bgPos_trans.y = (int)bgPos_trans.y;
    curr_transition_img.position = bgPos_trans;
    curr_loop_img_1.position = bgPos1;
    curr_loop_img_2.position = bgPos2;

    [self addChild:curr_loop_img_1 z:-3];
    [self addChild:curr_loop_img_2 z:-3];
    [self addChild:curr_transition_img z:-3];
    
    return bgPos_trans;

}
// -----------------------------------------------------------------------
#pragma mark - Add Missile
// -----------------------------------------------------------------------
-(void)addMissile:(CCTime)delta
{
    _missile = [[Missile alloc] initPlayer:_martian andWorld:_physicsWorld andScene:self andImgName:assets[@"missiles"][_currlevel]];
    //add missile to array
    [_missilesArray addObject: _missile];
    [self schedule:(@selector(trackPlayerwithMissile)) interval:0.07];
}

// -----------------------------------------------------------------------
#pragma mark - For missiles to track players
// -----------------------------------------------------------------------

-(void)trackPlayerwithMissile{

    //remove all missiles that have passed end of screen
    [self cleanUpArray];
    
    int num_missiles = (int)[_missilesArray count];
    CGPoint playerPos = _martian._sprite.position;
    
    if(DEBUGbool == true) {
        CCLOG(@"number of missiles in num_missiles %d", num_missiles);
    }
    
    for (int i= 0; i < num_missiles; i++) {
        Missile *cur_miss = [_missilesArray objectAtIndex:(i)];
        CGPoint missilePos = cur_miss.missile.position;
        
        if ((playerPos.x >= missilePos.x) && (playerPos.y > missilePos.y)) {
            missilePos.x = missilePos.x + 1;
            cur_miss.missile.position = missilePos;
        } else if ((playerPos.x <= missilePos.x) && (playerPos.y > missilePos.y)) {
            missilePos.x = missilePos.x - 1;
            cur_miss.missile.position = missilePos;
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Remove missiles that have passed off the screen
// -----------------------------------------------------------------------

-(void)cleanUpArray {
    for (int i= 0; i < (int)[_missilesArray count]; i++) {
        Missile *cur_miss = [_missilesArray objectAtIndex:(i)];
        if (cur_miss.missile.position.y > (self.contentSize.height + cur_miss.missile.contentSize.height)) {
            [_missilesArray removeObjectAtIndex:(i)];
            i--; //decrement i becuase we just removed one index
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Collision Detection for Missiles and Player
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missileCollision:(CCNode *)missile playerCollision:(CCNode *)player {
    
    CCSprite *boomer = [CCSprite spriteWithImageNamed:(@"boomer.png")];
    CGPoint new_pos = missile.position;
    new_pos.y = new_pos.y + 10;
    boomer.position  = new_pos;
    [self addChild:boomer z:-1];

    [missile removeFromParent];
    [player removeFromParent];
    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:2.0];
    CCAction *actionRemove = [CCActionRemove action];
    [boomer runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];

    //stop the score & control scheme
    gameRunning = false;
    
    // Create the ending menu
    [self createHighScoreLabel];
    [self addChild:endMenu];
    
    //play sound
    [[OALSimpleAudio sharedInstance] playBg:@"explosion2.wav" loop:NO];
    
    //player is dead
    playerAlive = false;
    
    return YES;
}


// -----------------------------------------------------------------------
#pragma mark - High Score Calculation and Storing
// -----------------------------------------------------------------------

-(void) createHighScoreLabel {
    
    int highScore;
    
    // If the app is running for the first time, set the high score
    if (![_defaults floatForKey:@"firstRun"]) {
        
        [_defaults setFloat:1 forKey:@"firstRun"];
        [_defaults setFloat:_score forKey:@"SavedHighScore"];
        
        highScore = _score;
    }
    
    // Otherwise, check if the highscore needs to be updated
    else {
        highScore = [[_defaults valueForKey:@"SavedHighScore"] intValue];
        
        if (_score > highScore) {
            [_defaults setFloat:_score forKey:@"SavedHighScore"];
            highScore = _score;
        }
    }
    
    [_defaults synchronize];
    [highScoreLabel setString:[NSString stringWithFormat:NSLocalizedString(@"High Score: %d", nil), highScore]];
    
}
// -----------------------------------------------------------------------
#pragma mark - Add Powerup
// -----------------------------------------------------------------------
-(void)addPowerup:(CCTime)delta
{
    _powerup = [[Powerup alloc] initWithPhysicsWorld: _physicsWorld andGameScene:self];
}

// -----------------------------------------------------------------------
#pragma mark - Collision Detection for Powerups and player
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair powerupCollision:(CCNode *)powerup playerCollision:(CCNode *)player {
    
    //increment score on powerup collision
    _score = _score + POWERUP_INCREASE;
    
    CCLabelTTF *pUp = [CCLabelTTF labelWithString:@"+100" fontName:@"ArialRoundedMTBold" fontSize:13.0f];
    pUp.color = [CCColor whiteColor];
    CGPoint new_pos = powerup.position;
    new_pos.y = new_pos.y + 10;
    pUp.position  = new_pos;
    [self addChild:pUp z:-2];
    
    [powerup removeFromParent];
    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:1.0];
    CCAction *actionRemove = [CCActionRemove action];
   
    [pUp runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    
    //play sound
    [[OALSimpleAudio sharedInstance] playBg:@"powerup1.wav" loop:NO];
    return YES;
}
// -----------------------------------------------------------------------
#pragma mark - Collision Detection for Powerups and missiles
// -----------------------------------------------------------------------

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missileCollision:(CCNode *)missile powerupCollision:(CCNode *)powerup {
    
    CCSprite *boomer = [CCSprite spriteWithImageNamed:(@"fireworks.png")];
    CGPoint new_pos = missile.position;
    new_pos.y = new_pos.y + 10;
    boomer.position  = new_pos;
    [self addChild:boomer z:-1];
    
    [missile removeFromParent];
    [powerup removeFromParent];
    
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:1.0];
    CCAction *actionRemove = [CCActionRemove action];
    
    [boomer runAction:[CCActionSequence actionWithArray:@[fadeOut,actionRemove]]];
    
    return YES;
}
// -----------------------------------------------------------------------
 #pragma mark - Collision Detection for HorizObject and player
 // -----------------------------------------------------------------------
 - (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair windCollision:(CCNode *)wind playerCollision:(CCNode *)player {
 
 return YES;
 }
 // -----------------------------------------------------------------------
 #pragma mark - Collision Detection for HorizObject and Powerup
 // -----------------------------------------------------------------------
 - (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair windCollision:(CCNode *)wind powerupCollision:(CCNode *)player {
 
 return YES;
 }
// -----------------------------------------------------------------------
#pragma mark - Make sure label fits the screen
// -----------------------------------------------------------------------
- (void) fitLabeltoScreen:(CCLabelTTF *)label {
        float fontSize = [label fontSize];//[self fontSize];
        float fontAdjustmentStep = 0.5f;
        
        while((self.contentSize.width - 20) < label.contentSize.width)
        {
            fontSize -= fontAdjustmentStep;
            [label setFontSize:fontSize];
            if( fontSize < 5)
            {
                break;
            }
        }
}
@end
