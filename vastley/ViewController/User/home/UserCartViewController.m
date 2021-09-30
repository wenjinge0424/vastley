//
//  UserCartViewController.m
//  vastley
//
//  Created by Techsviewer on 8/21/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserCartViewController.h"
#import "CartItemTableViewCell.h"
#import "UserDeliveryDetailViewController.h"

@interface UserCartViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    PFUser * me;
    __weak IBOutlet UITableView *tbl_data;
    __weak IBOutlet UILabel *lbl_title;
    
    NSMutableArray * m_productArray;
    NSMutableArray * sortedArray;
    NSMutableArray * storeIdArray;
}
@end

@implementation UserCartViewController

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
- (BOOL) arrayContainsUser:(PFUser*)subUsr inArray:(NSArray*)array
{
    for(PFObject * user in array){
        if([user.objectId isEqualToString:subUsr.objectId]){
            return YES;
        }
    }
    return NO;
}
- (int) indexOfUser:(PFUser*)subUsr inArray:(NSArray*)array
{
    for(PFObject * user in array){
        if([user.objectId isEqualToString:subUsr.objectId]){
            return (int)[array indexOfObject:user];
        }
    }
    return -1;
}
- (NSMutableArray *) getStoreProductArray:(PFUser*)store
{
    int index = [self indexOfUser:store inArray:storeIdArray];
    return [sortedArray objectAtIndex:index];
}
- (void) fetchData
{
    m_productArray = [NSMutableArray new];
    sortedArray = [NSMutableArray new];
    storeIdArray = [NSMutableArray new];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_CART];
    [query whereKey:PARSE_CART_SENDER equalTo:me];
    [query includeKey:PARSE_CART_SENDER];
    [query includeKey:PARSE_CART_OWNER];
    [query includeKey:PARSE_CART_PRODUCT];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            m_productArray = (NSMutableArray *) array;
            for(PFObject * object in m_productArray){
                PFUser * owner = object[PARSE_CART_OWNER];
                if([self arrayContainsUser:owner inArray:storeIdArray]){
                    int index = [self indexOfUser:owner inArray:storeIdArray];
                    NSMutableArray * storeProducts = [sortedArray objectAtIndex:index];
                    if(!storeProducts) storeProducts = [NSMutableArray new];
                    [storeProducts addObject:object];
                }else{
                    [storeIdArray addObject:owner];
                    NSMutableArray * storeProducts = [NSMutableArray new];
                    [storeProducts addObject:object];
                    [sortedArray addObject:storeProducts];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                lbl_title.text = [NSString stringWithFormat:@"My Carts(%d)", (int)m_productArray.count];
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == tbl_data){
        return storeIdArray.count;
    }
    PFUser * productId = [storeIdArray objectAtIndex:tableView.tag];
    NSMutableArray * storeProducts = [self getStoreProductArray:productId];
    return storeProducts.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbl_data){
        PFUser * productId = [storeIdArray objectAtIndex:indexPath.row];
        NSMutableArray * storeProducts = [self getStoreProductArray:productId];
        return 200 + 120 * storeProducts.count;
    }
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tv == tbl_data){
        static NSString *cellIdentifier = @"CartItemTableViewCell";
        CartItemTableViewCell *cell = (CartItemTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.view_container.layer.cornerRadius = 5.f;
            PFUser * productId = [storeIdArray objectAtIndex:indexPath.row];
            cell.lbl_soldBy.text = [NSString stringWithFormat:@"Sold by: %@", productId[PARSE_USER_COMPANY]];
            NSMutableArray * compProducts = [self getStoreProductArray:productId];
            float totalAmount = 0;
            for(PFObject * cart in compProducts){
                PFObject * product = cart[PARSE_CART_PRODUCT];
                float value = [product[PARSE_PRODUCT_PRICE] floatValue];
                totalAmount += value;
            }
            cell.lbl_total.text = [NSString stringWithFormat:@"$ %.2f", totalAmount];
            
            cell.dataTable.tag = indexPath.row;
            cell.dataTable.scrollEnabled = NO;
            cell.dataTable.delegate = self;
            cell.dataTable.dataSource = self;
            [cell.dataTable reloadData];
            
            cell.btn_order.tag = indexPath.row;
            [cell.btn_order addTarget:self action:@selector(onStartOrder:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }else{
        static NSString *cellIdentifier = @"SubCartItemTableViewCell";
        SubCartItemTableViewCell *cell = (SubCartItemTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            PFUser * productId = [storeIdArray objectAtIndex:tv.tag];
            NSMutableArray * compProducts = [self getStoreProductArray:productId];
            PFObject * cartObj = [compProducts objectAtIndex:indexPath.row];
            PFObject * product = cartObj[PARSE_CART_PRODUCT];
            [Util setImage:cell.img_thumb imgFile:product[PARSE_PRODUCT_THUMB]];
            cell.lbl_price.text = [NSString stringWithFormat:@"$ %@", product[PARSE_PRODUCT_PRICE]];
            cell.btn_delete.tag = tv.tag;
            cell.btn_delete.secondTag = (int)indexPath.row;
            [cell.btn_delete addTarget:self action:@selector(onDeleteCartItem:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) onStartOrder:(UIButton*)button
{
    int tag = (int)button.tag;
    PFUser * productId = [storeIdArray objectAtIndex:tag];
    NSMutableArray * compProducts = [self getStoreProductArray:productId];
    UserDeliveryDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserDeliveryDetailViewController"];
    controller.cartitems = compProducts;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) onDeleteCartItem:(TwoTagButton*)button
{
    int tag = (int)button.tag;
    int secondTag = button.secondTag;
    PFUser * productId = [storeIdArray objectAtIndex:tag];
    NSMutableArray * compProducts = [self getStoreProductArray:productId];
    PFObject * cartObj = [compProducts objectAtIndex:secondTag];
    
    NSString *msg = @"Are you sure delete this item from your cart?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"No" actionBlock:^(void) {
    }];
    [alert addButton:@"Yes" actionBlock:^(void) {
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [cartObj deleteInBackgroundWithBlock:^(BOOL success, NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Success"];
            [self fetchData];
        }];
    }];
    [alert showError:@"Delete Cart" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
@end
