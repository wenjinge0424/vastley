//
//  SignUpOptViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "SignUpOptViewController.h"
#import "SignUpEmailViewController.h"

@interface SignUpOptViewController ()
{
    PFUser * userInfo;
}
@end

@implementation SignUpOptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userInfo = [PFUser user];
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
- (IBAction)onSelectUser:(id)sender {
    userInfo[PARSE_USER_TYPE] = [NSNumber numberWithInt:100];
    
    SignUpEmailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpEmailViewController"];
    controller.userInfo = userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSelectStore:(id)sender {
    userInfo[PARSE_USER_TYPE] = [NSNumber numberWithInt:200];
    SignUpEmailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpEmailViewController"];
    controller.userInfo = userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
