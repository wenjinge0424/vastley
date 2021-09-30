//
//  SignUpMatchPWDViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "SignUpMatchPWDViewController.h"
#import "SignUpUserInfoViewController.h"
#import "SignUpStoreInfoViewController.h"

@interface SignUpMatchPWDViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtRepassword;
@property (weak, nonatomic) IBOutlet UIButton *btnMatch;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

@implementation SignUpMatchPWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnNext.enabled = NO;
    [_txtRepassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
- (IBAction)onCheck:(id)sender {
    if (![self isValid]){
        return;
    }
    if([self.userInfo[PARSE_USER_TYPE] intValue] == 100){
        SignUpUserInfoViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpUserInfoViewController"];
        controller.userInfo = self.userInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }else if([self.userInfo[PARSE_USER_TYPE] intValue] == 200){
        SignUpStoreInfoViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpStoreInfoViewController"];
        controller.userInfo = self.userInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (BOOL) isValid {
    BOOL result = _btnMatch.selected /*&& btnLower.selected && btnUpper.selected && btnNumber.selected */;
    return result;
}
-(void)textFieldDidChange :(UITextField *) textField{
    _btnMatch.selected = [self.userInfo[PARSE_USER_PASSWORD] isEqualToString:_txtRepassword.text];
    _btnNext.enabled = _btnMatch.selected;
}
@end
