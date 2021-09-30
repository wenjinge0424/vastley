//
//  BaseViewController.m
//  vastley
//
//  Created by Techsviewer on 8/14/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"
#import "IAPChecker.h"

@interface BaseViewController ()<IAPCheckerDelegate>
{
    IAPChecker * cheker;
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (void) onBuyProItem
{
    cheker = [IAPChecker new];
    cheker.delegate = self;
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [cheker checkIAP];
}
- (void) didUpdateToProversion
{
    
}
- (void) IAPCheckerDelegate_completeSuccess
{
    [SVProgressHUD dismiss];
    [self didUpdateToProversion];
}
- (void) IAPCheckerDelegate_completeFail:(NSString *)errorMsg
{
    [SVProgressHUD dismiss];
    if(errorMsg.length > 0){
        [Util showAlertTitle:self title:@"Error" message:errorMsg];
    }
}
@end
