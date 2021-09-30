//
//  UserMessageViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserMessageViewController.h"
#import "MessageTableViewCell.h"

UserMessageViewController *_sharedViewController;
@interface UserMessageViewController ()<UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>
{
     __weak IBOutlet UITableView *tbl_data;
    
    NSMutableArray *dataArray;
    NSMutableDictionary * unreadCounts;
    int calcIndex;
    
    PFUser *me;
}
@end

@implementation UserMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    me = [PFUser currentUser];
    _sharedViewController = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRooms) name:kChatReceiveNotificationUsers object:nil];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshRooms];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _sharedViewController = nil;
}
+ (UserMessageViewController *)getInstance{
    return _sharedViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) refreshRooms
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if (![SVProgressHUD isVisible])
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query1 whereKey:PARSE_ROOM_SENDER equalTo:me];
    
    PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:me];
    
    NSMutableArray *queries = [[NSMutableArray alloc] init];
    [queries addObject:query1];
    [queries addObject:query2];
    PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
    [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
    [query includeKey:PARSE_ROOM_RECEIVER];
    [query includeKey:PARSE_ROOM_SENDER];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query whereKeyExists:PARSE_ROOM_LAST_MESSAGE];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        
        unreadCounts = [NSMutableDictionary new];
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            dataArray = (NSMutableArray *) array;
            calcIndex = 0;
            [self getUnreadCount:dataArray :calcIndex];
        }
    }];
}
- (void) getUnreadCount:(NSMutableArray *) roomArray :(int)index
{
    if(index >= roomArray.count){
        [SVProgressHUD dismiss];
        tbl_data.delegate = self;
        tbl_data.dataSource = self;
        [tbl_data reloadData];
    }else{
        calcIndex = index;
        PFObject * rommDict = [roomArray objectAtIndex:index];
        PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_HISTORY];
        [query whereKey:PARSE_HISTORY_ROOM equalTo:rommDict];
        [query whereKey:PARSE_HISTORY_SENDER notEqualTo:[PFUser currentUser]];
        [query whereKey:PARSE_ROOM_IS_READ equalTo:[NSNumber numberWithBool:NO]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if(array.count > 0){
                [unreadCounts setObject:[NSNumber numberWithInt:(int)array.count] forKey:rommDict.objectId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                calcIndex ++;
                [self getUnreadCount:roomArray :calcIndex];
            });
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MessageTableViewCell";
    MessageTableViewCell *cell = (MessageTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.view_container.layer.cornerRadius = 10.f;
        cell.delegate = self;
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"ico_delete"] backgroundColor:[UIColor colorWithRed:221.f/255.0f green:65.f/255.0f blue:65.f/255.0f alpha:1.0f]]];
        cell.rightButtons[0].tag = indexPath.row;
        cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
        cell.rightExpansion.expansionLayout = MGSwipeExpansionLayoutCenter;
        cell.rightExpansion.buttonIndex = 1;
        
        PFObject *room = [dataArray objectAtIndex:indexPath.row];
        PFUser *sender = room[PARSE_ROOM_SENDER];
        PFUser *toUser;
        if ([sender.objectId isEqualToString:me.objectId]){
            toUser = room[PARSE_ROOM_RECEIVER];
        } else {
            sender = me;
            toUser = room[PARSE_ROOM_SENDER];
        }
        [Util setImage:cell.img_thumb imgFile:(PFFile *)toUser[PARSE_USER_AVATAR]];
        cell.lbl_username.text = toUser[PARSE_USER_FULLNAME];
        if (room[PARSE_ROOM_LAST_MESSAGE]){
            cell.lbl_lastMsg.text = room[PARSE_ROOM_LAST_MESSAGE];
            cell.lbl_time.text = [room.updatedAt formattedAsTimeAgo];
        };
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
