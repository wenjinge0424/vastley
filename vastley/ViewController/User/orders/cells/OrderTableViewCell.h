//
//  OrderTableViewCell.h
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view_container;
@property (weak, nonatomic) IBOutlet UILabel *lbl_orderIdenty;
@property (weak, nonatomic) IBOutlet UILabel *lbl_placedTime;
@property (weak, nonatomic) IBOutlet UIButton *btn_menu;
@property (weak, nonatomic) IBOutlet UIImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_productTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_deliveredTime;
@property (weak, nonatomic) IBOutlet UILabel *lbl_quantity;
@property (weak, nonatomic) IBOutlet UIButton *btn_deliverd;
@property (weak, nonatomic) IBOutlet UIButton *btn_share;

@end
