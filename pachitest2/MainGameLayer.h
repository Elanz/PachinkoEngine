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

@interface MainGameLayer : CCLayerColor
{  
    WorldController * theWorld;
    BallController * theBallController;
}

+(CCScene *) scene;


@end
