//
//  UserNotificationViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserNotificationViewController.h"
#import "NotificationTableViewCell.h"

@interface UserNotificationViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tbl_data;
    NSMutableArray * notificationArray;
    
    PFUser * me;
}

@end

@implementation UserNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    tbl_data.layer.cornerRadius = 5.f;
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
    notificationArray = [NSMutableArray new];
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_RECEIVER equalTo:me];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query includeKey:PARSE_NOTIFICATION_SENDER];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            notificationArray = (NSMutableArray *) array;
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
    return notificationArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotificationTableViewCell";
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFObject * notificationObj = [notificationArray objectAtIndex:indexPath.row];
        PFUser * sender = notificationObj[PARSE_NOTIFICATION_SENDER];
        [Util setImage:cell.img_thumb imgFile:sender[PARSE_USER_AVATAR]];
        NSString * userName = sender[PARSE_USER_FULLNAME];
        NSString * notificationString = [NSString stringWithFormat:@"%@", userName];
        int notificationType = [notificationObj[PARSE_NOTIFICATION_TYPE] intValue];
        if(notificationType == SYSTEM_NOTIFICATION_TYPE_LIKE){
            notificationString = [notificationString stringByAppendingString:@" like your post."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_COMMENT){
            notificationString = [notificationString stringByAppendingString:@" add comment to your post."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_ORDER){
            notificationString = [notificationString stringByAppendingString:@" make order for your products."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_FRIEND){
            notificationString = [notificationString stringByAppendingString:@" send friend request."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_FOLLOW){
            notificationString = [notificationString stringByAppendingString:@" send follow request."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_ALLOW_FRIEND){
            notificationString = [notificationString stringByAppendingString:@" accepted your friend request."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_ALLOW_FOLLOW){
            notificationString = [notificationString stringByAppendingString:@" accepted your follow request."];
        }else if(notificationType == SYSTEM_NOTIFICATION_TYPE_SHAREPRODUCT){
            notificationString = [notificationString stringByAppendingString:@" has invited you for Co-shopping."];
        }else{
            notificationString = @"";
        }
        cell.lbl_title.text = notificationString;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
