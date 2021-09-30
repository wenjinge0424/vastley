//
//  StoreInfoViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "StoreInfoViewController.h"
#import "ProductCollectionViewCell.h"
#import "OrderTableViewCell.h"
#import "StoreHomeViewController.h"
#import "StoreAddItemViewController.h"
#import "ItemDetailViewController.h"

@interface StoreInfoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    __weak IBOutlet UITextView *txt_storeNote;
    __weak IBOutlet UITableView *tbl_data;
    __weak IBOutlet UICollectionView *collectionData;
    
    __weak IBOutlet UIButton *btn_info;
    __weak IBOutlet UIButton *btn_product;
    __weak IBOutlet UIButton *btn_orders;
    __weak IBOutlet UIButton *btn_addNewItem;
    
    PFUser * me;
    __weak IBOutlet UIImageView *img_thumb;
    __weak IBOutlet UILabel *lbl_compName;
    __weak IBOutlet UILabel *lbl_follows;
    
    UIImage * selectedImage;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    NSMutableArray * products;
    NSMutableArray * orderArray;
    __weak IBOutlet NSLayoutConstraint *contrant_containerTop;//230
}
@end

@implementation StoreInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeUI];
    
    me = [PFUser currentUser];
    
    [btn_info setSelected:YES];
    [btn_product setSelected:NO];
    [btn_orders setSelected:NO];
    [txt_storeNote setHidden:NO];
    [tbl_data setHidden:YES];
    [collectionData setHidden:YES];
    [btn_addNewItem setHidden:YES];
}
- (void) initializeUI
{
    img_thumb.image = nil;
    lbl_compName.text = @"";
    lbl_follows.text = @"";
    txt_storeNote.text = @"";
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
    orderArray = [NSMutableArray new];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if(btn_info.isSelected || btn_product.selected){
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [me fetchInBackgroundWithBlock:^(PFObject * obj, NSError * error){
            if(error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                return;
            }else{
                me = (PFUser *) obj;
                
                PFQuery * productQuery = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
                [productQuery includeKey:PARSE_PRODUCT_OWNER];
                [productQuery whereKey:PARSE_PRODUCT_OWNER equalTo:me];
                [productQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                    [SVProgressHUD dismiss];
                    if (error){
                        [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
                    } else {
                        products = (NSMutableArray *) array;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [Util setImage:img_thumb imgFile:me[PARSE_USER_COMPAVATAR]];
                            [lbl_compName setText:me[PARSE_USER_COMPANY]];
                            NSString * description = [NSString stringWithFormat:@"Phone Number: %@\n", me[PARSE_USER_CONTACTNUM]];
                            description = [description stringByAppendingFormat:@"Location: %@\n", me[PARSE_USER_LOCATION]];
                            description = [description stringByAppendingFormat:@"Email: %@\n", me[PARSE_USER_EMAIL]];
                            txt_storeNote.text = description;
                            [btn_product setTitle:[NSString stringWithFormat:@"Products(%d)", (int)products.count] forState:UIControlStateNormal];
                            
                            if(btn_product.selected){
                                collectionData.delegate = self;
                                collectionData.dataSource = self;
                                [collectionData reloadData];
                            }
                        });
                    }
                }];
            }
        }];
    }else if(btn_orders.selected){
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_ORDER];
        [query whereKey:PARSE_ORDER_OWNER equalTo:me];
        [query orderByDescending:PARSE_FIELD_UPDATED_AT];
        [query includeKey:PARSE_ORDER_SENDER];
        [query includeKey:PARSE_ORDER_PRODUCT];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            } else {
                orderArray = (NSMutableArray *) array;
                dispatch_async(dispatch_get_main_queue(), ^{
                    tbl_data.delegate = self;
                    tbl_data.dataSource = self;
                    [tbl_data reloadData];
                });
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
- (IBAction)onSelectInfomation:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        contrant_containerTop.constant = 250;
        [self.view layoutIfNeeded];
    }];
    [btn_info setSelected:YES];
    [btn_product setSelected:NO];
    [btn_orders setSelected:NO];
    [txt_storeNote setHidden:NO];
    [tbl_data setHidden:YES];
    [collectionData setHidden:YES];
    [btn_addNewItem setHidden:YES];
    [self fetchData];
}
- (IBAction)onSelectProducts:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        contrant_containerTop.constant = 250;
        [self.view layoutIfNeeded];
    }];
    [btn_info setSelected:NO];
    [btn_product setSelected:YES];
    [btn_orders setSelected:NO];
    [txt_storeNote setHidden:YES];
    [tbl_data setHidden:YES];
    [collectionData setHidden:NO];
    [btn_addNewItem setHidden:NO];
    
    [self fetchData];
    
    
}
- (IBAction)onSelectOrders:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        contrant_containerTop.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
    [btn_info setSelected:NO];
    [btn_product setSelected:NO];
    [btn_orders setSelected:YES];
    [txt_storeNote setHidden:YES];
    [tbl_data setHidden:NO];
    [collectionData setHidden:YES];
    [btn_addNewItem setHidden:YES];
    
    [self fetchData];
    
    
}
- (IBAction)onNewItem:(id)sender {
    UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
    StoreAddItemViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StoreAddItemViewController"];
    controller.runMode = ITEMEDIT_MODE_ADD;
    [mainNav pushViewController:controller animated:YES];
}

- (IBAction)onEditThumb:(id)sender {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Take a new photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Select from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}


- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    isGallery = YES;
    isCamera = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    isCamera = YES;
    isGallery = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    image = [Util cropedImage:image];
    [img_thumb setImage:image];
    selectedImage = image;
    hasPhoto = YES;
    [self updateUserProfileImage:selectedImage];
}

- (void) updateUserProfileImage:(UIImage*)image
{
    if(image){
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        UIImage *profileImage = [Util getUploadingImageFromImage:image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        me[PARSE_USER_COMPAVATAR] = [PFFile fileWithData:imageData];
        [me saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Edit Profile" message:@"Your profile changed."];
        }];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
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
    
    UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
    ItemDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemDetailViewController"];
    controller.productInfo = productInfo;
    controller.runType = PRODUCTDETAIL_RUN_STORE;
    [mainNav pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return orderArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"OrderTableViewCell";
    OrderTableViewCell *cell = (OrderTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.view_container.layer.cornerRadius = 10.f;
        PFObject * orderInfo = [orderArray objectAtIndex:indexPath.row];
        PFObject * productInto = orderInfo[PARSE_ORDER_PRODUCT];
        PFUser * sender = orderInfo[PARSE_ORDER_SENDER];
        
        cell.lbl_orderIdenty.text = [NSString stringWithFormat:@"Order #%@" ,orderInfo[PARSE_ORDER_IDENTIFY]];
        cell.lbl_placedTime.text = [NSString stringWithFormat:@"Placed on %@", [Util convertDateToString:orderInfo.updatedAt]];
        [Util setImage:cell.img_thumb imgFile:productInto[PARSE_PRODUCT_THUMB]];
        cell.lbl_productTitle.text = productInto[PARSE_PRODUCT_TITLE];
        cell.lbl_deliveredTime.text = [NSString stringWithFormat:@"Delivered %@", [Util convertDateToString:productInto.updatedAt]];
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
