//
//  MasterViewController.m
//  CityworksExample-iOS
//
//  Created by Dee Clawson on 1/24/15.
//  Copyright (c) 2015 Dee Clawson. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AFNetworking.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@property NSMutableArray *objects2;

@end

NSString* baseURL = @"http://www.example.com/cityworks";

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    

    
}

- (void) loginCityworks{

    //For this example I am using AFNetworking, RestKit works well to, and there are many others...
    //baseURL is declared at the top of this implementation file. I did not make a login controller for LoginName and Password it is declared below
    
    NSString* url = [NSString stringWithFormat:@"%@%@", baseURL, @"/services/authentication/authenticate?data={'LoginName':'PUTLOGINNAMEHERE','Password':'PUTPASSWORDHERE'}"];
    NSString* escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:escapedUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Authentication: %@", responseObject);
        
        if ([[responseObject objectForKey:@"Status"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSString *token = [responseObject valueForKeyPath:@"Value.Token"];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"userToken"];
            [self getUserInfo];
        }
        else
        {
             NSLog(@"%@",[responseObject objectForKey:@"Message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
} //end loginCityworks


- (void) getUserInfo{
    
    NSString* userToken  = [[NSUserDefaults standardUserDefaults] stringForKey:@"userToken"];
    NSString* url = [NSString stringWithFormat:@"%@%@&token=%@", baseURL, @"/services/authentication/user?data={}",userToken];
    NSString* escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:escapedUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //NSLog(@"User Info: %@", responseObject);
        
        if ([[responseObject objectForKey:@"Status"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSString *fullName = [responseObject valueForKeyPath:@"Value.FullName"];
            NSString *employeeSid = [responseObject valueForKeyPath:@"Value.EmployeeSid"];
            [[NSUserDefaults standardUserDefaults] setObject:fullName forKey:@"fullName"];
            [[NSUserDefaults standardUserDefaults] setObject:employeeSid forKey:@"employeeSid"];
            [self getWorkOrderIndex];
        }
        else
        {
            NSLog(@"%@",[responseObject objectForKey:@"Message"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
} //end getUserInfo


- (void) getWorkOrderIndex{
    
    NSString* employeeSid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeSid"];
    NSString* userToken  = [[NSUserDefaults standardUserDefaults] stringForKey:@"userToken"];
    //Authenticated Employee's Work Orders that are not Canceled or Closed
    NSString* url = [NSString stringWithFormat:@"%@%@%@]}&token=%@", baseURL, @"/services/WorkOrder/Search?data={'ActualFinishDateIsNull':true,'Closed':false,'Canceled':false,'SubmitTo':[",employeeSid,userToken];
    //All Work Orders
    //NSString* url = [NSString stringWithFormat:@"%@%@%@&token=%@", baseURL, @"/services/WorkOrder/Search?data={}",employeeSid,userToken];
    NSString* escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:escapedUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Work Orders Index: %@", responseObject);
        
        if ([[responseObject objectForKey:@"Status"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSArray *fullName = [responseObject objectForKey:@"Value"];
            
            for (NSString* woId in fullName)
            {
                [self getWorkOrderShow:woId];
            }
        }
        else
        {
            NSLog(@"%@",[responseObject objectForKey:@"Message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
} //end getWorkOrderIndex

- (void) getWorkOrderShow:(NSString*) woId{
    
    NSString* employeeSid = [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeSid"];
    NSString* userToken  = [[NSUserDefaults standardUserDefaults] stringForKey:@"userToken"];
    //You can also call ByIds here instead of ById, probably a better solution then this :)!
    NSString* url = [NSString stringWithFormat:@"%@%@%@'}&token=%@", baseURL, @"/services/WorkOrder/ById?data={'WorkOrderId':'",woId,userToken];
    NSString* escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:escapedUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Work Order Show: %@", responseObject);
        
        if ([[responseObject objectForKey:@"Status"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            
            //As you can see I've been lazy in this demo. I have not created any models for the return JSON.
            //Check out JSONModel, or Mantle they both work well. What you see below would be a nightmare...
            
            NSString *woID = woId;
            NSString *woDescription = [responseObject valueForKeyPath:@"Value.Description"];
            NSString *woPriority= [responseObject valueForKeyPath:@"Value.Priority"];
            NSString *woStatus= [responseObject valueForKeyPath:@"Value.Status"];
            NSDecimalNumber *woX = [responseObject valueForKeyPath:@"Value.WOXCoordinate"];
            NSDecimalNumber *woY = [responseObject valueForKeyPath:@"Value.WOYCoordinate"];
            
            NSString *cellView = [NSString stringWithFormat:@"WO: %@   %@",woID, woDescription];
            NSString *subtitle = [NSString stringWithFormat:@"Priority: %@   Status: %@",woPriority, woStatus];
            
            if (!self.objects) { //This is BS, only used to demostrate two rows in standard TableView
                self.objects = [[NSMutableArray alloc] init];
                self.objects2 = [[NSMutableArray alloc] init];
            }
            
            [self.objects insertObject:cellView atIndex:0];
            [self.objects2 insertObject:subtitle atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
            [self.detailViewController addPins:woX ycoord:woY desc:cellView];
            
        }
        else
        {
            NSLog(@"%@",[responseObject objectForKey:@"Message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
} //end getWorkOrderShow


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {

    //After the view loads call Cityworks
    //I have forgone all frameworks to display calling Cityworks APIs quickly
    [self loginCityworks];
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    NSDate *object2 = self.objects2[indexPath.row];
    cell.textLabel.text = [object description];
    cell.detailTextLabel.text = [object2 description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
