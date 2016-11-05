//
//  AppDelegate.m
//  BBCure
//
//  Created by Chen on 15/5/31.
//  Copyright (c) 2015年 Chen. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "BKPasscodeViewController.h"
#import "AppMacro.h"
//#import "UMMobClick/MobClick.h"
#import "MobClick.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [[BKPasscodeLockScreenManager sharedManager] setDelegate:self];
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    
//    self.mainViewController = [[MainViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
//    self.window.rootViewController = navController;
//    [self.window makeKeyAndVisible];
//    
//    return YES;
    
    
    self.splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [self.splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.splitViewController.delegate = self;
    
    //友盟统计
//    UMConfigInstance.appKey = @"581d501304e2053426001a5c";
//    UMConfigInstance.ChannelId = @"App Store";
//    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
    [MobClick startWithAppkey:@"581d501304e2053426001a5c" reportPolicy:BATCH channelId:@"App Store"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"will enter foreground");
    
    [self loadPasscodeView];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailName] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
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

#pragma mark - passcode view

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
        viewController.touchIDManager.promptText = @"通过Home键验证已有手机指纹";   // You can set prompt text.
        
        // Show Touch ID user interface
//        [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {
//            
//            // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
//            if (NO == prompted) {
//                viewController.touchIDManager = nil;
//                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//                [self.splitViewController presentViewController:navController animated:YES completion:nil];
//            }
//        }];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.splitViewController presentViewController:navController animated:YES completion:nil];
    }
    
    
}

@end
