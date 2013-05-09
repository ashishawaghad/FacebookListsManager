//
//  AppDelegate.h
//  FacebookCircles
//
//  Created by Ashish Awaghad on 15/4/13.
//  Copyright (c) 2013 Ashish Awaghad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "GAI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@property(nonatomic, strong) id<GAITracker> tracker;

+ (AppDelegate *)getAppDelegate;

@end
