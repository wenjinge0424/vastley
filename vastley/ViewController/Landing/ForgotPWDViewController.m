//
//  ForgotPWDViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "ForgotPWDViewController.h"
#import "SignUpOptViewController.h"

@interface ForgotPWDViewController ()<UITextFieldDelegate>
{
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_checker;

@end

@implementation ForgotPWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_edt_email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    dataArray = [[NSMutableArray alloc] init];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [dataArray addObject:user[PARSE_USER_NAME]];
            }
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
- (BOOL) isValid {
    [self.view endEditing:YES];
    NSString *errMsg = @"";
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    if (![email isEmail] && email.length > 0){
        errMsg = [errMsg stringByAppendingString:@"Please enter valid email."];
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        return NO;
    }
    if ([email containsString:@".."] && email.length > 0){
        errMsg = [errMsg stringByAppendingString:@"Please enter valid email."];
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        return NO;
    }
    if (email.length == 0){
        errMsg = [errMsg stringByAppendingString:@"Please enter your email."];
        [Util showAlertTitle:self title:@"Error" message:errMsg];
        return NO;
    }
    return YES;
}

- (IBAction)onCheck:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    if (![self isValid]){
        return;
    }
    [_edt_email resignFirstResponder];
    NSString *email = _edt_email.text;
    email = [Util trim:email];
    if (!_btn_checker.selected){
        NSString *msg = @"Email entered is not registered. Create an account now?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Not Now" actionBlock:^(void) {
        }];
        [alert addButton:@"Sign Up" actionBlock:^(void) {
            SignUpOptViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpOptViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }];
        [alert showError:@"Reset Password" subTitle:msg closeButtonTitle:nil duration:0.0f];
    }else{
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [Util showAlertTitle:self
                               title:@"Success"
                             message: @"We have sent a password reset link to your email address. Please check your email."
                              finish:^(void) {
                                  [self onBack:nil];
                              }];
            } else {
                if (![Util isConnectableInternet]){
                    if ([SVProgressHUD isVisible]){
                        [SVProgressHUD dismiss];
                    }
                    [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
                    return;
                }
                NSString *errorString = [error localizedDescription];
                [Util showAlertTitle:self
                               title:@"Error" message:errorString
                              finish:^(void) {
                              }];
            }
        }];
    }
}

-(void)textFieldDidChange :(UITextField *) textField{
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    if ([Util stringContainsInArray:email :dataArray])
        _btn_checker.selected = YES;
    else
        _btn_checker.selected = NO;
}

@end
