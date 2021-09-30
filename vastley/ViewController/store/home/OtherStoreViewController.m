//
//  OtherStoreViewController.m
//  vastley
//
//  Created by Techsviewer on 8/21/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "OtherStoreViewController.h"
#import "ItemDetailViewController.h"
#import "ProductCollectionViewCell.h"
#import "UserHomeViewController.h"

@interface OtherStoreViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    __weak IBOutlet UITextView *txt_storeNote;
    __weak IBOutlet UICollectionView *collectionData;
    
    __weak IBOutlet UIButton *btn_info;
    __weak IBOutlet UIButton *btn_product;
    
    __weak IBOutlet UIImageView *img_thumb;
    __weak IBOutlet UILabel *lbl_compName;
    __weak IBOutlet UILabel *lbl_follows;
    
    NSMutableArray * products;
}
@end

@implementation OtherStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    img_thumb.image = nil;
    lbl_compName.text = @"";
    lbl_follows.text = @"0 Followers";
    txt_storeNote.text = @"";
    
    [btn_info setSelected:YES];
    [btn_product setSelected:NO];
    [txt_storeNote setHidden:NO];
    [collectionData setHidden:YES];
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
    products = [NSMutableArray new];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * productQuery = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
    [productQuery includeKey:PARSE_PRODUCT_OWNER];
    [productQuery whereKey:PARSE_PRODUCT_OWNER equalTo:self.companyInfo];
    [productQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
        } else {
            products = (NSMutableArray *) array;
            [self.companyInfo fetchIfNeeded];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Util setImage:img_thumb imgFile:self.companyInfo[PARSE_USER_COMPAVATAR]];
                [lbl_compName setText:self.companyInfo[PARSE_USER_COMPANY]];
                NSString * description = [NSString stringWithFormat:@"Phone Number: %@\n", self.companyInfo[PARSE_USER_CONTACTNUM]];
                description = [description stringByAppendingFormat:@"Location: %@\n", self.companyInfo[PARSE_USER_LOCATION]];
                description = [description stringByAppendingFormat:@"Email: %@\n", self.companyInfo[PARSE_USER_NAME]];
                txt_storeNote.text = description;
                [btn_product setTitle:[NSString stringWithFormat:@"Products(%d)", products.count] forState:UIControlStateNormal];
                
                if(btn_info.selected){
                    [self onSelectInfomation:nil];
                }else if(btn_product.selected){
                    [self onSelectProducts:nil];
                }
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
- (IBAction)onSelectInfomation:(id)sender {
    [btn_info setSelected:YES];
    [btn_product setSelected:NO];
    [txt_storeNote setHidden:NO];
    [collectionData setHidden:YES];
}
- (IBAction)onSelectProducts:(id)sender {
    [btn_info setSelected:NO];
    [btn_product setSelected:YES];
    [txt_storeNote setHidden:YES];
    [collectionData setHidden:NO];
    
    collectionData.delegate = self;
    collectionData.dataSource = self;
    [collectionData reloadData];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onFollowing:(id)sender {
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return products.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    return CGSizeMake(collectionView.frame.size.width / 3.f, collectionView.frame.size.width / 3.f);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        PFObject * productInfo = [products objectAtIndex:indexPath.row];
        cell.lbl_price.text = [NSString stringWithFormat:@"$ %@", productInfo[PARSE_PRODUCT_PRICE]];
        [Util setImage:cell.img_thumb imgFile:productInfo[PARSE_PRODUCT_THUMB]];
    }
    return cell;
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    PFObject * productInfo = [products objectAtIndex:indexPath.row];
    
    UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
    ItemDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemDetailViewController"];
    controller.productInfo = productInfo;
    controller.runType = PRODUCTDETAIL_RUN_USER;
    [mainNav pushViewController:controller animated:YES];
}
@end
