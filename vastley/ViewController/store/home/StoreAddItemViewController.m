//
//  StoreAddItemViewController.m
//  vastley
//
//  Created by Techsviewer on 8/16/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "StoreAddItemViewController.h"
#import "SelectImageCollectionViewCell.h"

@interface StoreAddItemViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    __weak IBOutlet CircleImageView *img_thumb;
    __weak IBOutlet UITextField *edt_name;
    __weak IBOutlet UITextField *edt_price;
    __weak IBOutlet UITextView *txt_description;
    __weak IBOutlet UITextView *txt_keyword;
    
    UIImage * selectedImage;
    PFUser * me;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    NSMutableArray * mediaThumbArray;
    
    __weak IBOutlet UILabel *lbl_title;
    __weak IBOutlet UICollectionView *img_collection;
}
@end

@implementation StoreAddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mediaThumbArray = [NSMutableArray new];
    
    me = [PFUser currentUser];
    txt_description.placeholder = @"Description";
    txt_keyword.placeholder = @"Keywords (separate by commas)";
    img_thumb.layer.borderWidth = 1.f;
    img_thumb.layer.borderColor = [UIColor whiteColor].CGColor;
    img_thumb.delegate = self;
    
    BOOL isProversion = [me[PARSE_USER_VIPMODE] boolValue];
    if(isProversion){
        [img_collection setHidden:NO];
    }else{
        [img_collection setHidden:YES];
    }
    
    if(self.runMode == ITEMEDIT_MODE_EDIT){
        [lbl_title setText:@"Edit Item"];
        [Util setImage:img_thumb imgFile:self.productInfo[PARSE_PRODUCT_THUMB]];
        edt_name.text = self.productInfo[PARSE_PRODUCT_TITLE];
        edt_price.text = self.productInfo[PARSE_PRODUCT_PRICE];
        txt_description.text = self.productInfo[PARSE_PRODUCT_DESCRIPTION];
        txt_keyword.text = self.productInfo[PARSE_PRODUCT_KEYWORD];
        
        if(isProversion){
            mediaThumbArray = self.productInfo[PARSE_PRODUCT_IMAGES];
            if(mediaThumbArray && mediaThumbArray.count > 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    img_collection.delegate = self;
                    img_collection.dataSource = self;
                    [img_collection reloadData];
                });
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSave:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    NSString * itemName = [Util trim:edt_name.text];
    edt_name.text = itemName;
    NSString * price = [Util trim:edt_price.text];
    edt_price.text = price;
    NSString * description = [Util trim:txt_description.text];
    NSString * keyword = [Util trim:txt_keyword.text];
    NSArray * keywordArray = [keyword componentsSeparatedByString:@","];
    BOOL isProversion = [me[PARSE_USER_VIPMODE] boolValue];
    if(itemName.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input Item name."];
    }else if(price.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input Item price."];
    }else if(description.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input Item description."];
    }else if(keyword.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input Item keywords."];
    }else if(!hasPhoto){
        [Util showAlertTitle:self title:@"Error" message:@"Please upload Item image."];
    }else if(!isProversion && keywordArray && keywordArray.count > 1){
        [Util showAlertTitle:self title:@"Error" message:@"You can add only one keyword."];
    }else{
        PFObject * product = [PFObject objectWithClassName:PARSE_TABLE_PRODUCT];
        if(self.runMode == ITEMEDIT_MODE_EDIT){
            product = self.productInfo;
        }
        product[PARSE_PRODUCT_OWNER] = [PFUser currentUser];
        product[PARSE_PRODUCT_TITLE] = itemName;
        product[PARSE_PRODUCT_DESCRIPTION] = description;
        product[PARSE_PRODUCT_PRICE] = price;
        product[PARSE_PRODUCT_KEYWORD] = keyword;
        product[PARSE_PRODUCT_SELLMODE] = me[PARSE_USER_VIPMODE];
        product[PARSE_PRODUCT_LIKES] = [NSMutableArray new];
        product[PARSE_PRODUCT_LOCATION] = me[PARSE_USER_GEOPOINT];
        product[PARSE_PRODUCT_COMMENT_COUNT] = [NSNumber numberWithInt:0];
        if(selectedImage){
            UIImage *profileImage = [Util getUploadingImageFromImage:selectedImage];
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
            product[PARSE_PRODUCT_THUMB] = [PFFile fileWithData:imageData];
        }
        NSMutableArray * postThumbs = [NSMutableArray new];
        for(NSObject * imgObj in mediaThumbArray){
            if([imgObj isKindOfClass:[UIImage class]]){
                NSData *imageData = UIImageJPEGRepresentation(imgObj, 0.8);
                PFFile * file = [PFFile fileWithName:[NSString stringWithFormat:@"%lupost.png", (unsigned long)[mediaThumbArray indexOfObject:imgObj]] data:imageData];
                [postThumbs addObject:file];
            }else if([imgObj isKindOfClass:[PFFile class]]){
                [postThumbs addObject:imgObj];
            }
        }
        product[PARSE_PRODUCT_IMAGES] = postThumbs;
        
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [product saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [mediaThumbArray count];
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    return CGSizeMake(100, 100);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectImageCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        NSObject * imageThumb = [mediaThumbArray objectAtIndex:indexPath.row];
        if([imageThumb isKindOfClass:[UIImage class]]){
            [cell.img_thumb setImage:(UIImage*)imageThumb];
        }else if([imageThumb isKindOfClass:[PFFile class]]){
            [Util setImage:cell.img_thumb imgFile:(PFFile*)imageThumb];
        }
        cell.btn_delete.tag = indexPath.row;
        [cell.btn_delete addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
- (NSMutableArray*) removeObjectAtIndex:(int)index :(NSMutableArray*)array
{
    NSMutableArray * newArray = [NSMutableArray new];
    for(int i=0;i<array.count;i++){
        if(i != index)
            [newArray addObject:[array objectAtIndex:i]];
    }
    return newArray;
}
- (void) onDelete:(UIButton*) button
{
    int index = (int)button.tag;
    mediaThumbArray = [self removeObjectAtIndex:index :mediaThumbArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        img_collection.delegate = self;
        img_collection.dataSource = self;
        [img_collection reloadData];
    });
}




- (void) tapCircleImageView {
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
    BOOL isProversion = [me[PARSE_USER_VIPMODE] boolValue];
    if(!isProversion){
        [img_thumb setImage:image];
        selectedImage = image;
        mediaThumbArray = [NSMutableArray new];
        [mediaThumbArray addObject:image];
    }else{
        if(!mediaThumbArray) mediaThumbArray = [NSMutableArray new];
        [mediaThumbArray addObject:image];
        if(mediaThumbArray.count == 1){
            [img_thumb setImage:image];
            selectedImage = image;
        }
        if(mediaThumbArray.count > 5){
            [Util showAlertTitle:self title:@"Error" message:@"You can upload up to 5 images."];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            img_collection.delegate = self;
            img_collection.dataSource = self;
            [img_collection reloadData];
        });
    }
    hasPhoto = YES;
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
@end
