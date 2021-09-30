//
//  SignUpStoreInfoViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "SignUpStoreInfoViewController.h"
#import "SignUpTermsViewController.h"
#import <GooglePlaces/GooglePlaces.h>

@interface SignUpStoreInfoViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate>
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
    __weak IBOutlet UITextField *txtStoreName;
}

@end

@implementation SignUpStoreInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtLocation.placeholder = @"Address";
    
    img_thumb.delegate = self;
    img_thumb.layer.borderColor = [UIColor whiteColor].CGColor;
    img_thumb.layer.borderWidth = 1.f;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    GMSPlacesClient * gmsClient = [GMSPlacesClient sharedClient];
    [gmsClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList * likehoodList, NSError * error){
        [SVProgressHUD dismiss];
        if(error){
        }else{
            GMSPlaceLikelihood * likeihood = [likehoodList.likelihoods firstObject];
            GMSPlace * place = likeihood.place;
            NSString *locatedAt = place.formattedAddress;
            txtLocation.text = locatedAt;
            lonLat = [PFGeoPoint geoPointWithLocation:[[CLLocation alloc] initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude]];
        }
    }];
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
- (NSString *) isValid {
    NSString * firstName = [Util trim:txtFirstName.text];
    txtFirstName.text = firstName;
    NSString * lastName = [Util trim:txtLastName.text];
    txtLastName.text = lastName;
    NSString * contactNum = [Util trim:txtContact.text];
    txtContact.text = contactNum;
    NSString * location = txtLocation.text;
    NSString * storename = [Util trim:txtStoreName.text];
    txtStoreName.text = storename;
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
    if(storename.length == 0){
        return @"Please enter your store name.";
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
        self.userInfo[PARSE_USER_FIRSTNAME] = txtFirstName.text;
        self.userInfo[PARSE_USER_LASTSTNAME] = txtLastName.text;
        self.userInfo[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", txtFirstName.text, txtLastName.text];
        self.userInfo[PARSE_USER_CONTACTNUM] = txtContact.text;
        self.userInfo[PARSE_USER_LOCATION] = txtLocation.text;
        self.userInfo[PARSE_USER_GEOPOINT] = lonLat;
        self.userInfo[PARSE_USER_IS_PRIMARY] = [NSNumber numberWithBool:btnChecker.selected];
        self.userInfo[PARSE_USER_COMPANY] = txtStoreName.text;
        
        if (!hasPhoto){
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:@"Yes" actionBlock:^(void) {
                [self gotoNext];
            }];
            [alert addButton:@"Upload Photo" actionBlock:^(void) {
                [self tapCircleImageView];
            }];
            [alert showError:@"Sign Up" subTitle:@"Are you sure you want to proceed without a profile photo?" closeButtonTitle:nil duration:0.0f];
        } else {
            UIImage *profileImage = [Util getUploadingImageFromImage:selectedImage];
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
            self.userInfo[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
            [self gotoNext];
        }
    }
}
- (void) gotoNext
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        [self onBuyProItem];
        
    }];
    [alert addButton:@"No" actionBlock:^(void) {
        self.userInfo[PARSE_USER_VIPMODE] = [NSNumber numberWithBool:NO];
        [self gotoTerms];
    }];
    [alert showError:@"Upgrade VIP" subTitle:@"Upgrade to VIP Premium version?" closeButtonTitle:nil duration:0.0f];
    
}
- (void) didUpdateToProversion
{
    self.userInfo[PARSE_USER_VIPMODE] = [NSNumber numberWithBool:YES];
    self.userInfo[PARSE_USER_PRODATE] = [NSDate date];
    [self gotoTerms];
}
- (void) gotoTerms
{
    SignUpTermsViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpTermsViewController"];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
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
    CLLocationCoordinate2D placePos = place.coordinate;
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
