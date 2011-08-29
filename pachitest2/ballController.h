//
//  BallController.h
//  pachitest2
//
//  Created by elanz on 8/29/11.
//  Copyright (c) 2011 200Monkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

@class WorldController;
@class CCLayer;

@interface BallController : NSObject
{
    CCLayer * mainGameLayer;
    WorldController * theWorld;
    
    NSMutableArray * ballArray;
    
    BOOL ballLaunchPending;
    b2Vec2 pendingBallForce;
}

- (id) initWithLayer:(CCLayer*)MainGameLayer andWorld:(WorldController*)TheWorld;
- (void) addBallWithForce:(b2Vec2)force;
- (void) updateBalls;

@end
