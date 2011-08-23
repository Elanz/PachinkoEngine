//
//  MainGameLayer.mm
//  pachitest2
//
//  Created by elanz on 8/22/11.
//  Copyright 200Monkeys 2011. All rights reserved.
//


// Import the interfaces
#import "MainGameLayer.h"
#import "GB2ShapeCache.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation MainGameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainGameLayer *layer = [MainGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
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
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
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
        [self addChild:sprite];
        
        backBodyDef.userData = sprite;
        
        b2Body* backBody = world->CreateBody(&backBodyDef);
		[[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"back.plist"];
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:backBody forShapeName:@"back"];
        
        [sprite setAnchorPoint:[
                                [GB2ShapeCache sharedShapeCache]
                                anchorPointForShape:@"back"]];
        
		//Set up sprite
		
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"ball.png" capacity:150];
		[self addChild:batch z:0 tag:kTagBatchNode];
    				
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw
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

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(0,0,10,10)];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;

	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2CircleShape dynamicCircle;
	dynamicCircle.m_radius = .2;
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicCircle;	
	fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.1f;
    fixtureDef.restitution = 0.4f;
	body->CreateFixture(&fixtureDef);
    b2Vec2 force;
    force.Set(20.0f, 0.0f);
    body->ApplyLinearImpulse(force, body->GetWorldCenter());
}



-(void) tick: (ccTime) dt
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

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [self addNewSpriteWithCoords: ccp(320,60)];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;

   	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
