//
//  BallController.mm
//  pachitest2
//
//  Created by elanz on 8/29/11.
//  Copyright (c) 2011 200Monkeys. All rights reserved.
//

#import "BallController.h"
#import "WorldController.h"
#import "cocos2d.h"

#define launchPointX 320
#define launchPointY 64

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

@interface bodyContainer : NSObject

@property (nonatomic, readwrite) b2Body * body;
    
@end

@implementation bodyContainer

@synthesize body;

@end

@implementation BallController

- (id) initWithLayer:(CCLayer*)MainGameLayer andWorld:(WorldController*)TheWorld;
{
    if( (self=[super init])) {
        mainGameLayer = MainGameLayer;
        theWorld = TheWorld;
        
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"ball.png" capacity:150];
		[mainGameLayer addChild:batch z:0 tag:kTagBatchNode];
        
        ballLaunchPending = NO;
        
        ballArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (CGPoint) getLaunchPoint
{
    return ccp( launchPointX, launchPointY);
}

- (void) processPendingBalls
{
    CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [mainGameLayer getChildByTag:kTagBatchNode];
	
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(0,0,10,10)];
	[batch addChild:sprite];
	
	sprite.position = [self getLaunchPoint];
	
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(launchPointX/PTM_RATIO, launchPointY/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = theWorld.World->CreateBody(&bodyDef);
	
	b2CircleShape dynamicCircle;
	dynamicCircle.m_radius = .2;
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicCircle;	
	fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.1f;
    fixtureDef.restitution = 0.4f;
	body->CreateFixture(&fixtureDef);
    body->ApplyLinearImpulse(pendingBallForce, body->GetWorldCenter());
    
    bodyContainer * container = [[bodyContainer alloc] init];
    container.body = body;
    
    [ballArray addObject:container];
}

- (void) addBallWithForce:(b2Vec2)force
{
    pendingBallForce = force;
    ballLaunchPending = YES;
}

- (void) updateBalls
{
    NSLog(@"count = %d", [ballArray count]); 
    
    if (ballLaunchPending)
    {
        [self processPendingBalls];
        ballLaunchPending = NO;
    }
}

- (void) dealloc
{
    [ballArray release];
    
    [super dealloc];
}

@end
