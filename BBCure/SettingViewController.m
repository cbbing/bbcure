//
//  MainViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 26..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "AppMacro.h"
#import "BKPasscodeLockScreenManager.h"


@interface SettingViewController ()

@property (strong, nonatomic) UIBarButtonItem *backButtonItem;

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.passcode = @"1234";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.backButtonItem;
    
    _simplePasscodeSwitch = [[UISwitch alloc] init];
    [_simplePasscodeSwitch setOn:YES];
    
    _customizeAppearanceSwitch = [[UISwitch alloc] init];
    [_customizeAppearanceSwitch setOn:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _lockWhenEnterBackgroundSwitch = [[UISwitch alloc] init];
    [_lockWhenEnterBackgroundSwitch setOn:[userDefaults boolForKey:ACTIVIE_PASSCODE]];
    
    _authWithTouchIDFirstSwitch = [[UISwitch alloc] init];
    [_authWithTouchIDFirstSwitch setOn:YES];
    
    self.title = @"设置";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    cell.textLabel.numberOfLines = 0;
    
    switch (indexPath.section) {
            
        case 0:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"启用密码锁";
                cell.accessoryView = self.lockWhenEnterBackgroundSwitch;
            } else {
                cell.textLabel.text = @"Touch ID可用时启用";
                cell.accessoryView = self.authWithTouchIDFirstSwitch;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case 1:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"设置密码";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"修改密码";
            }
            break;

    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"\n";
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 3) {
        return indexPath;
    }
    return nil;
}

- (BKPasscodeViewController *)createPasscodeViewController
{
    return [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        switch (indexPath.row) {
            case 0:
                [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerNewPasscodeType];
                break;
            case 1:
                [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerChangePasscodeType];
                break;
            
            default:
                break;
        }
    }
}

- (void)presentPasscodeViewControllerWithType:(BKPasscodeViewControllerType)type
{
    BKPasscodeViewController *viewController = [self createPasscodeViewController];
    viewController.delegate = self;
    viewController.type = type;

    // Passcode style (numeric or ASCII)
    viewController.passcodeStyle = (self.simplePasscodeSwitch.isOn) ? BKPasscodeInputViewNumericPasscodeStyle : BKPasscodeInputViewNormalPasscodeStyle;
    
    // Setup Touch ID manager
    BKTouchIDManager *touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:@"BKPasscodeSampleService"];
    touchIDManager.promptText = @"BKPasscodeView Touch ID Demo";
    viewController.touchIDManager = touchIDManager;
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (self.authWithTouchIDFirstSwitch.isOn && viewController.type == BKPasscodeViewControllerCheckPasscodeType) {
        
        // To prevent duplicated selection before showing Touch ID user interface.
        self.tableView.userInteractionEnabled = NO;
        
        // Show Touch ID user interface
//        [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {
//            
//            // Enable user interaction
//            self.tableView.userInteractionEnabled = YES;
//            
//            // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
//            if (prompted) {
//                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
//                if (selectedIndexPath) {
//                    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
//                }
//            } else {
//                [self presentViewController:navController animated:YES completion:nil];
//            }
//        }];
        
    } else {
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)passcodeViewCloseButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
            {
                self.passcode = aPasscode;
                self.failedAttempts = 0;
                self.lockUntilDate = nil;
            
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:self.passcode forKey:PASSCODE];
            }

            break;
        default:
            break;
    }
    
    [aViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - event response

-(void)backAction
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.lockWhenEnterBackgroundSwitch.isOn forKey:ACTIVIE_PASSCODE];
    
//    if (!self.lockWhenEnterBackgroundSwitch.isOn) {
//        
//        [userDefaults setObject:@"" forKey:PASSCODE];
//    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter

-(UIBarButtonItem*) backButtonItem
{
    _backButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backAction)];
    return _backButtonItem;
}

@end
