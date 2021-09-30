//
//  UserItemsViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserItemsViewController.h"
#import "ItemInfoTableViewCell.h"
#import "UserHomeViewController.h"
#import "ItemDetailViewController.h"

@interface UserItemsViewController ()<UITableViewDataSource, UITableViewDelegate, IQDropDownTextFieldDelegate>
{
    __weak IBOutlet UITableView *tbl_data;
    
    __weak IBOutlet UILabel *lbl_userLocation;
    
    __weak IBOutlet IQDropDownTextField *edt_distance;
    PFUser * me;
    
    NSMutableArray * products;
    
    int distanceNum;
}
@end

@implementation UserItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    lbl_userLocation.text = me[PARSE_USER_LOCATION];
    
    distanceNum = 100;
    edt_distance.selectedItem = @"100 miles";
    edt_distance.delegate = self;
    edt_distance.isOptionalDropDown = NO;
    [edt_distance setItemList:@[@"100 miles", @"250 miles", @"500 miles", @"1000 miles", @"Anywhere"]];
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
-(void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nullable NSString*)item
{
    int selectedIndex = (int)textField.selectedRow;
    if(selectedIndex == 0) distanceNum = 100;
    if(selectedIndex == 1) distanceNum = 250;
    if(selectedIndex == 2) distanceNum = 500;
    if(selectedIndex == 3) distanceNum = 1000;
    if(selectedIndex == 4) distanceNum = 10000;
    [self fetchData];
}


- (void) fetchData
{
    products = [NSMutableArray new];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * productQuery = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
    [productQuery includeKey:PARSE_PRODUCT_OWNER];
    PFGeoPoint * geoPoint = me[PARSE_USER_GEOPOINT];
    [productQuery whereKey:PARSE_PRODUCT_LOCATION nearGeoPoint:geoPoint withinMiles:distanceNum];
    
    [productQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            products = (NSMutableArray *) array;
            products = [[products sortedArrayUsingComparator:^NSComparisonResult(PFObject * a, PFObject * b) {
                PFGeoPoint* curPos = (PFGeoPoint*)me[PARSE_USER_GEOPOINT];
                PFGeoPoint * productPos1 = a[PARSE_PRODUCT_LOCATION];
                PFGeoPoint * productPos2 = b[PARSE_PRODUCT_LOCATION];
                double dist_left = [curPos distanceInMilesTo:productPos1];
                double dist_right = [curPos distanceInMilesTo:productPos2];
                return dist_right < dist_left;
            }] mutableCopy];
            
            
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
- (BOOL) containsMe:(NSMutableArray*)array
{
    for(PFUser * user in array){
        if([user.objectId isEqualToString:me.objectId]){
            return YES;
        }
    }
    return NO;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return products.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ItemInfoTableViewCell";
    ItemInfoTableViewCell *cell = (ItemInfoTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.view_container.layer.cornerRadius = 10.f;
        PFObject * productItem = [products objectAtIndex:indexPath.row];
        [Util setImage:cell.img_thumb imgFile:productItem[PARSE_PRODUCT_THUMB]];
        cell.lbl_title.text = productItem[PARSE_PRODUCT_TITLE];
        cell.lbl_detail.text = productItem[PARSE_PRODUCT_DESCRIPTION];
        NSMutableArray * likes = productItem[PARSE_PRODUCT_LIKES];
        cell.lbl_likeCount.text = [NSString stringWithFormat:@"%d likes", (int)likes.count];
        if([self containsMe:likes]){
            [cell.ic_favourite setImage:[UIImage imageNamed:@"ico_like"]];
        }else{
            [cell.ic_favourite setImage:[UIImage imageNamed:@"ic_favourite"]];
        }
        int commentCount = [productItem[PARSE_PRODUCT_COMMENT_COUNT] intValue];
        cell.lbl_commentCount.text = [NSString stringWithFormat:@"%d comments", commentCount];
        
        PFGeoPoint * productPoint = productItem[PARSE_PRODUCT_LOCATION];
        PFGeoPoint * myPoint = me[PARSE_USER_GEOPOINT];
        double distance = [myPoint distanceInMilesTo:productPoint];
        cell.lbl_distance.text = [NSString stringWithFormat:@"%.1f miles", distance];
        
        cell.btn_like.tag = indexPath.row;
        [cell.btn_like addTarget:self action:@selector(onLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject * productItem = [products objectAtIndex:indexPath.row];
    UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
    ItemDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemDetailViewController"];
    controller.productInfo = productItem;
    controller.runType = PRODUCTDETAIL_RUN_USER;
    [mainNav pushViewController:controller animated:YES];
}
- (void) onLikeAction:(UIButton*)button
{
    int index = (int)button.tag;
    PFObject * productItem = [products objectAtIndex:index];
    NSMutableArray * likes = productItem[PARSE_PRODUCT_LIKES];
    if(!likes)
        likes = [NSMutableArray new];
    if([self containsMe:likes]){
        [Util showAlertTitle:self title:@"" message:@"You are already like this post."];
    }else{
        [likes addObject:[PFUser currentUser]];
        productItem[PARSE_PRODUCT_LIKES] = likes;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [productItem saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            [self fetchData];
        }];
    }
}
@end
