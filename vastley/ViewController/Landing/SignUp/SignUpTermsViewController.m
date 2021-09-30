//
//  SignUpTermsViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "SignUpTermsViewController.h"
#import "UserHomeViewController.h"
#import "StoreHomeViewController.h"

@interface SignUpTermsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SignUpTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
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
- (IBAction)onAccept:(id)sender {
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [self.userInfo signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            
            [Util setLoginUserName:self.userInfo.username password:self.userInfo.password];
            int userType = [self.userInfo[PARSE_USER_TYPE] intValue];
            if(userType == 100){
                UserHomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserHomeViewController"];
                [self.navigationController pushViewController:controller animated:YES];
            }else if(userType == 200){
                StoreHomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StoreHomeViewController"];
                [self.navigationController pushViewController:controller animated:YES];
            }
        } else {
            NSString *message = [error localizedDescription];
            if ([message containsString:@"already"]){
                message = @"Account already exists for this email.";
            }
            [Util showAlertTitle:self title:@"Error" message:message];
        }
    }];
}
@end
