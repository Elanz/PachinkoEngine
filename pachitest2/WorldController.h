//
//  WorldController.h
//  pachitest2
//
//  Created by elanz on 8/29/11.
//  Copyright (c) 2011 200Monkeys. All rights reserved.
//

#import "Box2D.h"
#import "GLES-Render.h"

#define PTM_RATIO 32

@class CCLayer;
@class CCTime;

@interface WorldController : NSObject
{
	GLESDebugDraw *m_debugDraw;
}

@property (nonatomic, readwrite) b2World* World;

- (void) createWorldWithLayer:(CCLayer*)mainGameLayer;
- (void) drawDebug;
- (void) updateWorld:(float)dt;

@end
