//
//  ContactTableViewCell.h
//  vastley
//
//  Created by Techsviewer on 8/23/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleImageView.h"
#import "CartItemTableViewCell.h"

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CircleImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_menu;

@end

@interface ContactAcceptTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CircleImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet TwoTagButton *btn_accept;
@property (weak, nonatomic) IBOutlet TwoTagButton *btn_decline;

@end
