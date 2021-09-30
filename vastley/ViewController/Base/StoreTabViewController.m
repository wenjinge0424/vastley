//
//  StoreTabViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "StoreTabViewController.h"

@interface StoreTabViewController ()

@end
static StoreTabViewController * StoreTabinstance;
@implementation StoreTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    StoreTabinstance = self;
    self.tabBar.hidden = YES;
    self.moreNavigationController.navigationBar.hidden = YES;
}
+ (StoreTabViewController*) getInstance
{
    return StoreTabinstance;
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
