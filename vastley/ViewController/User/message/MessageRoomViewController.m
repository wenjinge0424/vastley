//
//  MessageRoomViewController.m
//  vastley
//
//  Created by Techsviewer on 8/21/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "MessageRoomViewController.h"
#import "ChatDetailsViewController.h"

@interface MessageRoomViewController ()

@end

@implementation MessageRoomViewController

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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatDetailsViewController *vc = (ChatDetailsViewController *) segue.destinationViewController;
        vc.toUser = self.toUser;
        vc.room = self.room;
    }
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
