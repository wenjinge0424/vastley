//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"
/* ***************************************************************************/
/* ***************************** Paypal config ********************************/
/* ***************************************************************************/


/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/

#define STRIPE_KEY                                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                                          @"charges"
#define STRIPE_CUSTOMERS                                        @"customers"
#define STRIPE_TOKENS                                           @"tokens"
#define STRIPE_ACCOUNTS                                         @"accounts"
#define STRIPE_CONNECT_URL                                      @"https://stripe.smarter.brainyapps.tk"

#define NOTIFICATION_ACTIVE                                     @"NOTIFICATION_ACTIVE"
#define NOTIFICATION_BACKGROUND                                 @"NOTIFICATION_BACKGROUND"
#define PUSH_NOTIFICATION_TYPE                                  @"type"

#define SYSTEM_KEY_READ_ONBOARD                                 @"read_onboard"

#define USER_PUBLIC_STATE_PUBLIC                                0
#define USER_PUBLIC_STATE_FRIEND                                1


/* Remote Notification Type values */
#define REMOTE_NF_TYPE_NEW_ITEM                                 @"New_Iwant_Item"
#define REMOTE_NF_TYPE_NEW_CATEGORY                             @"New_Category"
#define REMOTE_NF_TYPE_FRIEND_INVITE                            @"Friend_Invite"
#define REMOTE_NF_TYPE_INVITE_ACCEPT                            @"Invite_Result_Accept"
#define REMOTE_NF_TYPE_INVITE_REJECT                            @"Invite_Result_Reject"
#define REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY                     @"Click_Empty_Category"
#define kChatReceiveNotification                                @"ChatReceiveNotification"
#define kChatReceiveNotificationUsers                           @"ChatReceiveNotificationUsers"
#define kNewAdPosted                                            @"kNewAdPosted"
#define kReceivedFollowRequest                                  @"kReceivedFollowRequest"
#define kHomeTapped                                             @"kHomeTapped"

enum {
    CHAT_TYPE_MESSAGE = 100,
    CHAT_TYPE_IMAGE = 200,
    CHAT_TYPE_VIDEO = 300
};

enum {
    REPORT_TYPE_POST = 100,
    REPORT_TYPE_USER = 200,
    REPORT_TYPE_AD = 300
};

enum {
    PUSH_TYPE_CHAT = 1,
    PUSH_TYPE_BAN,
    PUSH_TYPE_NEW_POST,
    PUSH_TYPE_DEL_POST,
    PUSH_TYPE_FOLLOW_REQUEST,
    PUSH_TYPE_FOLLOW_ACCEPTED,
    PUSH_TYPE_UNFOLLOW,
    PUSH_TYPE_LIKE,
    PUSH_TYPE_COMMENT,
    PUSH_TYPE_OTHER
};


#define MAIN_COLOR                                              [UIColor colorWithRed:0/255.f green:202/255.f blue:37/255.f alpha:1.f]
#define MAIN_BORDER_COLOR                                       [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR                                      [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR                                      [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR                                       [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR                                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR                                        [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR                                       [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR                                        [UIColor colorWithRed:204/255.f green:227/255.f blue:244/255.f alpha:1.f]

/* Page Notifcation */

/* Refresh Notifcation */

/* Remote Notification Type values */

/* Smarter */
#define NOTIFICATION_STATE_PENDING                              0
#define NOTIFICATION_STATE_ACCEPT                               1
#define NOTIFICATION_STATE_REJECT                               2



/* Spin Notification Data */
#define USER_TYPE                                               [AppStateManager sharedInstance].user_type


/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"

/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define PARSE_USER_FULLNAME                                     @"fullName"
#define PARSE_USER_COMPANY                                     @"compName"
#define PARSE_USER_VIPMODE                                     @"vip"
#define PARSE_USER_PRODATE                                     @"prodate"
#define PARSE_USER_FIRSTNAME                                    @"firstName"
#define PARSE_USER_LASTSTNAME                                   @"lastName"
#define PARSE_USER_NAME                                         @"username"
#define PARSE_USER_CONTACTNUM                                         @"contactNum"
#define PARSE_USER_GENDER                                         @"gender"
#define PARSE_USER_AGE                                         @"age"
#define PARSE_USER_EMAIL                                        @"email"
#define PARSE_USER_PASSWORD                                     @"password"
#define PARSE_USER_LOCATION                                     @"location"
#define PARSE_USER_GEOPOINT                                     @"geoPoint"
#define PARSE_USER_TYPE                                         @"userType"
#define PARSE_USER_AVATAR                                       @"avatar"
#define PARSE_USER_COMPAVATAR                                   @"compAvatar"
#define PARSE_USER_FINGERPHOTO                                  @"fingerPhoto"
#define PARSE_USER_FACEBOOKID                                   @"facebookid"
#define PARSE_USER_GOOGLEID                                     @"googleid"
#define PARSE_USER_BUSINESS_ACCOUNT_ID                          @"accountId"
#define PARSE_USER_IS_BANNED                                    @"isBanned"
#define PARSE_USER_IS_PRIMARY                                    @"isPrimary"
#define PARSE_USER_PARENT                                       @"parent"
#define PARSE_USER_TEACHER_LIST                                 @"teacherList"
#define PARSE_USER_STUDENT_LIST                                 @"studentList"
#define PARSE_USER_ACCOUNT_ID                                   @"accountId"
#define PARSE_USER_FRINEDS                                      @"friends"
#define PARSE_USER_PRODUCTS                                     @"products"
#define PARSE_USER_PREVIEWPWD                                   @"previewPassword"
#define PARSE_USER_POSTTYPE                                   @"postType"
#define PARSE_USER_INTEREST                                   @"interest"


/* Post Table */
#define PARSE_TABLE_POST                                        @"Posts"
#define PARSE_POST_OWNER                                        @"owner"
#define PARSE_POST_IMAGE                                        @"image"
#define PARSE_POST_CATEGORY                                     @"category"
#define PARSE_POST_TITLE                                        @"title"
#define PARSE_POST_TITLE_COLOR                                  @"titleColor"
#define PARSE_POST_LIKES                                        @"liked"
#define PARSE_POST_BOOKMARKED                                        @"bookmarked"
#define PARSE_POST_IS_VIDEO                                     @"isVideo"
#define PARSE_POST_VIDEO                                        @"video"
#define PARSE_POST_DESCRIPTION                                  @"description"
#define PARSE_POST_COMMENT_COUNT                                @"commentCount"
#define PARSE_POST_IS_PRIVATE                                   @"isPrivate"
#define PARSE_POST_THUMBS                                   @"thumbs"
#define PARSE_POST_DATAS                                   @"datas"
#define PARSE_POST_VIDEOINDEXS                                   @"video_indexs"
#define PARSE_POST_ISVIDEOS                                   @"isVideos"
/* AD Table */
#define PARSE_TABLE_AD                                        @"Ads"
#define PARSE_AD_OWNER                                        @"owner"
#define PARSE_AD_IMAGE                                        @"image"
#define PARSE_AD_TITLE                                        @"title"
#define PARSE_AD_IS_VIDEO                                     @"isVideo"
#define PARSE_AD_VIDEO                                        @"video"
#define PARSE_AD_DESCRIPTION                                  @"description"
#define PARSE_AD_PRICE                                        @"price"

/*Notification Table*/
#define PARSE_TABLE_NOTIFICATION                                        @"Notification"
#define PARSE_NOTIFICATION_SENDER                                       @"sender"
#define PARSE_NOTIFICATION_RECEIVER                                     @"receiver"
#define PARSE_NOTIFICATION_TYPE                                         @"type"

#define SYSTEM_NOTIFICATION_TYPE_ACCEPT                                             0
#define SYSTEM_NOTIFICATION_TYPE_LIKE                                               1
#define SYSTEM_NOTIFICATION_TYPE_COMMENT                                            2
#define SYSTEM_NOTIFICATION_TYPE_ORDER                                              3
#define SYSTEM_NOTIFICATION_TYPE_FRIEND                                             4
#define SYSTEM_NOTIFICATION_TYPE_FOLLOW                                             5
#define SYSTEM_NOTIFICATION_TYPE_ALLOW_FRIEND                                       6
#define SYSTEM_NOTIFICATION_TYPE_ALLOW_FOLLOW                                       7
#define SYSTEM_NOTIFICATION_TYPE_SHAREPRODUCT                                       8


/* Comment Table */
#define PARSE_TABLE_COMMENT                                     @"Comment"
#define PARSE_COMMENT_USER                                      @"user"
#define PARSE_COMMENT_POST                                      @"post"
#define PARSE_COMMENT_TEXT                                      @"comment"


/*Friends table*/
#define PARSE_TABLE_FRIENDS                                     @"Friends"
#define PARSE_FRIENDS_FROM                                      @"fromUser"
#define PARSE_FRIENDS_TO                                        @"toUser"
#define PARSE_FRIENDS_ACTIVE                                   @"isActive"

/*Follow table*/
#define PARSE_TABLE_FOLLOW                                      @"Follow"
#define PARSE_FOLLOW_FROM                                       @"fromUser"
#define PARSE_FOLLOW_TO                                         @"toUser"
#define PARSE_FOLLOW_ACTIVE                                     @"isActive"

/* Chat Room */
#define PARSE_TABLE_CHAT_ROOM                                   @"ChatRoom"
#define PARSE_ROOM_SENDER                                       @"sender"
#define PARSE_ROOM_RECEIVER                                     @"receiver"
#define PARSE_ROOM_LAST_MESSAGE                                 @"lastMsg"
#define PARSE_ROOM_ENABLED                                      @"isAvailable"
#define PARSE_ROOM_IS_READ                                      @"isRead"
#define PARSE_ROOM_LAST_SENDER                                  @"message_sender"

/* Chat History */
#define PARSE_TABLE_CHAT_HISTORY                                @"ChatHistory"
#define PARSE_HISTORY_ROOM                                      @"room"
#define PARSE_HISTORY_SENDER                                    @"sender"
#define PARSE_HISTORY_RECEIVER                                  @"receiver"
#define PARSE_HISTORY_TYPE                                      @"type"
#define PARSE_HISTORY_MESSAGE                                   @"message"
#define PARSE_HISTORY_IMAGE                                     @"image"
#define PARSE_HISTORY_VIDEO                                     @"video"

/* Report Table */
#define PARSE_TABLE_REPORT                                      @"Report"
#define PARSE_REPORT_POST                                       @"post"
#define PARSE_REPORT_AD                                       @"ad"
#define PARSE_REPORT_OWNER                                      @"owner"
#define PARSE_REPORT_REPORTER                                   @"reporter"
#define PARSE_REPORT_TYPE                                       @"type"
#define PARSE_REPORT_DESCRIPTION                                @"description"

/*Product Table*/
#define PARSE_TABLE_PRODUCT                                     @"Product"
#define PARSE_PRODUCT_TITLE                                     @"title"
#define PARSE_PRODUCT_PRICE                                     @"price"
#define PARSE_PRODUCT_DESCRIPTION                               @"description"
#define PARSE_PRODUCT_KEYWORD                               @"keyword"
#define PARSE_PRODUCT_THUMB                               @"thumb"
#define PARSE_PRODUCT_IMAGES                               @"images"
#define PARSE_PRODUCT_OWNER                               @"owner"
#define PARSE_PRODUCT_SELLMODE                               @"sellMode"
#define PARSE_PRODUCT_LIKES                               @"likes"
#define PARSE_PRODUCT_COMMENT_COUNT                                @"commentCount"
#define PARSE_PRODUCT_LOCATION                               @"location"

/*Cart Table*/
#define PARSE_TABLE_CART                                     @"Cart"
#define PARSE_CART_SENDER                                    @"sender"
#define PARSE_CART_OWNER                                     @"owner"
#define PARSE_CART_PRODUCT                                   @"product"
#define PARSE_CART_ISSHARED                                   @"isShared"
#define PARSE_CART_SHAREDUSER                                   @"sharedUser"

/*Cart Table*/
#define PARSE_TABLE_ORDER                                     @"Order"
#define PARSE_ORDER_IDENTIFY                                   @"identify"
#define PARSE_ORDER_SENDER                                    @"sender"
#define PARSE_ORDER_OWNER                                     @"owner"
#define PARSE_ORDER_PRODUCT                                   @"product"
#define PARSE_ORDER_PRICE                                     @"price"

/*Shared Product*/
#define PARSE_TABLE_SHARE                                   @"SharedProduct"
#define PARSE_SHARE_SENDER                                   @"sender"
#define PARSE_SHARE_RECEIVER                                   @"receiver"
#define PARSE_SHARE_PRODUCT                                   @"product"
