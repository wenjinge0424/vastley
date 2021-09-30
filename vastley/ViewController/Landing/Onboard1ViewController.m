//
//  Onboard1ViewController.m
//  vastley
//
//  Created by Techsviewer on 8/14/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "Onboard1ViewController.h"
#import "Onboard2ViewController.h"

@interface Onboard1ViewController ()

@end

@implementation Onboard1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:SYSTEM_KEY_READ_ONBOARD];
    [userDefault synchronize];
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
- (IBAction)onNext:(id)sender {
    Onboard2ViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Onboard2ViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
