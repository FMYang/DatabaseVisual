//
//  DatabaseManager.m
//  DQGuess
//
//  Created by Imp on 2018/11/5.
//  Copyright © 2018 jingbo. All rights reserved.
//

#import "DatabaseManager.h"
#import "DatabaseListViewController.h"
#import "DatabaseFactory.h"

@interface DatabaseManager () <DatabaseListViewControllerDelegate>

@property (nonatomic, strong) UIWindow *showWindow;
@property (nonatomic, strong) DatabaseListViewController *viewController;

@end

@implementation DatabaseManager

+ (instancetype)sharedInstance {
    static DatabaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DatabaseManager alloc] init];
    });
    return sharedInstance;
}

- (UIWindow *)showWindow {
    if (_showWindow == nil) {
        _showWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _showWindow.backgroundColor = [UIColor redColor];
        _showWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
        _showWindow.windowLevel = UIWindowLevelStatusBar;
    }
    return _showWindow;
}

- (DatabaseListViewController *)viewController {
    if (_viewController == nil) {
        _viewController = [[DatabaseListViewController alloc] initWithDBPaths:[DatabaseFactory queryIfHadDBFromDirectory:self.dbDocumentPath]];
        _viewController.delegate = self;
    }
    return _viewController;
}

- (void)iOS13ShowCustomWindowWithWindow:(UIWindow *)window {
    if (@available(iOS 13.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        if (!window.windowScene) {
            for (UIWindowScene *windowScene in array) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    window.windowScene = windowScene;
                    return;
                }
            }
        }
    }
}

- (void)showTables {
    [self iOS13ShowCustomWindowWithWindow:self.showWindow];
    self.showWindow.hidden = false;
}

- (void)hideTables {
    self.showWindow.hidden = true;
}

#pragma mark -- DatabaseListViewControllerDelegate

- (void)databaseListViewControllerDidFinish {
    [self hideTables];
}

- (UIViewController *)currentViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;

        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

@end
