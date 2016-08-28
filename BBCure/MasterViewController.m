//
//  MasterViewController.m
//  BBCure
//
//  Created by Chen on 15/5/31.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BKPasscodeViewController.h"
#import "SettingViewController.h"
#import "AppMacro.h"


@interface MasterViewController ()

@property (strong, nonatomic) UIBarButtonItem *addNewButtonItem;
@property (strong, nonatomic) UIBarButtonItem *settingButtonItem;

//@property (strong, nonatomic) UIButton *settingButton;

@property (nonatomic)  NSMutableArray *objects;

@end

@implementation MasterViewController

#pragma mark - life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.settingButtonItem;
    self.navigationItem.rightBarButtonItem = self.addNewButtonItem;
    self.navigationItem.title = @"进行中";
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    if ([self.objects count] > 0) {
        CureData *data = self.objects[0];
        [self.detailViewController setDetailName:data.name];
    }
    
    [self loadPasscodeView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CureData *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailName:object.name];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UICureTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CureCell" forIndexPath:indexPath];
    cell.data = self.objects[indexPath.row];
    
    cell.addNewCureButton.tag = indexPath.row;
    [cell.addNewCureButton addTarget:self action:@selector(insertNewObject:) forControlEvents:UIControlEventTouchUpInside];
    //cell.titleLabel.text = cell.data.name;
    

    //NSDate *object = self.objects[indexPath.row];
    //cell.textLabel.text = [object description];
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CureData *object = self.objects[indexPath.row];
//    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//    [controller setDetailName:object.name];
//    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//    controller.navigationItem.leftItemsSupplementBackButton = YES;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //删除数据库对应数据
        CureData *data = self.objects[indexPath.row];
        [CureData deleteWithWhere:[NSString stringWithFormat:@"name='%@'", data.name]];
        //[CureData deleteToDB:self.objects[indexPath.row]];
        
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

//#pragma mark - UICureTableCellDelegate
//
//-(void)addNewCureItem:(UIButton *)button
//{
//    [self insertNewObject:button];
//}

#pragma mark - UIAddNewItemViewDelegate

-(void)refreshTableView
{
    self.objects = nil;
    [self.tableView reloadData];
}

#pragma mark - BKPasscodeViewControllerDelegate

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController authenticatePasscode:(NSString *)aPasscode resultHandler:(void (^)(BOOL))aResultHandler
{
    if ([aPasscode isEqualToString:self.passcode]) {
        
        self.lockUntilDate = nil;
        self.failedAttempts = 0;
        
        aResultHandler(YES);
    } else {
        aResultHandler(NO);
    }
}

- (void)passcodeViewControllerDidFailAttempt:(BKPasscodeViewController *)aViewController
{
    self.failedAttempts++;
    
    if (self.failedAttempts > 5) {
        
        NSTimeInterval timeInterval = 60;
        
        if (self.failedAttempts > 6) {
            
            NSUInteger multiplier = self.failedAttempts - 6;
            
            timeInterval = (5 * 60) * multiplier;
            
            if (timeInterval > 3600 * 24) {
                timeInterval = 3600 * 24;
            }
        }
        
        self.lockUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
}

- (NSUInteger)passcodeViewControllerNumberOfFailedAttempts:(BKPasscodeViewController *)aViewController
{
    return self.failedAttempts;
}

- (NSDate *)passcodeViewControllerLockUntilDate:(BKPasscodeViewController *)aViewController
{
    return self.lockUntilDate;
}

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode
{
    switch (aViewController.type) {
        case BKPasscodeViewControllerNewPasscodeType:
        case BKPasscodeViewControllerChangePasscodeType:
            self.passcode = aPasscode;
            self.failedAttempts = 0;
            self.lockUntilDate = nil;
            break;
        default:
            break;
    }
    
    [aViewController dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - event response

- (void)insertNewObject:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    //UINavigationController *addVC = [story instantiateViewControllerWithIdentifier:@"navAddVC"];
    AddNewItemViewController *addVC = [story instantiateViewControllerWithIdentifier:@"addVC"];
    if ([sender isKindOfClass:[UIButton class]]) { //editing
        UIButton *addButton = sender;
        CureData *data = self.objects[addButton.tag];
        
        addVC.partName = data.name;
        addVC.bEditing = YES;
    }
    else
    {
        addVC.bEditing = NO;
    }
    _popover = [[UIPopoverController alloc] initWithContentViewController:addVC];
    _popover.popoverContentSize = CGSizeMake(600, 650);
    
    addVC.popoverVC = _popover;
    addVC.delegate = self;
    
    //test
    popoverController = [[WYPopoverController alloc] initWithContentViewController:addVC];
    popoverController.delegate = self;
//    [popoverController presentPopoverAsDialogAnimated:YES
//                                 completion:^{
//                                     // Code executed after popover presentation animation sequence ends
//                                 }];
//    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 1, 1)   //self.navigationController.view.bounds
//                             inView:self.navigationController.view
//           permittedArrowDirections:WYPopoverArrowDirectionAny  //WYPopoverArrowDirectionAny
//                           animated:YES
//                            options:WYPopoverAnimationOptionFadeWithScale];
    
//    [popoverController presentPopoverFromRect:self.view.bounds inView:self.view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];

    
//    if ([sender isKindOfClass:[UIButton class]]) { //editing
//        //UIButton *addButton = sender;
//        [_popover presentPopoverFromRect:self.tableView.frame
//                                  inView:self.view
//                permittedArrowDirections:UIPopoverArrowDirectionLeft
//                                animated:YES];
//    }
//    else
//    {
//        UIBarButtonItem *buttomItem = sender;
//        [_popover presentPopoverFromBarButtonItem:buttomItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }
    
    [_popover presentPopoverFromRect:CGRectMake(0, 0, 1, 1)
                              inView:self.view
            permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                            animated:YES];
   
}

//进入设置页面
-(void) setting:(id)sender
{
    SettingViewController *vc = [[SettingViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] init];
    [nav pushViewController:vc animated:YES];
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)loadPasscodeView
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.passcode = [userDefaults stringForKey:PASSCODE];
    BOOL active_passcode = [userDefaults boolForKey:ACTIVIE_PASSCODE];
    
    if (active_passcode && [self.passcode length] > 0) {
        BKPasscodeViewController *viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
        viewController.delegate = self;
        viewController.type = BKPasscodeViewControllerCheckPasscodeType;
        // viewController.type = BKPasscodeViewControllerChangePasscodeType;    // for change
        // viewController.type = BKPasscodeViewControllerCheckPasscodeType;   // for authentication
        
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
        // viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle;    // for ASCII style passcode.
        
        // To supports Touch ID feature, set BKTouchIDManager instance to view controller.
        // It only supports iOS 8 or greater.
        viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
        viewController.touchIDManager.promptText = @"Scan fingerprint to authenticate";   // You can set prompt text.
        
//        [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {
//            
//            // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
//            if (NO == prompted) {
//                viewController.touchIDManager = nil;
//                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//                [self presentViewController:navController animated:YES completion:nil];
//            }
//        }];
        
    }
    
    
}

#pragma mark - getter

-(UIBarButtonItem*) addNewButtonItem
{
    if (_addNewButtonItem)
        return _addNewButtonItem;
        
        _addNewButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:0 target:self action:@selector(insertNewObject:)];
    return _addNewButtonItem;
}

-(UIBarButtonItem*) settingButtonItem
{
    //_settingButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(setting:)];
    //return _settingButtonItem;
    
    if (_settingButtonItem)
        return _settingButtonItem;
    
    _settingButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:0 target:self action:@selector(setting:)];
    return _settingButtonItem;
}

-(NSMutableArray*)objects
{
    if (_objects == nil)
    {
        LKDBHelper *globalHelper = [CureData getUsingLKDBHelper];
        NSString *sql = [NSString stringWithFormat:@"select name, cureDuration, date, max(date) from @t group by name order by date asc limit 10"];
        
        _objects = [globalHelper searchWithSQL:sql toClass:[CureData class]];
        //_objects = [CureData searchWithWhere:nil orderBy:@"timeIntervalSince1970 desc" offset:0 count:100];
        
    }
    return _objects;
}



- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}

@end
