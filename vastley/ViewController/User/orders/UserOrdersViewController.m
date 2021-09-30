//
//  UserOrdersViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserOrdersViewController.h"
#import "OrderTableViewCell.h"
#import "GKActionSheetPicker.h"

@interface UserOrdersViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tbl_data;
    PFUser * me;
    NSMutableArray * m_productArray;
    
    NSMutableArray * m_friendsList;
}
@property (nonatomic, retain) GKActionSheetPicker * actioSheetPicker;
@end

@implementation UserOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    
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
    m_productArray = [NSMutableArray new];
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_ORDER];
    [query whereKey:PARSE_ORDER_SENDER equalTo:me];
    [query includeKey:PARSE_ORDER_OWNER];
    [query includeKey:PARSE_ORDER_PRODUCT];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            m_productArray = (NSMutableArray *) array;
            dispatch_async(dispatch_get_main_queue(), ^{
                tbl_data.delegate = self;
                tbl_data.dataSource = self;
                [tbl_data reloadData];
            });
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_productArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"OrderTableViewCell";
    OrderTableViewCell *cell = (OrderTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.view_container.layer.cornerRadius = 10.f;
        PFObject * orderInfo = [m_productArray objectAtIndex:indexPath.row];
        cell.lbl_orderIdenty.text = [NSString stringWithFormat:@"Order #%@", orderInfo[PARSE_ORDER_IDENTIFY]];
        cell.lbl_placedTime.text = [NSString stringWithFormat:@"Placed on %@", [Util convertDateToString:orderInfo.updatedAt]];
        PFObject * productInfo = orderInfo[PARSE_ORDER_PRODUCT];
        [Util setImage:cell.img_thumb imgFile:productInfo[PARSE_PRODUCT_THUMB]];
        cell.lbl_productTitle.text = productInfo[PARSE_PRODUCT_TITLE];
        cell.lbl_deliveredTime.text = [NSString stringWithFormat:@"Delivered %@", [Util convertDateToString:productInfo.updatedAt]];
        
        cell.btn_menu.tag = indexPath.row;
        cell.btn_deliverd.tag = indexPath.row;
        cell.btn_share.tag = indexPath.row;
        
        [cell.btn_menu addTarget:self action:@selector(onOrderMenu:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_deliverd addTarget:self action:@selector(onDelivered:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_share addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) onOrderMenu:(UIButton*)button
{
    
}
- (void) onDelivered:(UIButton*)button
{
    
}
- (void) onShare:(UIButton*)button
{
    PFObject * orderInfo = [m_productArray objectAtIndex:button.tag];
    PFObject * productInfo = orderInfo[PARSE_ORDER_PRODUCT];
    
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
    [query1 whereKey:PARSE_FRIENDS_FROM equalTo:me];
    [query1 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
    [query2 whereKey:PARSE_FRIENDS_TO equalTo:me];
    [query2 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
    [query includeKey:PARSE_FRIENDS_TO];
    [query includeKey:PARSE_FRIENDS_FROM];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        }else{
            NSMutableArray * namesArray = [NSMutableArray new];
            m_friendsList = [NSMutableArray new];
            for(PFObject * obj in array){
                PFObject * friend = obj[PARSE_FRIENDS_TO];
                if([friend.objectId isEqualToString:me.objectId]){
                    friend = obj[PARSE_FRIENDS_FROM];
                }
                [namesArray addObject:[GKActionSheetPickerItem pickerItemWithTitle:friend[PARSE_USER_FULLNAME] value:friend]];
                [m_friendsList addObject:friend];
            }
            if(namesArray.count > 0){
                self.actioSheetPicker = [GKActionSheetPicker stringPickerWithItems:namesArray selectCallback:^(id selected){
                    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
                    
                    PFUser * sharedUser = selected;
                    PFObject * sharedObj = [PFObject objectWithClassName:PARSE_TABLE_SHARE];
                    sharedObj[PARSE_SHARE_SENDER] = me;
                    sharedObj[PARSE_SHARE_RECEIVER] = sharedUser;
                    sharedObj[PARSE_SHARE_PRODUCT] = productInfo;
                    [sharedObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                        if (error){
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                        }else{
                            PFObject * cartInfo = [PFObject objectWithClassName:PARSE_TABLE_CART];
                            cartInfo[PARSE_CART_SENDER]= sharedUser;
                            cartInfo[PARSE_CART_OWNER] = productInfo[PARSE_PRODUCT_OWNER];
                            cartInfo[PARSE_CART_PRODUCT] = productInfo;
                            cartInfo[PARSE_CART_ISSHARED] = [NSNumber numberWithBool:YES];
                            cartInfo[PARSE_CART_SHAREDUSER] = [PFUser currentUser];
                            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                            [cartInfo saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                                if (error){
                                    [SVProgressHUD dismiss];
                                    [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                                } else {
                                    PFObject * notificaionQuery = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                                    notificaionQuery[PARSE_NOTIFICATION_SENDER] = me;
                                    notificaionQuery[PARSE_NOTIFICATION_RECEIVER] = sharedUser;
                                    notificaionQuery[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_SHAREPRODUCT];
                                    [notificaionQuery saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                                        if (error){
                                            [SVProgressHUD dismiss];
                                            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                                        } else {
                                            [SVProgressHUD dismiss];
                                            NSString *fullName = @"";
                                            fullName = me[PARSE_USER_FULLNAME];
                                            NSString *pushMsg = [NSString stringWithFormat:@"%@ shared product with you.", fullName];
                                            NSDictionary *data = @{
                                                                   @"alert" : pushMsg,
                                                                   @"badge" : @"Increment",
                                                                   @"sound" : @"cheering.caf",
                                                                   @"email" : sharedUser.username,
                                                                   @"data"  : sharedUser.objectId,
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
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                } cancelCallback:nil];
                self.actioSheetPicker.selectButtonTitle =  @"Share";
                self.actioSheetPicker.cancelButtonTitle = @"No";
                self.actioSheetPicker.title = @"Share With:";
                [self.actioSheetPicker presentPickerOnView:self.view];
            }else{
                [Util showAlertTitle:self title:@"Error" message:@"You have no friend for share product"];
            }
        }
    }];
}
@end
