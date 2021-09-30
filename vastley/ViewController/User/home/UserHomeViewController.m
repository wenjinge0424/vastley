//
//  UserHomeViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "UserHomeViewController.h"
#import "TitleTableViewCell.h"
#import "UserTabViewController.h"
#import "LoginViewController.h"
#import "ItemDetailViewController.h"
#import "UserCartViewController.h"

@interface UserHomeViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    __weak IBOutlet CircleImageView *img_userThumb;
    __weak IBOutlet UILabel *lbl_userName;
    
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *actionView;
    __weak IBOutlet NSLayoutConstraint *constant_tailing;
    __weak IBOutlet NSLayoutConstraint *contant_leading;
    __weak IBOutlet UIView *view_search;
    __weak IBOutlet UITableView *tbl_search;
    __weak IBOutlet UITextField *edt_search;
    
    NSMutableArray * products;
    NSString * searchString;
    
    PFUser * me;
}
@end
static UserHomeViewController * UserHomeinstance;
@implementation UserHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UserHomeinstance = self;
    [actionView setHidden:YES];
    [view_search setHidden:YES];
    
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    lbl_userName.text = [NSString stringWithFormat:@"Hi, %@", me[PARSE_USER_FULLNAME]];
    [Util setImage:img_userThumb imgFile:me[PARSE_USER_AVATAR]];
    
    searchString = @"";
    edt_search.delegate = self;
}
+ (id) getInstance
{
    return UserHomeinstance;
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
- (IBAction)onMenu:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        contant_leading.constant = 250;
        constant_tailing.constant = -250;
        [self.view layoutIfNeeded];
        [actionView setHidden:NO];
    }];
}
- (IBAction)onSearch:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [view_search setHidden:NO];
    } completion:^(BOOL finished){
        [self fetchSearch];
    }];
}
- (IBAction)onCancelSearch:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [view_search setHidden:YES];
    }];
}
- (IBAction)onCart:(id)sender {
    UserCartViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserCartViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onShowRightView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        contant_leading.constant = 0;
        constant_tailing.constant = 0;
        [self.view layoutIfNeeded];
        [actionView setHidden:YES];
    }];
}
- (IBAction)onGotoItems:(id)sender {
    UserTabViewController * tabCtr = [UserTabViewController getInstance];
    [tabCtr setSelectedIndex:0];
    [self onShowRightView:nil];
}
- (IBAction)onGotoProfile:(id)sender {
    UserTabViewController * tabCtr = [UserTabViewController getInstance];
    [tabCtr setSelectedIndex:1];
    [self onShowRightView:nil];
}
- (IBAction)onGotoMyOrder:(id)sender {
    UserTabViewController * tabCtr = [UserTabViewController getInstance];
    [tabCtr setSelectedIndex:2];
    [self onShowRightView:nil];
}
- (IBAction)onGotoNotification:(id)sender {
    UserTabViewController * tabCtr = [UserTabViewController getInstance];
    [tabCtr setSelectedIndex:3];
    [self onShowRightView:nil];
}
- (IBAction)onGotoMessage:(id)sender {
    UserTabViewController * tabCtr = [UserTabViewController getInstance];
    [tabCtr setSelectedIndex:4];
    [self onShowRightView:nil];
}
- (IBAction)onGotoSetting:(id)sender {
    UserTabViewController * tabCtr = [UserTabViewController getInstance];
    [tabCtr setSelectedIndex:5];
    [self onShowRightView:nil];
}
- (IBAction)onLogOut:(id)sender {
    [SVProgressHUD showWithStatus:@"Log out..." maskType:SVProgressHUDMaskTypeGradient];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Log out" message:[error localizedDescription]];
        } else {
            [Util setLoginUserName:@"" password:@""];
            UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
            for(UIViewController * vc in mainNav.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [self.navigationController popToViewController:vc animated:YES];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    break;
                }
            }
        }
    }];
}

#pragma mark - search result
- (void) fetchSearch
{
    products = [NSMutableArray new];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    tbl_search.userInteractionEnabled = NO;
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery * productQuery = nil;
    if(searchString.length > 0){
        PFQuery * productSearch1 = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
        [productSearch1 whereKey:PARSE_PRODUCT_TITLE matchesRegex:searchString modifiers:@"i"];
        PFQuery * productSearch2 = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
        [productSearch2 whereKey:PARSE_PRODUCT_DESCRIPTION matchesRegex:searchString modifiers:@"i"];
        PFQuery * productSearch3 = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
        [productSearch3 whereKey:PARSE_PRODUCT_KEYWORD matchesRegex:searchString modifiers:@"i"];
        productQuery = [PFQuery orQueryWithSubqueries:[[NSArray alloc] initWithObjects:productSearch1, productSearch2, productSearch3, nil]];
    }else{
        productQuery = [PFQuery queryWithClassName:PARSE_TABLE_PRODUCT];
    }
    
    [productQuery includeKey:PARSE_PRODUCT_OWNER];
    [productQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:error.localizedDescription];
            tbl_search.userInteractionEnabled = YES;
        } else {
            products = (NSMutableArray *) array;
            tbl_search.delegate = self;
            tbl_search.dataSource = self;
            [tbl_search reloadData];
            tbl_search.userInteractionEnabled = YES;
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return products.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TitleTableViewCell";
    TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFObject * productItem = [products objectAtIndex:indexPath.row];
        cell.lbl_title.text = productItem[PARSE_PRODUCT_TITLE];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PFObject * productItem = [products objectAtIndex:indexPath.row];
    UINavigationController * mainNav = ((UserHomeViewController*)[UserHomeViewController getInstance]).navigationController;
    ItemDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemDetailViewController"];
    controller.productInfo = productItem;
    controller.runType = PRODUCTDETAIL_RUN_USER;
    [mainNav pushViewController:controller animated:YES];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == edt_search){
        NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        searchString = newString;
        [self fetchSearch];
    }
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == edt_search){
        edt_search.text = [Util trim:edt_search.text];
        searchString = edt_search.text;
        [self fetchSearch];
    }
}

@end
