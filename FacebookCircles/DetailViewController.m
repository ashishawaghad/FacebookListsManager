//
//  DetailViewController.m
//  FacebookCircles
//
//  Created by Ashish Awaghad on 15/4/13.
//  Copyright (c) 2013 Ashish Awaghad. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface DetailViewController () <FBFriendPickerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addMembersButton;

@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;

- (void)configureView;
- (IBAction)addMembersButtonClicked:(id)sender;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(FacebookList *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        self.members = [[NSMutableArray alloc] init];
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Update the user interface for the detail item.
    [[[FBRequest alloc] initWithSession:[AppDelegate getAppDelegate].session graphPath:[NSString stringWithFormat:@"/%@/members", _detailItem.listId]] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.members = [[NSMutableArray alloc] init];
        
        if (!error) {
            NSArray *dataArr = [result objectForKey:@"data"];
            if (dataArr && [dataArr count] > 0) {
                for (NSDictionary *dict in dataArr) {
                    if ([dict objectForKey:@"id"] && [dict objectForKey:@"name"]) {
                        [self.members addObject:[dict objectForKey:@"name"]];
                    }
                }
            }
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)addMembersButtonClicked:(id)sender {
    [[AppDelegate getAppDelegate].tracker sendEventWithCategory:@"UIAction" withAction:@"addMembersButtonPressed" withLabel:[NSString stringWithFormat:@"on List: %@", _detailItem.name] withValue:[NSNumber numberWithInt:0]];
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.session = [AppDelegate getAppDelegate].session;
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    // iOS 5.0+ apps should use [UIViewController presentViewController:animated:completion:]
    // rather than this deprecated method, but we want our samples to run on iOS 4.x as well.
    [self presentViewController:self.friendPickerController animated:YES completion:^{
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.title = _detailItem.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    NSString *object = self.members[indexPath.row];
    cell.textLabel.text = object;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@","];
        }
        [text appendString:user.id];
    }
    if ([text length]) {
        
        [[AppDelegate getAppDelegate].tracker sendEventWithCategory:@"FBAction" withAction:@"membersAdded" withLabel:[NSString stringWithFormat:@"to List: %@", _detailItem.name] withValue:[NSNumber numberWithInt:self.friendPickerController.selection.count]];
        [[[FBRequest alloc] initWithSession:[AppDelegate getAppDelegate].session graphPath:[NSString stringWithFormat:@"/%@/members", _detailItem.listId] parameters:[NSDictionary dictionaryWithObject:text forKey:@"members"] HTTPMethod:@"POST"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self configureView];
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
