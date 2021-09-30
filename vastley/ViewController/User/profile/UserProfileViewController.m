//
//  UserProfileViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ItemInfoTableViewCell.h"
#import "ItemDetailViewController.h"
#import "UserHomeViewController.h"
#import "MyContactsViewController.h"

@interface UserProfileViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet CircleImageView *img_thumb;
    __weak IBOutlet UILabel *lbl_username;
    __weak IBOutlet UILabel *lbl_description;
    __weak IBOutlet UILabel *lbl_friendCount;
    __weak IBOutlet UILabel *lbl_followCount;
    
    __weak IBOutlet UITableView *tbl_data;
    
    NSMutableArray * m_sharedDatas;
    
    PFUser * me;
}
@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    
    [Util setImage:img_thumb imgFile:me[PARSE_USER_AVATAR]];
    lbl_username.text = me[PARSE_USER_FULLNAME];
    lbl_description.text = me[PARSE_USER_LOCATION];
    
    lbl_followCount.text  = @"0 followers";
    lbl_friendCount.text = @"0 friends";
    
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
    m_sharedDatas  = [NSMutableArray new];
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query1 whereKey:PARSE_FOLLOW_FROM equalTo:me];
    [query1 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FOLLOW];
    [query2 whereKey:PARSE_FOLLOW_TO equalTo:me];
    [query2 whereKey:PARSE_FOLLOW_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
    PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        }else{
            lbl_followCount.text  = [NSString stringWithFormat:@"%d followers", (int)array.count];
            
            PFQuery * query1 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
            [query1 whereKey:PARSE_FRIENDS_FROM equalTo:me];
            [query1 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
            PFQuery * query2 = [PFQuery queryWithClassName:PARSE_TABLE_FRIENDS];
            [query2 whereKey:PARSE_FRIENDS_TO equalTo:me];
            [query2 whereKey:PARSE_FRIENDS_ACTIVE equalTo:[NSNumber numberWithBool:YES]];
            PFQuery * query = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:query1, query2, nil]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                }else{
                    lbl_friendCount.text  = [NSString stringWithFormat:@"%d friends", (int)array.count];
                    
                    PFQuery * shareItemQuery = [PFQuery queryWithClassName:PARSE_TABLE_SHARE];
                    [shareItemQuery whereKey:PARSE_SHARE_SENDER equalTo:me];
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
            }];
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
- (IBAction)onCantacts:(id)sender {
    UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
    MyContactsViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyContactsViewController"];
    [mainNav pushViewController:controller animated:YES];
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
        PFGeoPoint * myPoint = me[PARSE_USER_GEOPOINT];
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
