//
//  HandleController.m
//  pachitest2
//
//  Created by elanz on 8/29/11.
//  Copyright (c) 2011 200Monkeys. All rights reserved.
//

#import "HandleController.h"

@implementation HandleController

@synthesize LaunchForce = launchForce;

- (id) initWithLayer:(CCLayer*)MainGameLayer andWorld:(WorldController*)TheWorld
{
    if( (self=[super init])) {
        mainGameLayer = MainGameLayer;
        theWorld = TheWorld;
        
        launchForce = 0.0;
        
        handle = [CCSprite spriteWithFile:@"handle.png"];
        [handle setScale:1.66];
        [handle setPosition:ccp(250, -5)];
        [mainGameLayer addChild:handle];

        [handle setRotation:-60];
    }
    
    return self;
}

- (void) handleTouch:(CGPoint)touch
{
    float relativeX = touch.x - [handle boundingBox].origin.x;
    float percentX = relativeX / [handle boundingBox].size.width;
    float angle = -60 + (120.0 * percentX);
    launchForce = 20.0 * percentX;
    
    [handle runAction:[CCRotateTo actionWithDuration:0.2 angle:angle]];
}

- (BOOL) hitTestWithPoint:(CGPoint)point
{ 
    if (CGRectContainsPoint([handle boundingBox], point))
        return YES;
    
    return NO;
}

- (void) dealloc
{
    [mainGameLayer removeChild:handle cleanup:YES];
    
    [super dealloc];
}

@end
