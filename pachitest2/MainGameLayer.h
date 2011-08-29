//
//  MainGameLayer.h
//  pachitest2
//
//  Created by elanz on 8/22/11.
//  Copyright 200Monkeys 2011. All rights reserved.
//

#import "cocos2d.h"

@class WorldController;
@class BallController;
@class HandleController;

@interface MainGameLayer : CCLayerColor
{  
    WorldController * theWorld;
    BallController * theBallController;
    HandleController * theHandle;
}

+(CCScene *) scene;

- (void) launchBall;


@end
