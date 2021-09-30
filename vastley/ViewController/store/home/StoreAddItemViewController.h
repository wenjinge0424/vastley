//
//  StoreAddItemViewController.h
//  vastley
//
//  Created by Techsviewer on 8/16/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

#define ITEMEDIT_MODE_ADD       0
#define ITEMEDIT_MODE_EDIT      1

@interface StoreAddItemViewController : BaseViewController
@property (atomic) int runMode;
@property (nonatomic, retain) PFObject * productInfo;
@end
