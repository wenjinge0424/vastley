//
//  ProductCollectionViewCell.h
//  vastley
//
//  Created by Techsviewer on 8/16/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UILabel *lbl_price;

@end
