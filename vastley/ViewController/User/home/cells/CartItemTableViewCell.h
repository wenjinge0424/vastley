//
//  CartItemTableViewCell.h
//  vastley
//
//  Created by Techsviewer on 8/23/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoTagButton : UIButton
@property (atomic) int secondTag;
@end

@interface SubCartItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UIButton *btn_quality;
@property (weak, nonatomic) IBOutlet UILabel *lbl_price;
@property (weak, nonatomic) IBOutlet TwoTagButton *btn_delete;

@end

@interface CartItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_soldBy;
@property (weak, nonatomic) IBOutlet UILabel *lbl_coshoping;
@property (weak, nonatomic) IBOutlet UILabel *lbl_total;
@property (weak, nonatomic) IBOutlet UILabel *lbl_delvery;

@property (weak, nonatomic) IBOutlet UIButton *btn_order;
@property (weak, nonatomic) IBOutlet UIView *view_container;
@property (weak, nonatomic) IBOutlet UITableView *dataTable;
@end
