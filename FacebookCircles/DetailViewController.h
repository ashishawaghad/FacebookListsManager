//
//  DetailViewController.h
//  FacebookCircles
//
//  Created by Ashish Awaghad on 15/4/13.
//  Copyright (c) 2013 Ashish Awaghad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookList.h"
#import "GAI.h"

@interface DetailViewController : GAITrackedViewController

@property (strong, nonatomic) FacebookList *detailItem;

@end
