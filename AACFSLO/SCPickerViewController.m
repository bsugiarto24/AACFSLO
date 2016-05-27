// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.


#import "SCPickerViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation SCPickerViewController
{
    __weak IBOutlet UISearchBar *searchBar;
    NSArray *_results;
    NSMutableArray *_filtered;
    __weak IBOutlet UITableView *tblSearchResults;
    BOOL shouldShowSearchResults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //a bunch of config stuff
    shouldShowSearchResults = false;
    self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    tblSearchResults.delegate = self;
    tblSearchResults.dataSource = self;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.placeholder = @"search here";

    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    tblSearchResults.tableHeaderView = _searchController.searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.requiredPermission && ![[FBSDKAccessToken currentAccessToken] hasGranted:self.requiredPermission])
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[self.requiredPermission]
                     fromViewController:self
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    if ([result.grantedPermissions containsObject:self.requiredPermission]) {
                                        [self fetchData];
                                    } else {
                                        [self dismissViewControllerAnimated:YES completion:NULL];
                                    }
                                }];
    } else {
        [self fetchData];
    }
    NSLog(@"view appear");

}


//gets user's friends
- (void)fetchData
{
    NSLog(@"fetch data");
    [self.request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Picker loading error:%@", error);
            if (!error.userInfo[FBSDKErrorLocalizedDescriptionKey]) {
                [[[UIAlertView alloc] initWithTitle:@"Oops"
                                            message:@"There was a problem fetching the list"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            _results = result[@"data"];
            [self.tableView reloadData];
        }
    }];
}


//selected friends function
- (NSArray *)selection {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *data = [NSMutableArray array];
    
    if(shouldShowSearchResults) {
        data = _filtered;
    }else {
        data = [_results copy];
    }
    
    for (NSIndexPath *index in self.tableView.indexPathsForSelectedRows) {
        [result addObject: @{
                             @"id" : data[index.row][@"id"],
                             @"name" : data[index.row][@"name"]
                             }];
    }
    
    return result;
}

#pragma mark - UITableViewDataSource

//number of cells to display
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(shouldShowSearchResults){
        return _filtered.count;
    }
    return _results.count;
}


//data display in table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSArray *data = [NSArray array];
    
    if(shouldShowSearchResults) {
        data = _filtered;
    }else {
        data = _results;
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = data[indexPath.row][@"name"];
    NSString *pictureURL = data[indexPath.row][@"picture"][@"data"][@"url"];
    if (pictureURL) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:pictureURL]];
            
            //this will set the image when loading is finished
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:image];
                [cell setNeedsLayout];
            });
        });
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}



//begin editing bar
-(void) searchBarTextDidBeginEditing: (UISearchBar*)searchBar
{
    NSLog(@"search bar editing");
    shouldShowSearchResults = true;
    [tblSearchResults reloadData];
}


//enter clicking search bar
-(void) searchBarSearchButtonClicked: (UISearchBar*)searchBar
{
    NSLog(@"searchBar click");

    if(!shouldShowSearchResults){
        shouldShowSearchResults = true;
        [tblSearchResults reloadData];
    }
    
    [_searchController.searchBar resignFirstResponder];
}


//update search results
- (void)updateSearchResultsForSearchController:(UISearchController *) searchController {
    NSLog(@"update search results");
    NSString *searchString = searchController.searchBar.text;
    NSLog(@"Searching : %@", searchString);
    
    
    _filtered = [NSMutableArray array];
    for(id object in _results) {
        if([object[@"name"] rangeOfString: searchString].location != NSNotFound) {
            [_filtered addObject:object];
        }
    }
    
    NSLog(@"%d", (unsigned int)_filtered.count);
    
    
    [tblSearchResults reloadData];
}


//changes search text
-(void) didChangeSearchText: (NSString*)searchText
{
    NSLog(@"changed Search text");

    _filtered = [NSMutableArray array];
    for(id object in _results) {
        if([object[@"name"] rangeOfString: searchText].location != NSNotFound) {
            [_filtered addObject:object];
        }
    }
    [tblSearchResults reloadData];
}



@end
