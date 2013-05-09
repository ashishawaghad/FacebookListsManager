//
//  FacebookList.m
//  FacebookCircles
//
//  Created by Ashish Awaghad on 15/4/13.
//  Copyright (c) 2013 Ashish Awaghad. All rights reserved.
//

#import "FacebookList.h"

@implementation FacebookList

@synthesize listId = _listId, name = _name, members = _members;

- (id) initWithId:(NSString *)listId andName:(NSString *)name {
    if ((self = [super init])) {
        _listId = listId;
        _name = name;
        
        _members = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) addMember:(id<FBGraphUser>)member {
    [_members addObject:member];
}
@end
