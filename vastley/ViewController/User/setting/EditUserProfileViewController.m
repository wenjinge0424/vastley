//
//  EditUserProfileViewController.m
//  vastley
//
//  Created by Techsviewer on 8/24/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "EditUserProfileViewController.h"
#import <GooglePlaces/GooglePlaces.h>

@interface EditUserProfileViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate>
{
    UIImage * selectedImage;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
    
    NSString *city;
    NSString *zipCode;
    PFGeoPoint *lonLat;
    
    __weak IBOutlet CircleImageView *img_thumb;
    __weak IBOutlet UITextField *txtFirstName;
    __weak IBOutlet UITextField *txtLastName;
    __weak IBOutlet UITextField *txtContact;
    __weak IBOutlet UITextView *txtLocation;
    __weak IBOutlet UIButton *btnChecker;
    
    PFUser * me;
}
@end

@implementation EditUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtLocation.placeholder = @"Address";
    
    img_thumb.delegate = self;
    img_thumb.layer.borderColor = [UIColor whiteColor].CGColor;
    img_thumb.layer.borderWidth = 1.f;
    
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    [self fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) fetchData
{
    [Util setImage:img_thumb imgFile:me[PARSE_USER_AVATAR]];
    txtFirstName.text = me[PARSE_USER_FULLNAME];
    txtLastName.text = me[PARSE_USER_LASTSTNAME];
    txtContact.text = me[PARSE_USER_CONTACTNUM];
    txtLocation.text = me[PARSE_USER_LOCATION];
    BOOL isPrimary = [me[PARSE_USER_IS_PRIMARY] boolValue];
    lonLat = me[PARSE_USER_GEOPOINT];
    btnChecker.selected = isPrimary;
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
- (NSString *) isValid {
    NSString * firstName = [Util trim:txtFirstName.text];
    txtFirstName.text = firstName;
    NSString * lastName = [Util trim:txtLastName.text];
    txtLastName.text = lastName;
    NSString * contactNum = [Util trim:txtContact.text];
    txtContact.text = contactNum;
    NSString * location = txtLocation.text;
    if(firstName.length == 0){
        return @"Please enter your first name.";
    }
    if(lastName.length == 0){
        return @"Please enter your last name.";
    }
    if(contactNum.length == 0){
        return @"Please enter your contact number.";
    }
    if(location.length == 0){
        return @"Please enter your location.";
    }
    return @"";
}
- (IBAction)onCheck:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    NSString * error = [self isValid];
    if(error.length > 0){
        [Util showAlertTitle:self title:@"Error" message:error];
    }else{
        me[PARSE_USER_FIRSTNAME] = txtFirstName.text;
        me[PARSE_USER_LASTSTNAME] = txtLastName.text;
        me[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", txtFirstName.text, txtLastName.text];
        me[PARSE_USER_CONTACTNUM] = txtContact.text;
        me[PARSE_USER_LOCATION] = txtLocation.text;
        me[PARSE_USER_GEOPOINT] = lonLat;
        me[PARSE_USER_IS_PRIMARY] = [NSNumber numberWithBool:btnChecker.selected];
        
        if (!hasPhoto){
        } else {
            UIImage *profileImage = [Util getUploadingImageFromImage:selectedImage];
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
            me[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
        }
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [me saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Success" message:@"Profile changed." finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}
- (IBAction)onSelectPrimaru:(id)sender {
    btnChecker.selected = !btnChecker.selected;
}

- (IBAction)onSelectLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
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
    [img_thumb setImage:image];
    selectedImage = image;
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

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    NSString *placeName = place.name;
    txtLocation.text = placeName;
    lonLat = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
