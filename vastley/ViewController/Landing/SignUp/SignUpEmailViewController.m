//
//  SignUpEmailViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "SignUpEmailViewController.h"
#import "SignUpPWDViewController.h"

@interface SignUpEmailViewController ()
{
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_valid;
@property (weak, nonatomic) IBOutlet UIButton *btn_noUse;
@property (weak, nonatomic) IBOutlet UIButton *btn_next;
@end

@implementation SignUpEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btn_next.enabled = NO;
    [_edt_email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [dataArray addObject:owner.username];
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
- (IBAction)onCheck:(id)sender {
    if (![self isValid]){
        return;
    }
    self.userInfo[PARSE_USER_EMAIL] = _edt_email.text;
    self.userInfo[PARSE_USER_IS_BANNED] = [NSNumber numberWithBool:NO];
    self.userInfo.username = _edt_email.text;
    
    SignUpPWDViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpPWDViewController"];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) isValid {
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    if (email.length == 0){
        return NO;
    }
    if (![email isEmail]){
        return NO;
    }
    return YES;
}
-(void)textFieldDidChange :(UITextField *) textField{
    _edt_email.text = [Util trim:_edt_email.text.lowercaseString];
    NSString *email = _edt_email.text;
    _btn_valid.selected = [email isEmail];
    if (![email isEmail]){
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
        return;
    }
    if ([email containsString:@".."]){
        _btn_valid.selected = NO;
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
        return;
    }
    if ([dataArray containsObject:email]){
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
    } else if ([email isEmail]){
        _btn_noUse.selected = YES;
        _btn_next.enabled = YES;
    }
}

@end
