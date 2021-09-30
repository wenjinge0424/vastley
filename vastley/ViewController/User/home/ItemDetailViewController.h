//
//  ItemDetailViewController.h
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

#define PRODUCTDETAIL_RUN_STORE     0
#define PRODUCTDETAIL_RUN_USER      1

@interface ItemDetailViewController : BaseViewController
@property (nonatomic, retain) PFObject * productInfo;
@property (atomic) int runType;
@end
