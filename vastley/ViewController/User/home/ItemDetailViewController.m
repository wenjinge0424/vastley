//
//  ItemDetailViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ImageCollectionViewCell.h"
#import "ImageTitleTableViewCell.h"
#import "StoreHomeViewController.h"
#import "UserHomeViewController.h"
#import "StoreAddItemViewController.h"
#import "OtherProfileViewController.h"
#import "OtherStoreViewController.h"
#import "UserCartViewController.h"

@interface ItemDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *tbl_data;
    __weak IBOutlet UICollectionView *img_collection;
    __weak IBOutlet UILabel *lbl_title;
    __weak IBOutlet UILabel *lbl_price;
    __weak IBOutlet UILabel *lbl_subTitle;
    __weak IBOutlet UIPageControl *pageControl;
    __weak IBOutlet UIButton *btn_beforeImg;
    __weak IBOutlet UIButton *btn_nextImage;
    __weak IBOutlet UITextView *txt_description;
    __weak IBOutlet UILabel *lbl_likeCount;
    __weak IBOutlet UIButton *btn_cart;
    __weak IBOutlet UIButton *btn_action;
    
    __weak IBOutlet UITextField *txtComment;
    
    __weak IBOutlet UIView *view_radios;
    
    NSMutableArray * dataArray;
    NSMutableArray *heightArray;
    
    NSInteger commentCount;
    
    NSMutableArray * productThumbArray;
}
@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.runType == PRODUCTDETAIL_RUN_STORE){
        btn_cart.hidden = YES;
        [btn_action setTitle:@"Edit Item" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.productInfo fetchIfNeeded];
    
    lbl_title.text = self.productInfo[PARSE_PRODUCT_TITLE];
    lbl_price.text = [NSString stringWithFormat:@"$ %@", self.productInfo[PARSE_PRODUCT_PRICE]];
    PFUser * owner = self.productInfo[PARSE_PRODUCT_OWNER];
    [owner fetchIfNeeded];
    lbl_subTitle.text = owner[PARSE_USER_COMPANY];
    txt_description.text = self.productInfo[PARSE_PRODUCT_DESCRIPTION];
    if(self.productInfo[PARSE_PRODUCT_LIKES]){
        lbl_likeCount.text = [NSString stringWithFormat:@"%d likes", (int)[self.productInfo[PARSE_PRODUCT_LIKES] count]];
    }else{
        lbl_likeCount.text = @"0 likes";
    }
    commentCount = [self.productInfo[PARSE_PRODUCT_COMMENT_COUNT] integerValue];
    
    productThumbArray = [NSMutableArray new];
    productThumbArray = self.productInfo[PARSE_PRODUCT_IMAGES];
    if(!productThumbArray || productThumbArray.count == 0){
        productThumbArray = [NSMutableArray new];
        [productThumbArray addObject:self.productInfo[PARSE_PRODUCT_THUMB]];
    }
    if(productThumbArray.count == 1){
        [btn_beforeImg setHidden:YES];
        [btn_nextImage setHidden:YES];
        [pageControl setHidden:YES];
    }else{
        [btn_beforeImg setHidden:NO];
        [btn_nextImage setHidden:NO];
        [pageControl setHidden:NO];
        pageControl.numberOfPages = productThumbArray.count;
    }
    [self fetchData];
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_COMMENT];
    [query whereKey:PARSE_COMMENT_POST equalTo:self.productInfo];
    [query includeKey:PARSE_COMMENT_USER];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            dataArray = (NSMutableArray *)array;
            heightArray = [[NSMutableArray alloc] init];
            for (int i=0;i<dataArray.count;i++){
                [heightArray addObject:[NSString stringWithFormat:@"%f", [self getHeight:i]]];
            }
            tbl_data.delegate = self;
            tbl_data.dataSource = self;
            [tbl_data reloadData];
            
            img_collection.delegate = self;
            img_collection.dataSource = self;
            img_collection.pagingEnabled = YES;
            view_radios.layer.cornerRadius = 10.f;
            [img_collection reloadData];
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
- (IBAction)onBeforeImage:(id)sender {
    CGPoint currentPoint = img_collection.contentOffset;
    int currentIndex = currentPoint.x / img_collection.frame.size.width;
    if(currentIndex == 0)
        return;
    [img_collection setContentOffset:CGPointMake((currentIndex - 1) * img_collection.frame.size.width, 0) animated:YES];
    pageControl.currentPage = currentIndex- 1;
}
- (IBAction)onNextImage:(id)sender {
    CGPoint currentPoint = img_collection.contentOffset;
    int currentIndex = currentPoint.x / img_collection.frame.size.width;
    if(currentIndex >= productThumbArray.count -1)
        return;
    [img_collection setContentOffset:CGPointMake((currentIndex + 1) * img_collection.frame.size.width, 0) animated:YES];
    pageControl.currentPage = currentIndex + 1;
}
- (IBAction)onCart:(id)sender {
    UserCartViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserCartViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onGotoStore:(id)sender {
    if(self.runType == PRODUCTDETAIL_RUN_USER){
        UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
        OtherStoreViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherStoreViewController"];
        controller.companyInfo = self.productInfo[PARSE_PRODUCT_OWNER];
        [mainNav pushViewController:controller animated:YES];
    }
}
- (IBAction)onAddToCart:(id)sender {
    if(self.runType == PRODUCTDETAIL_RUN_STORE){
        UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
        StoreAddItemViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StoreAddItemViewController"];
        controller.runMode = ITEMEDIT_MODE_EDIT;
        controller.productInfo = self.productInfo;
        [mainNav pushViewController:controller animated:YES];
    }else{
        PFObject * cartInfo = [PFObject objectWithClassName:PARSE_TABLE_CART];
        cartInfo[PARSE_CART_SENDER]= [PFUser currentUser];
        cartInfo[PARSE_CART_OWNER] = self.productInfo[PARSE_PRODUCT_OWNER];
        cartInfo[PARSE_CART_PRODUCT] = self.productInfo;
        cartInfo[PARSE_CART_ISSHARED] = [NSNumber numberWithBool:NO];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [cartInfo saveInBackgroundWithBlock:^(BOOL success, NSError * error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Success"];
            }
        }];
    }
}

- (IBAction)onPostComment:(id)sender {
    [self.view endEditing:YES];
    txtComment.text = [Util trim:txtComment.text];
    NSString *comment = txtComment.text;
    if (comment.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input comment."];
        return;
    }
    if (comment.length > 500){
        [Util showAlertTitle:self title:@"Error" message:@"Comment is too long."];
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    txtComment.text = @"";
    PFUser * postOwner  = self.productInfo[PARSE_PRODUCT_OWNER];
    PFUser * me = [PFUser currentUser];
    PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_COMMENT];
    obj[PARSE_COMMENT_POST] = self.productInfo;
    obj[PARSE_COMMENT_USER] = [PFUser currentUser];
    obj[PARSE_COMMENT_TEXT] = comment;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            int count = [self.productInfo[PARSE_PRODUCT_COMMENT_COUNT] intValue];
            self.productInfo[PARSE_PRODUCT_COMMENT_COUNT] = [NSNumber numberWithInt:(count+1)];
            [self.productInfo saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                commentCount++;
                if([postOwner.objectId isEqualToString:me.objectId]){
                    [self fetchData];
                }else{
                    PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                    notificationObj[PARSE_NOTIFICATION_SENDER] = me;
                    notificationObj[PARSE_NOTIFICATION_RECEIVER] = postOwner;
                    notificationObj[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_COMMENT];
                    [notificationObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                        [SVProgressHUD dismiss];
                        NSString *fullName = @"";
                        
                        fullName = me[PARSE_USER_FULLNAME];
                        NSString *pushMsg = [NSString stringWithFormat:@"%@ commented on your product.", fullName];
                        NSDictionary *data = @{
                                               @"alert" : pushMsg,
                                               @"badge" : @"Increment",
                                               @"sound" : @"cheering.caf",
                                               @"email" : postOwner.username,
                                               @"data"  : postOwner.objectId,
                                               @"type"  : [NSNumber numberWithInt:PUSH_TYPE_COMMENT]
                                               };
                        [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                            if (err) {
                                NSLog(@"Fail APNS: %@", @"send ban push");
                            } else {
                                NSLog(@"Success APNS: %@", @"send ban push");
                            }
                        }];
                        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                            [self fetchData];
                        }];
                    }];
                }
            }];
        }
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ImageTitleTableViewCell";
    ImageTitleTableViewCell *cell = (ImageTitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFObject *object = dataArray[indexPath.row];
        PFUser *user = object[PARSE_COMMENT_USER];
        [Util setImage:cell.img_thumb imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
        cell.lbl_title.text = user[PARSE_USER_FULLNAME];
        cell.lbl_description.text = object[PARSE_COMMENT_TEXT];
        cell.btn_thumbDetail.tag = indexPath.row;
        [cell.btn_thumbDetail addTarget:self action:@selector(onSelectThumbDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[heightArray objectAtIndex:indexPath.row] floatValue];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void) onSelectThumbDetail:(UIButton*)button
{
    int index = (int)button.tag;
    PFObject *object = dataArray[index];
    PFUser *user = object[PARSE_COMMENT_USER];
    if(self.runType == PRODUCTDETAIL_RUN_STORE){
        UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
        OtherProfileViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherProfileViewController"];
        controller.userInfo = user;
        [mainNav pushViewController:controller animated:YES];
    }else{
        UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
        OtherProfileViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OtherProfileViewController"];
        controller.userInfo = user;
        [mainNav pushViewController:controller animated:YES];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return productThumbArray.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        PFFile * productImage = [productThumbArray objectAtIndex:indexPath.row];
        [Util setImage:cell.img_thumb imgFile:productImage];
    }
    return cell;
}


- (CGFloat) getHeight:(NSInteger)row {
    UITextView *textView = [[UITextView alloc] init];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(265, 20);
    textView.frame = newFrame;
    
    PFObject *feed = [dataArray objectAtIndex:row];
    NSString *text = feed[PARSE_COMMENT_TEXT];
    textView.text = text;
    
    textView.translatesAutoresizingMaskIntoConstraints = YES;
    [textView sizeToFit];
    textView.scrollEnabled =NO;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize new = [self calculateHeightForString:text];
    CGRect newFrame1 = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, new.height);
    textView.frame = newFrame1;
    
    return 60 + new.height;
}
//our helper method
- (CGSize)calculateHeightForString:(NSString *)str
{
    CGSize size = CGSizeZero;
    
    UIFont *labelFont = [UIFont systemFontOfSize:12.0f];
    NSDictionary *systemFontAttrDict = [NSDictionary dictionaryWithObject:labelFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:str attributes:systemFontAttrDict];
    CGRect rect = [message boundingRectWithSize:(CGSize){320, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];//you need to specify the some width, height will be calculated
    size = CGSizeMake(rect.size.width, rect.size.height + 5); //padding
    
    return size;
    
}
@end
