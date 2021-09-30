//
//  SignUpPWDViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "SignUpPWDViewController.h"
#import "SignUpMatchPWDViewController.h"

@interface SignUpPWDViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnLength;
@property (weak, nonatomic) IBOutlet UIButton *btnNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnLower;
@property (weak, nonatomic) IBOutlet UIButton *btnUpper;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

@implementation SignUpPWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnNext.enabled = NO;
    [_txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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
    self.userInfo[PARSE_USER_PASSWORD] = _txtPassword.text;
    self.userInfo[PARSE_USER_PREVIEWPWD] = _txtPassword.text;
    
    SignUpMatchPWDViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpMatchPWDViewController"];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) isValid {
    BOOL result = _btnLength.selected /*&& btnLower.selected && btnUpper.selected && btnNumber.selected */;
    return result;
}
-(void)textFieldDidChange :(UITextField *) textField{
    NSString *password = _txtPassword.text;
    _btnLength.selected = (password.length >= 6);
    _btnLower.selected = [Util isContainsLowerCase:password];
    _btnUpper.selected = [Util isContainsUpperCase:password];
    _btnNumber.selected = [Util isContainsNumber:password];
    _btnNext.enabled = [self isValid];
}
@end
