//
//  WorldController.mm
//  pachitest2
//
//  Created by elanz on 8/29/11.
//  Copyright (c) 2011 200Monkeys. All rights reserved.
//

#import "WorldController.h"
#import "cocos2d.h"
#import "GB2ShapeCache.h"

@implementation WorldController

@synthesize World = world;
@synthesize Background = backBody;

- (void) createWorldWithLayer:(CCLayer*)mainGameLayer
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, -10.0f);
    
    // Do we want to let bodies sleep?
    // This will speed up the physics simulation
    bool doSleep = true;
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    world = new b2World(gravity, doSleep);
    
    world->SetContinuousPhysics(true);
    
    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    //		flags += b2DebugDraw::e_jointBit;
    //      flags += b2DebugDraw::e_aabbBit;
    //		flags += b2DebugDraw::e_pairBit;
    //		flags += b2DebugDraw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);	
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;		
    
    // bottom
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // top
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    
    b2BodyDef backBodyDef;	
    backBodyDef.position.Set(0, 0); // bottom-left corner
    
    CCSprite *sprite = [CCSprite spriteWithFile:@"back.png"];
    [mainGameLayer addChild:sprite];
    
    backBodyDef.userData = sprite;
    
    backBody = world->CreateBody(&backBodyDef);
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"back.plist"];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:backBody forShapeName:@"back"];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:backBody forShapeName:@"sensors"];
    
    [sprite setAnchorPoint:[
                            [GB2ShapeCache sharedShapeCache]
                            anchorPointForShape:@"back"]];
}

- (void) updateWorld:(float)dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}
	}
}

- (void) drawDebug
{
    // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glClearColor(255, 255, 255, 1.0);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void) dealloc
{
	delete world;
	world = NULL;
    
   	delete m_debugDraw;
    
	[super dealloc];
}

@end
