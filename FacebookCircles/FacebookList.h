//
//  FacebookList.h
//  FacebookCircles
//
//  Created by Ashish Awaghad on 15/4/13.
//  Copyright (c) 2013 Ashish Awaghad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookList : NSObject
@property (nonatomic, strong, readonly) NSString *listId, *name;
@property (nonatomic, strong, readonly) NSMutableArray *members;
- (void) addMember:(id<FBGraphUser>)member;
- (id) initWithId:(NSString *)listId andName:(NSString *)name;
@end
