//
//  NotificationTableViewCell.h
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleImageView.h"

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CircleImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@end
