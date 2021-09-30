//
//  MessageRoomViewController.h
//  vastley
//
//  Created by Techsviewer on 8/21/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"


@interface MessageRoomViewController : BaseViewController
@property (strong, nonatomic) PFUser *toUser;
@property (strong, nonatomic) PFObject *room;
@end
