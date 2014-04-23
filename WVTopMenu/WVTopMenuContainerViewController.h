//
//  WVTopMenuContainerViewController.h
//  TestBench
//
//  Created by Daniel Brim on 4/21/14.
//  Copyright (c) 2014 Daniel Brim. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const WVTopMenuStateNotificationEvent;

typedef NS_ENUM(NSInteger, WVTopMenuPanMode) {
    WVTopMenuPanModeNone = 0, // pan disabled
    WVTopMenuPanModeCenterViewController = 1 << 0, // enable panning on the centerViewController
    WVTopMenuPanModeSideMenu = 1 << 1, // enable panning on side menus
    WVTopMenuPanModeDefault = WVTopMenuPanModeCenterViewController | WVTopMenuPanModeSideMenu
};

typedef NS_ENUM(NSInteger, WVTopMenuState) {
    WVTopMenuStateClosed, // the menu is closed
    WVTopMenuStateOpen // the top menu is open
};

typedef NS_ENUM(NSInteger, WVTopMenuStateEvent) {
    WVTopMenuStateEventMenuWillOpen, // the menu is going to open
    WVTopMenuStateEventMenuDidOpen, // the menu finished opening
    WVTopMenuStateEventMenuWillClose, // the menu is going to close
    WVTopMenuStateEventMenuDidClose // the menu finished closing
};

@interface WVTopMenuContainerViewController : UIViewController <UIGestureRecognizerDelegate>

+ (WVTopMenuContainerViewController *)containerWithMainViewController:(id)mainViewController
                                                   menuViewController:(id)menuViewController;

@property (nonatomic, strong) id mainViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

@property (nonatomic, assign) WVTopMenuState menuState;
@property (nonatomic, assign) WVTopMenuPanMode panMode;

@property (nonatomic) CGFloat topMenuHeight;

@property (nonatomic, assign) CGFloat menuAnimationDefaultDuration;
@property (nonatomic, assign) CGFloat menuAnimationMaxDuration;

// menu slide-in animation
@property (nonatomic, assign) BOOL menuSlideAnimationEnabled;
@property (nonatomic, assign) CGFloat menuSlideAnimationFactor; // higher = less menu movement on animation

- (void)toggleTopMenuCompletion:(void (^)(void))completion;
- (void)setMenuState:(WVTopMenuState)menuState completion:(void (^)(void))completion;

// can be used to attach a pan gesture recognizer to a custom view
- (UIPanGestureRecognizer *)panGestureRecognizer;

@end
