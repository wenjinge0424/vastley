//
//  MyContactsViewController.m
//  vastley
//
//  Created by Techsviewer on 8/23/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "MyContactsViewController.h"
#import "ContactTableViewCell.h"
#import "OtherProfileViewController.h"
#import "UserHomeViewController.h"

@interface MyContactsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UIButton *btn_followers;
    __weak IBOutlet UIButton *btn_friends;
    __weak IBOutlet UIButton *btn_requests;
    
    __weak IBOutlet UITextField *edt_search;
    
    __weak IBOutlet UITableView *tbl_data;
    PFUser * me;
    
    NSMutableArray * m_showData;
    NSMutableArray * m_keyArray;
    NSMutableDictionary * dictData;
    
    NSString * searchString;
}
@end

@implementation MyContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    searchString = @"";
    edt_search.delegate = self;
    [self onFollowers:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL) stringContainsInArray:(NSString*)string :(NSArray*)array
{
    for(NSString * subString in array){
        if([subString isEqualToString:string]){
            return YES;
        }
    }
    return NO;
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == edt_search){
        edt_search.text = [Util trim:edt_search.text];
        searchString = edt_search.text;
        [self fetchData];
    }
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == edt_search){
        edt_search.text = [Util trim:edt_search.text];
        searchString = edt_search.text;
        [self fetchData];
    }
    return YES;
}

- (void) fetchData
{
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    if(btn_followers.isSelected){
        
        PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query1 whereKey:PARSE_FOLLOW_FROM equalTo:me];
        [query1 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
        PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query2 whereKey:PARSE_FOLLOW_TO equalTo:me];
        [query2 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
        PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
        [query includeKey:PARSE_FOLLOW_FROM];
        [query includeKey:PARSE_FOLLOW_TO];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            } else {
                NSMutableArray *  allUsers = (NSMutableArray *) array;
                NSMutableArray * tmpArray = [NSMutableArray new];
                for(PFObject * followObj in allUsers){
                    if(searchString.length > 0){
                        PFUser * user = followObj[PARSE_FOLLOW_TO];
                        if([user.objectId isEqualToString:me.objectId]){
                            user = followObj[PARSE_FOLLOW_FROM];
                        }
                        NSString * userName = user[PARSE_USER_FULLNAME];
                        if([userName.uppercaseString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound){
                            [tmpArray addObject:followObj];
                        }
                    }else{
                        [tmpArray addObject:followObj];
                    }
                }
                allUsers = [[NSMutableArray alloc] initWithArray:tmpArray];
                dictData = [NSMutableDictionary new];
                m_keyArray = [NSMutableArray new];
                [dictData setObject:allUsers forKey:@"1"];
                [m_keyArray addObject:@"1"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    tbl_data.delegate = self;
                    tbl_data.dataSource = self;
                    [tbl_data reloadData];
                });
            }
        }];
    }else if(btn_friends.isSelected){
        PFQuery * query = [PFUser query];
        [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:100]];
        [query whereKey:PARSE_FIELD_OBJECT_ID notEqualTo:me.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            } else {
                NSMutableArray *  allUsers = (NSMutableArray *) array;
                NSMutableArray * tmpArray = [NSMutableArray new];
                for(PFUser * user in allUsers){
                    if(searchString.length > 0){
                        NSString * userName = user[PARSE_USER_FULLNAME];
                        if([userName.uppercaseString rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound){
                            [tmpArray addObject:user];
                        }
                    }else{
                        [tmpArray addObject:user];
                    }
                }
                allUsers = [[NSMutableArray alloc] initWithArray:tmpArray];
                
                dictData = [NSMutableDictionary new];
                m_keyArray = [NSMutableArray new];
                for(PFUser * user in allUsers){
                    NSString * userName = user[PARSE_USER_FULLNAME];
                    NSString * firstCharactor = [userName substringToIndex:1].uppercaseString;
                    if([self stringContainsInArray:firstCharactor :m_keyArray]){
                        NSMutableArray * subArray = [dictData objectForKey:firstCharactor];
                        [subArray addObject:user];
                    }else{
                        NSMutableArray * subArray = [NSMutableArray new];
                        [subArray addObject:user];
                        [dictData setObject:subArray forKey:firstCharactor];
                        [m_keyArray addObject:firstCharactor];
                    }
                }
                m_keyArray = [[NSMutableArray alloc] initWithArray:[m_keyArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    tbl_data.delegate = self;
                    tbl_data.dataSource = self;
                    [tbl_data reloadData];
                });
                    
            }
        }];
        
    }else if(btn_requests.isSelected){
        m_keyArray = [NSMutableArray new];
        dictData = [NSMutableDictionary new];
        
        PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
        [query whereKey:PARSE_FRIENDS_TO equalTo:me];
        [query whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
        [query includeKey:PARSE_FRIENDS_FROM];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if (error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            } else {
                NSMutableArray * dataArray = (NSMutableArray*)array;
                if(dataArray.count > 0){
                    [m_keyArray addObject:@"FRIEND REQUESTS"];
                    [dictData setObject:dataArray forKey:@"FRIEND REQUESTS"];
                }
                PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
                [query whereKey:PARSE_FOLLOW_TO equalTo:me];
                [query whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
                [query includeKey:PARSE_FOLLOW_FROM];
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                    [SVProgressHUD dismiss];
                    if (error){
                        [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                    } else {
                        NSMutableArray * dataArray = (NSMutableArray*)array;
                        if(dataArray.count > 0){
                            [m_keyArray addObject:@"FOLLOW REQUESTS"];
                            [dictData setObject:dataArray forKey:@"FOLLOW REQUESTS"];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            tbl_data.delegate = self;
                            tbl_data.dataSource = self;
                            [tbl_data reloadData];
                        });
                    }
                }];
                
            }
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onFollowers:(id)sender {
    [btn_followers setSelected:YES];
    [btn_friends setSelected:NO];
    [btn_requests setSelected:NO];
    edt_search.text = @"";
    edt_search.placeholder = @"search for followers...";
    [self fetchData];
}
- (IBAction)onFriends:(id)sender {
    [btn_followers setSelected:NO];
    [btn_friends setSelected:YES];
    [btn_requests setSelected:NO];
    edt_search.text = @"";
    edt_search.placeholder = @"search for friends...";
    [self fetchData];
}
- (IBAction)onRequests:(id)sender {
    [btn_followers setSelected:NO];
    [btn_friends setSelected:NO];
    [btn_requests setSelected:YES];
    edt_search.text = @"";
    edt_search.placeholder = @"search for requests...";
    [self fetchData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(btn_friends.isSelected){
        return m_keyArray.count;
    }else if(btn_requests.isSelected){
        return m_keyArray.count;
    }
    return 1;
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(btn_friends.isSelected){
        return [m_keyArray objectAtIndex:section];
    }else if(btn_requests.isSelected){
        return [m_keyArray objectAtIndex:section];
    }
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(btn_friends.isSelected){
        return 60;
    }else if(btn_requests.isSelected){
        return 80;
    }
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(btn_friends.isSelected){
        NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:section]];
        return dataArray.count;
    }else if(btn_requests.isSelected){
        NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:section]];
        return dataArray.count;
    }
    NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:section]];
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(btn_friends.isSelected){
        static NSString *cellIdentifier = @"ContactTableViewCell";
        ContactTableViewCell *cell = (ContactTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:indexPath.section]];
            PFUser * user = [dataArray objectAtIndex:indexPath.row];
            
            [Util setImage:cell.img_thumb imgFile:user[PARSE_USER_AVATAR]];
            cell.lbl_title.text = user[PARSE_USER_FULLNAME];
        }
        return cell;
    }else if(btn_requests.isSelected){
        static NSString *cellIdentifier = @"ContactAcceptTableViewCell";
        ContactAcceptTableViewCell *cell = (ContactAcceptTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:indexPath.section]];
            PFObject * object = [dataArray objectAtIndex:indexPath.row];
            NSString * keyStr = [m_keyArray objectAtIndex:indexPath.section];
            PFUser * sender = nil;
            if([keyStr isEqualToString:@"FRIEND REQUESTS"]){
                sender = object[PARSE_FRIENDS_FROM];
            }else{
                sender = object[PARSE_FOLLOW_FROM];
            }
            [Util setImage:cell.img_thumb imgFile:sender[PARSE_USER_AVATAR]];
            cell.lbl_title.text = sender[PARSE_USER_FULLNAME];
            
            cell.btn_accept.tag = indexPath.section;
            cell.btn_accept.secondTag = (int)indexPath.row;
            [cell.btn_accept addTarget:self action:@selector(onAcceptRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_decline.tag = indexPath.section;
            cell.btn_decline.secondTag = (int)indexPath.row;
            [cell.btn_decline addTarget:self action:@selector(onDeclineRequest:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        return cell;
        
    }else{
        static NSString *cellIdentifier = @"ContactTableViewCell";
        ContactTableViewCell *cell = (ContactTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:indexPath.section]];
            PFObject * followObj = [dataArray objectAtIndex:indexPath.row];
            PFUser * user = followObj[PARSE_FOLLOW_TO];
            if([user.objectId isEqualToString:me.objectId]){
                user = followObj[PARSE_FOLLOW_FROM];
            }
            
            [Util setImage:cell.img_thumb imgFile:user[PARSE_USER_AVATAR]];
            cell.lbl_title.text = user[PARSE_USER_FULLNAME];
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(btn_friends.isSelected){
        NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:indexPath.section]];
        PFUser * user = [dataArray objectAtIndex:indexPath.row];
        UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
        OtherProfileViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherProfileViewController"];
        controller.userInfo = user;
        [mainNav pushViewController:controller animated:YES];
    }
}
- (void) onAcceptRequest:(TwoTagButton*) button
{
    int section = (int)button.tag;
    int row = button.secondTag;
    
    NSString * keyStr = [m_keyArray objectAtIndex:section];
    NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:section]];
    PFObject * saveObject = [dataArray objectAtIndex:row];
    PFQuery * deleteQuery = nil;
    PFObject * notificaionQuery = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
    notificaionQuery[PARSE_NOTIFICATION_SENDER] = me;
    
    NSString *fullName = @"";
    fullName = me[PARSE_USER_FULLNAME];
    NSString *pushMsg = @"";
    
    PFUser * sender = nil;
    if([keyStr isEqualToString:@"FRIEND REQUESTS"]){
        sender = saveObject[PARSE_FRIENDS_FROM];
        saveObject[PARSE_FRIENDS_ACTIVE] = [NSNumber numberWithBool:YES];
        PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
        [query1 whereKey:PARSE_FRIENDS_FROM equalTo:me];
        [query1 whereKey:PARSE_FRIENDS_TO equalTo:sender];
        [query1 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
        PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
        [query2 whereKey:PARSE_FRIENDS_FROM equalTo:sender];
        [query2 whereKey:PARSE_FRIENDS_TO equalTo:me];
        [query2 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
        deleteQuery = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
        notificaionQuery[PARSE_NOTIFICATION_RECEIVER] = sender;
        notificaionQuery[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_ALLOW_FRIEND];
        pushMsg = [NSString stringWithFormat:@"%@ accept your friend request.", fullName];
        
    }else{// follow request
        sender = saveObject[PARSE_FOLLOW_FROM];
        saveObject[PARSE_FOLLOW_ACTIVE] = [NSNumber numberWithBool:YES];
        PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query1 whereKey:PARSE_FOLLOW_FROM equalTo:me];
        [query1 whereKey:PARSE_FOLLOW_TO equalTo:sender];
        [query1 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
        PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
        [query2 whereKey:PARSE_FOLLOW_FROM equalTo:sender];
        [query2 whereKey:PARSE_FOLLOW_TO equalTo:me];
        [query2 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
        deleteQuery = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
        notificaionQuery[PARSE_NOTIFICATION_RECEIVER] = sender;
        notificaionQuery[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_ALLOW_FOLLOW];
        pushMsg = [NSString stringWithFormat:@"%@ accept your follow request.", fullName];
    }
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [saveObject saveInBackgroundWithBlock:^(BOOL success, NSError* error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            [deleteQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                } else {
                    for(PFObject * object in array){
                        [object deleteInBackground];
                    }
                    [notificaionQuery saveInBackgroundWithBlock:^(BOOL success, NSError* error){
                        [SVProgressHUD dismiss];
                        NSDictionary *data = @{
                                               @"alert" : pushMsg,
                                               @"badge" : @"Increment",
                                               @"sound" : @"cheering.caf",
                                               @"email" : sender.username,
                                               @"data"  : sender.objectId,
                                               @"type"  : [NSNumber numberWithInt:PUSH_TYPE_OTHER]
                                               };
                        [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                            if (err) {
                                NSLog(@"Fail APNS: %@", @"send ban push");
                            } else {
                                NSLog(@"Success APNS: %@", @"send ban push");
                            }
                        }];
                        [self fetchData];
                    }];
                }
            }];
        }
    }];
}
- (void) onDeclineRequest:(TwoTagButton*) button
{
    int section = (int)button.tag;
    int row = button.secondTag;
    
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    NSMutableArray * dataArray = [dictData objectForKey:[m_keyArray objectAtIndex:section]];
    PFObject * object = [dataArray objectAtIndex:row];
    [object deleteInBackgroundWithBlock:^(BOOL success, NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            [self fetchData];
        }];
    }];
}
@end
