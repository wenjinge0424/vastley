//
//  UserTabViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserTabViewController.h"



@interface UserTabViewController ()

@end
static UserTabViewController * UserTabinstance;
@implementation UserTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UserTabinstance = self;
    self.tabBar.hidden = YES;
    self.moreNavigationController.navigationBar.hidden = YES;
}
+ (UserTabViewController*) getInstance
{
    return UserTabinstance;
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

@end
