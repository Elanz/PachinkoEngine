//
//  MainGameLayer.mm
//  pachitest2
//
//  Created by elanz on 8/22/11.
//  Copyright 200Monkeys 2011. All rights reserved.
//


// Import the interfaces
#import "MainGameLayer.h"
#import "WorldController.h"
#import "BallController.h"
#import "HandleController.h"
#import "Box2D.h"

@implementation MainGameLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MainGameLayer *layer = [MainGameLayer node];
	[scene addChild: layer];
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255,255,255,255)])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
        //create the world controller
        theWorld = [[WorldController alloc] init];
        [theWorld createWorldWithLayer:self];
        
        //create the handle controller
        theHandle = [[HandleController alloc] initWithLayer:self andWorld:theWorld];
        
        //create the ball controller
        theBallController = [[BallController alloc] initWithLayer:self andWorld:theWorld];
        
		[self schedule: @selector(tick:)];
        [self schedule:@selector(launchBall) interval:1.0];
        
	}
	return self;
}

-(void) draw
{
    [theWorld drawDebug];
}

- (void) launchBall
{
    if (theHandle.LaunchForce < 0.1) return;
    
    b2Vec2 force;
    force.Set(theHandle.LaunchForce, 0.0f);
    [theBallController addBallWithForce:force];
}

-(void) tick: (ccTime) dt
{
    [theWorld updateWorld:dt];
    [theBallController updateBalls];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * anyTouch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace: anyTouch];
    if ([theHandle hitTestWithPoint:location])
        [theHandle handleTouch:location];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * anyTouch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace: anyTouch];
    if ([theHandle hitTestWithPoint:location])
        [theHandle handleTouch:location];
}

- (void) dealloc
{
    [theWorld release];
    
    [super dealloc];
}

@end
