//
//  HandleController.h
//  pachitest2
//
//  Created by elanz on 8/29/11.
//  Copyright (c) 2011 200Monkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"

@class WorldController;

@interface HandleController : NSObject
{
    CCLayer * mainGameLayer;
    WorldController * theWorld;
    
    CCSprite * handle;
}

@property (nonatomic, readwrite) float LaunchForce;

- (id) initWithLayer:(CCLayer*)MainGameLayer andWorld:(WorldController*)TheWorld;
- (void) handleTouch:(CGPoint)touch;
- (BOOL) hitTestWithPoint:(CGPoint)point;

@end
