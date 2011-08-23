//
//  AppDelegate.h
//  pachitest2
//
//  Created by elanz on 8/22/11.
//  Copyright 200Monkeys 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
