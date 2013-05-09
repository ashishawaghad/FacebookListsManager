//
//  MasterViewController.m
//  FacebookCircles
//
//  Created by Ashish Awaghad on 15/4/13.
//  Copyright (c) 2013 Ashish Awaghad. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "FacebookList.h"
#import "MBProgressHUD.h"

@interface MasterViewController () <FBLoginViewDelegate>{
    NSMutableArray *_objects;
    UIAlertView *addAlertView, *deleteAlertView;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *loginView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) UITextField *myTextField;
- (IBAction)buttonClickHandler:(id)sender;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    
    self.title = @"Your Lists";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;

    [self updateView];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] initWithPermissions:@[@"read_friendlists", @"manage_friendlists", @"friends_about_me"]];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self updateView];
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
//        [self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
//        [self.textNoteOrLink setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
//                                      appDelegate.session.accessTokenData.accessToken]];
        
        self.loginView.hidden = YES;
        self.tableView.hidden = false;
        self.navigationController.navigationBarHidden = false;
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[[FBRequest alloc] initWithSession:appDelegate.session graphPath:@"me"] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (!error) {
                [AppDelegate getAppDelegate].loggedInUser = user;
                [self getFBLists];
            }
        }];
    } else {
        // login-needed account UI is shown whenever the session is closed
//        [self.buttonLoginLogout setTitle:@"Log in" forState:UIControlStateNormal];
//        [self.textNoteOrLink setText:@"Login to create a link to fetch account data"];
        self.tableView.hidden = YES;
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void) getFBLists {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[FBRequest alloc] initWithSession:[AppDelegate getAppDelegate].session graphPath:@"me/friendlists"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        BOOL found = false;
        if (!error) {
            NSArray *dataArr = [result objectForKey:@"data"];
            
            _objects = [[NSMutableArray alloc] init];
            if (dataArr && [dataArr count] > 0) {
                for (NSDictionary *dict in dataArr) {
                    if ([dict objectForKey:@"id"] && [dict objectForKey:@"name"]) {
                        found = YES;
                        FacebookList *list = [[FacebookList alloc] initWithId:[dict objectForKey:@"id"] andName:[dict objectForKey:@"name"]];
                        [_objects addObject:list];
                    }
                }
            }
            [self.tableView reloadData];
        }
    }];
}

// FBSample logic
// handler for button click, logs sessions in or out
- (IBAction)buttonClickHandler:(id)sender {
    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        //[appDelegate.session closeAndClearTokenInformation];
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            
            
            [self updateView];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    addAlertView = [[UIAlertView alloc] initWithTitle:@""
                                                          message:@"Enter name of the list to be created:\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 48.0, 260.0, 25.0)];
    [self.myTextField setBackgroundColor:[UIColor whiteColor]];
    [addAlertView addSubview:self.myTextField];
    [addAlertView show];
    [self.myTextField becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == addAlertView) {
        if (buttonIndex == 1 && self.myTextField.text.length) {
            [[[FBRequest alloc] initWithSession:[AppDelegate getAppDelegate].session graphPath:@"me/friendlists" parameters:[NSDictionary dictionaryWithObject:self.myTextField.text forKey:@"name"] HTTPMethod:@"POST"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [self getFBLists];
            }];
        }
    }
    else if(alertView == deleteAlertView) {
        if (buttonIndex == 1) {
            FacebookList *list = [_objects objectAtIndex:alertView.tag];
            [_objects removeObjectAtIndex:alertView.tag];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:alertView.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [[[FBRequest alloc] initWithSession:[AppDelegate getAppDelegate].session graphPath:[NSString stringWithFormat:@"/%@", list.listId] parameters:nil HTTPMethod:@"DELETE"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [self getFBLists];
            }];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    FacebookList *object = _objects[indexPath.row];
    cell.textLabel.text = [object name];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                  message:@"Are you sure you want to delete this list? Deleting will remove all your friends from this list and you will have to manually add the list and the members again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [deleteAlertView show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FacebookList *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
