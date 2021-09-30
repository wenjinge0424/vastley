//
//  UserDeliveryDetailViewController.m
//  vastley
//
//  Created by Techsviewer on 8/23/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserDeliveryDetailViewController.h"
#import <GooglePlaces/GooglePlaces.h>

@interface UserDeliveryDetailViewController ()<GMSAutocompleteViewControllerDelegate>
{
    __weak IBOutlet UIView *view_container;
    
    __weak IBOutlet UITextField *edt_fullName;
    __weak IBOutlet UITextField *edt_address;
    __weak IBOutlet UITextField *edt_phoneNum;
    
    PFUser * me;
    PFGeoPoint *lonLat;
    
    int currentIndex;
}
@end

@implementation UserDeliveryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    view_container.layer.cornerRadius = 10.f;
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    edt_fullName.text = me[PARSE_USER_FULLNAME];
    edt_address.text = me[PARSE_USER_LOCATION];
    edt_phoneNum.text = me[PARSE_USER_CONTACTNUM];
    lonLat = me[PARSE_USER_GEOPOINT];
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
- (IBAction)onAddNewAddress:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}
- (IBAction)pnContinue:(id)sender {
    if(edt_address.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select your complete address."];
    }else{
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
            return;
        }
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        currentIndex = 0;
        [self saveOrder:self.cartitems :currentIndex];
        
    }
}
- (void) saveOrder:(NSMutableArray*)orderArray :(int)atIndex
{
    if(atIndex >= orderArray.count){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Sucess" finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        currentIndex = atIndex;
        PFObject * cartItem = [self.cartitems objectAtIndex:currentIndex];
        PFUser * owner = cartItem[PARSE_CART_OWNER];
        PFObject * product = cartItem[PARSE_CART_PRODUCT];
        PFObject * orderItem = [PFObject objectWithClassName:PARSE_TABLE_ORDER];
        orderItem[PARSE_ORDER_SENDER] = [PFUser currentUser];
        orderItem[PARSE_ORDER_OWNER] = owner;
        orderItem[PARSE_ORDER_PRODUCT] = product;
        orderItem[PARSE_ORDER_IDENTIFY] = [Util randomStringWithLength:8];
        [orderItem saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            [cartItem deleteInBackgroundWithBlock:^(BOOL success, NSError* error){
                PFObject * notificationObj = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                notificationObj[PARSE_NOTIFICATION_SENDER] = me;
                notificationObj[PARSE_NOTIFICATION_RECEIVER] = owner;
                notificationObj[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInt:SYSTEM_NOTIFICATION_TYPE_ORDER];
                [notificationObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                    NSString *fullName = @"";
                    
                    fullName = me[PARSE_USER_FULLNAME];
                    NSString *pushMsg = [NSString stringWithFormat:@"%@ create order for your product.", fullName];
                    NSDictionary *data = @{
                                           @"alert" : pushMsg,
                                           @"badge" : @"Increment",
                                           @"sound" : @"cheering.caf",
                                           @"email" : owner.username,
                                           @"data"  : owner.objectId,
                                           @"type"  : [NSNumber numberWithInt:PUSH_TYPE_COMMENT]
                                           };
                    [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                        if (err) {
                            NSLog(@"Fail APNS: %@", @"send ban push");
                        } else {
                            NSLog(@"Success APNS: %@", @"send ban push");
                        }
                    }];
                    
                    currentIndex = currentIndex+1;
                    [self saveOrder:orderArray :currentIndex];
                }];
            }];
        }];
        
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
    edt_address.text = placeName;
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
