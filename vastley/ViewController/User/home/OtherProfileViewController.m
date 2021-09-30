//
//  OtherProfileViewController.m
//  vastley
//
//  Created by Techsviewer on 8/21/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "OtherProfileViewController.h"
#import "ItemInfoTableViewCell.h"
#import "ItemDetailViewController.h"
#import "UserHomeViewController.h"

@interface OtherProfileViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet CircleImageView *img_thumb;
    __weak IBOutlet UILabel *lbl_username;
    __weak IBOutlet UILabel *lbl_description;
    __weak IBOutlet UILabel *lbl_friendCount;
    __weak IBOutlet UILabel *lbl_followCount;
    
    __weak IBOutlet UIButton *btn_addFriend;
    __weak IBOutlet UIButton *btn_follow;
    __weak IBOutlet UITableView *tbl_data;
    
    PFUser * me;
    NSMutableArray * m_sharedDatas;
}

@end

@implementation OtherProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lbl_username.text = @"";
    lbl_description.text = @"";
    
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    int userType = [me[PARSE_USER_TYPE] intValue];
    if(userType == 100){
        lbl_friendCount.hidden = YES;
        lbl_followCount.hidden = YES;
        btn_addFriend.hidden = NO;
        btn_follow.hidden = NO;
    }else{
        lbl_friendCount.hidden = NO;
        lbl_followCount.hidden = NO;
        lbl_friendCount.text = @"0 friends";
        lbl_followCount.text = @"0 followers";
        btn_addFriend.hidden = YES;
        btn_follow.hidden = YES;
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [self.userInfo fetchInBackgroundWithBlock:^(PFObject * obj, NSError * error){
        if(error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            return;
        }else{
            self.userInfo = (PFUser *) obj;
            lbl_username.text = self.userInfo[PARSE_USER_FULLNAME];
            lbl_description.text = self.userInfo[PARSE_USER_LOCATION];
            [Util setImage:img_thumb imgFile:self.userInfo[PARSE_USER_AVATAR]];
      
            int userType = [me[PARSE_USER_TYPE] intValue];
            if(userType == 200){
                PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
                [query1 whereKey:PARSE_FOLLOW_FROM equalTo:self.userInfo];
                [query1 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
                PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
                [query2 whereKey:PARSE_FOLLOW_TO equalTo:self.userInfo];
                [query2 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
                PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                    if (error){
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                    }else{
                        lbl_followCount.text  = [NSString stringWithFormat:@"%d followers", (int)array.count];
                        
                        PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
                        [query1 whereKey:PARSE_FRIENDS_FROM equalTo:self.userInfo];
                        [query1 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
                        PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
                        [query2 whereKey:PARSE_FRIENDS_TO equalTo:self.userInfo];
                        [query2 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
                        PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
                        
                        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                            if (error){
                                [SVProgressHUD dismiss];
                                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                            }else{
                                lbl_friendCount.text  = [NSString stringWithFormat:@"%d friends", (int)array.count];
                                [self reloadSharedItems];
                            }
                            
                        }];
                    }
                }];
            }else{
                [self reloadSharedItems];
            }
        }
    }];
    
    
}
- (void) reloadSharedItems
{
    m_sharedDatas = [NSMutableArray new];
    PFQuery * shareItemQuery = [PFQuery queryWithClassName:PARSE_TABLE_SHARE];
    [shareItemQuery whereKey:PARSE_SHARE_SENDER equalTo:self.userInfo];
    [shareItemQuery includeKey:PARSE_SHARE_PRODUCT];
    [shareItemQuery includeKey:PARSE_SHARE_RECEIVER];
    [shareItemQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        }else{
            m_sharedDatas = (NSMutableArray*)array;
            [SVProgressHUD dismiss];
            tbl_data.delegate = self;
            tbl_data.dataSource = self;
            [tbl_data reloadData];
        }
    }];
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
- (IBAction)onAddAsFriend:(id)sender {
    //////
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
    [query1 whereKey:PARSE_FRIENDS_FROM equalTo:me];
    [query1 whereKey:PARSE_FRIENDS_TO equalTo:self.userInfo];
    [query1 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
    [query2 whereKey:PARSE_FOLLOW_TO equalTo:me];
    [query2 whereKey:PARSE_FRIENDS_FROM equalTo:self.userInfo];
    [query2 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query3 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
    [query3 whereKey:PARSE_FRIENDS_FROM equalTo:me];
    [query3 whereKey:PARSE_FRIENDS_TO equalTo:self.userInfo];
    [query3 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
    
    PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, query3 , nil]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            NSMutableArray *  dataArray = (NSMutableArray *)array;
            if(dataArray.count > 0){
                PFObject * friendObj = dataArray[0];
                BOOL isActive = [friendObj[PARSE_FRIENDS_ACTIVE] boolValue];
                if(isActive){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"" message:@"This user is already friend"];
                    return;
                }else{
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"" message:@"We are already send friend request to this user."];
                    return;
                }
            }else{
                PFObject * friendObj = [PFObject objectWithClassName:PARSE_TABLE_FRIENDS];
                friendObj[PARSE_FRIENDS_FROM] = me;
                friendObj[PARSE_FRIENDS_TO] = self.userInfo;
                friendObj[PARSE_FRIENDS_ACTIVE] = [NSNumber numberWithBool:NO];
                [friendObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                    PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                    notificationObj[PARSE_NOTIFICATION_SENDER] = me;
                    notificationObj[PARSE_NOTIFICATION_RECEIVER] = self.userInfo;
                    notificationObj[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_FRIEND];
                    [notificationObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                        for(PFObject * obj in dataArray){
                            [obj deleteInBackground];
                        }
                        [SVProgressHUD dismiss];
                        NSString *fullName = me[PARSE_USER_FULLNAME];
                        NSString *pushMsg = [NSString stringWithFormat:@"%@ send friend request.", fullName];
                        NSDictionary *data = @{
                                               @"alert" : pushMsg,
                                               @"badge" : @"Increment",
                                               @"sound" : @"cheering.caf",
                                               @"email" : self.userInfo.username,
                                               @"data"  : self.userInfo.objectId,
                                               @"type"  : [NSNumber numberWithInt:PUSH_TYPE_OTHER]
                                               };
                        [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                            if (err) {
                                NSLog(@"Fail APNS: %@", @"send ban push");
                            } else {
                                NSLog(@"Success APNS: %@", @"send ban push");
                            }
                        }];
                        
                        [Util showAlertTitle:self title:@"" message:@"Success"];
                    }];
                }];
            }
        }
    }];
    
}
- (IBAction)onFollowUser:(id)sender {
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query1 whereKey:PARSE_FOLLOW_FROM equalTo:me];
    [query1 whereKey:PARSE_FOLLOW_TO equalTo:self.userInfo];
    [query1 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query2 whereKey:PARSE_FOLLOW_TO equalTo:me];
    [query2 whereKey:PARSE_FOLLOW_FROM equalTo:self.userInfo];
    [query2 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query3 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query3 whereKey:PARSE_FOLLOW_FROM equalTo:me];
    [query3 whereKey:PARSE_FOLLOW_TO equalTo:self.userInfo];
    [query3 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:NO]];
    
    PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, query3 , nil]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            NSMutableArray *  dataArray = (NSMutableArray *)array;
            if(dataArray.count > 0){
                PFObject * friendObj = dataArray[0];
                BOOL isActive = [friendObj[PARSE_FOLLOW_ACTIVE] boolValue];
                if(isActive){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"" message:@"You are already follow this user."];
                    return;
                }else{
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"" message:@"We are already send follow request to this user."];
                    return;
                }
            }else{
                PFObject * friendObj = [PFObject objectWithClassName:PARSE_TABLE_FOLLOW];
                friendObj[PARSE_FOLLOW_FROM] = me;
                friendObj[PARSE_FOLLOW_TO] = self.userInfo;
                friendObj[PARSE_FOLLOW_ACTIVE] = [NSNumber numberWithBool:NO];
                [friendObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                    PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                    notificationObj[PARSE_NOTIFICATION_SENDER] = me;
                    notificationObj[PARSE_NOTIFICATION_RECEIVER] = self.userInfo;
                    notificationObj[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_FOLLOW];
                    [notificationObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                        for(PFObject * obj in dataArray){
                            [obj deleteInBackground];
                        }
                        [SVProgressHUD dismiss];
                        NSString *fullName = me[PARSE_USER_FULLNAME];
                        NSString *pushMsg = [NSString stringWithFormat:@"%@ send follow request.", fullName];
                        NSDictionary *data = @{
                                               @"alert" : pushMsg,
                                               @"badge" : @"Increment",
                                               @"sound" : @"cheering.caf",
                                               @"email" : self.userInfo.username,
                                               @"data"  : self.userInfo.objectId,
                                               @"type"  : [NSNumber numberWithInt:PUSH_TYPE_OTHER]
                                               };
                        [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                            if (err) {
                                NSLog(@"Fail APNS: %@", @"send ban push");
                            } else {
                                NSLog(@"Success APNS: %@", @"send ban push");
                            }
                        }];
                        [Util showAlertTitle:self title:@"" message:@"Success"];
                    }];
                }];
            }
        }
    }];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_sharedDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemInfoTableViewCell";
    ItemInfoTableViewCell *cell = (ItemInfoTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.view_container.layer.cornerRadius = 10.f;
        PFObject * sharedItem = [m_sharedDatas objectAtIndex:indexPath.row];
        PFObject * productItem = sharedItem[PARSE_SHARE_PRODUCT];
        
        [Util setImage:cell.img_thumb imgFile:productItem[PARSE_PRODUCT_THUMB]];
        cell.lbl_title.text = productItem[PARSE_PRODUCT_TITLE];
        cell.lbl_detail.text = productItem[PARSE_PRODUCT_DESCRIPTION];
        NSMutableArray * likes = productItem[PARSE_PRODUCT_LIKES];
        cell.lbl_likeCount.text = [NSString stringWithFormat:@"%d likes", (int)likes.count];
        int commentCount = [productItem[PARSE_PRODUCT_COMMENT_COUNT] intValue];
        cell.lbl_commentCount.text = [NSString stringWithFormat:@"%d comments", commentCount];
        
        PFGeoPoint * productPoint = productItem[PARSE_PRODUCT_LOCATION];
        PFGeoPoint * myPoint = self.userInfo[PARSE_USER_GEOPOINT];
        double distance = [myPoint distanceInMilesTo:productPoint];
        cell.lbl_distance.text = [NSString stringWithFormat:@"%.1f miles", distance];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PFObject * sharedItem = [m_sharedDatas objectAtIndex:indexPath.row];
    PFObject * productItem = sharedItem[PARSE_SHARE_PRODUCT];
    
    UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
    ItemDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemDetailViewController"];
    controller.productInfo = productItem;
    controller.runType = PRODUCTDETAIL_RUN_USER;
    [mainNav pushViewController:controller animated:YES];
}
@end
