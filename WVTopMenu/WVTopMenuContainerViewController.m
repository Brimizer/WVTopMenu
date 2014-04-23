//
//  WVTopMenuContainerViewController.m
//  TestBench
//
//  Created by Daniel Brim on 4/21/14.
//  Copyright (c) 2014 Daniel Brim. All rights reserved.
//

#import "WVTopMenuContainerViewController.h"

NSString * const WVTopMenuStateNotificationEvent = @"WVTopMenuStateNotificationEvent";

typedef NS_ENUM(NSInteger, WVTopMenuPanDirection) {
    WVTopMenuPanDirectionNone,
    WVTopMenuPanDirectionUp,
    WVTopMenuPanDirectionDown
};

@interface WVTopMenuContainerViewController ()
@property (nonatomic, assign) CGPoint panGestureOrigin;
@property (nonatomic, assign) CGFloat panGestureVelocity;
@property (nonatomic, assign) WVTopMenuPanDirection panDirection;

@property (nonatomic, strong) UIView *menuContainerView;

@property (nonatomic, assign) BOOL viewHasAppeared;

@end

@implementation WVTopMenuContainerViewController

+ (WVTopMenuContainerViewController *)containerWithMainViewController:(id)mainViewController
                                                   menuViewController:(id)menuViewController
{
    WVTopMenuContainerViewController *controller = [WVTopMenuContainerViewController new];
    controller.mainViewController = mainViewController;
    controller.menuViewController = menuViewController;
    return controller;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaultSettings];
    }
    return self;
}

- (void)setDefaultSettings {
    if(self.menuContainerView) return;
    
    self.menuContainerView = [[UIView alloc] init];
    self.menuState = WVTopMenuStateClosed;
    self.topMenuHeight = 420.0f;
    self.menuSlideAnimationEnabled = YES;
    self.menuSlideAnimationFactor = 3.0f;
    self.menuAnimationDefaultDuration = 0.2f;
    self.menuAnimationMaxDuration = 0.4f;
    self.panMode = WVTopMenuPanModeDefault;
    self.viewHasAppeared = NO;
}

- (void)setupMenuContainerView {
    if(self.menuContainerView.superview) return;
    
    self.menuContainerView.frame = self.view.bounds;
    self.menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:self.menuContainerView atIndex:0];
    
    if(self.menuViewController && !self.menuViewController.view.superview) {
        [self.menuContainerView addSubview:self.menuViewController.view];
    }
}

#pragma mark -
#pragma mark - View Lifecycle
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.viewHasAppeared) {
        [self setupMenuContainerView];
        [self setMenuFrameToClosedPosition];
        
        self.viewHasAppeared = YES;
    }
}

#pragma mark -
#pragma mark - UIViewController Containment

- (void)setMenuViewController:(UIViewController *)menuViewController {
    [self removeChildViewControllerFromContainer:_menuViewController];
    
    _menuViewController = menuViewController;
    if(!_menuViewController) return;
    
    [self addChildViewController:_menuViewController];
    if(self.menuContainerView.superview) {
        [self.menuContainerView insertSubview:[_menuViewController view] atIndex:0];
    }
    [_menuViewController didMoveToParentViewController:self];
    
    if(self.viewHasAppeared) [self setMenuFrameToClosedPosition];
}

- (void)setMainViewController:(UIViewController *)mainViewController {
    [self removeCenterGestureRecognizers];
    [self removeChildViewControllerFromContainer:_mainViewController];
    
    CGPoint origin = ((UIViewController *)_mainViewController).view.frame.origin;
    _mainViewController = mainViewController;
    if(!_mainViewController) return;
    
    [self addChildViewController:_mainViewController];
    [self.view addSubview:[_mainViewController view]];
    [((UIViewController *)_mainViewController) view].frame = (CGRect){.origin = origin, .size=mainViewController.view.frame.size};
    
    [_mainViewController didMoveToParentViewController:self];
    
//    self.shadow = [MFSideMenuShadow shadowWithView:[_mainViewController view]];
//    [self.shadow draw];
    [self addCenterGestureRecognizers];
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}

#pragma mark -
#pragma mark - UIGestureRecognizer Helpers

- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
	[recognizer setMaximumNumberOfTouches:1];
    [recognizer setDelegate:self];
    return recognizer;
}

- (void)addGestureRecognizers {
    [self addCenterGestureRecognizers];
    [self.menuContainerView addGestureRecognizer:[self panGestureRecognizer]];
}

- (void)removeCenterGestureRecognizers
{
    if (self.mainViewController)
    {
        [[self.mainViewController view] removeGestureRecognizer:[self centerTapGestureRecognizer]];
        [[self.mainViewController view] removeGestureRecognizer:[self panGestureRecognizer]];
    }
}
- (void)addCenterGestureRecognizers
{
    if (self.mainViewController)
    {
        [[self.mainViewController view] addGestureRecognizer:[self centerTapGestureRecognizer]];
        [[self.mainViewController view] addGestureRecognizer:[self panGestureRecognizer]];
    }
}

- (UITapGestureRecognizer *)centerTapGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(mainViewControllerTapped:)];
    [tapRecognizer setDelegate:self];
    return tapRecognizer;
}

#pragma mark -
#pragma mark - Menu State

- (void)toggleTopMenuCompletion:(void (^)(void))completion {
    if(self.menuState == WVTopMenuStateOpen) {
        [self setMenuState:WVTopMenuStateClosed completion:completion];
    } else {
        [self setMenuState:WVTopMenuStateOpen completion:completion];
    }
}

- (void)openTopMenuCompletion:(void (^)(void))completion {
    if (!self.menuViewController) return;
    [self.menuContainerView bringSubviewToFront:[self.menuViewController view]];
    [self setMainViewControllerOffset:self.topMenuHeight animated:YES completion:completion];
}

- (void)closeTopMenuCompletion:(void (^)(void))completion {
    [self setMainViewControllerOffset:0 animated:YES completion:completion];
}

- (void)setMenuState:(WVTopMenuState)menuState {
    [self setMenuState:menuState completion:nil];
}

- (void)setMenuState:(WVTopMenuState)menuState completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        _menuState = menuState;
        
        [self setUserInteractionStateForMainViewController];
        WVTopMenuStateEvent eventType = (_menuState == WVTopMenuStateClosed) ? WVTopMenuStateEventMenuDidClose : WVTopMenuStateEventMenuDidOpen;
        [self sendStateEventNotification:eventType];
        
        if(completion) completion();
    };
    
    switch (menuState) {
        case WVTopMenuStateClosed: {
            [self sendStateEventNotification:WVTopMenuStateEventMenuWillClose];
            [self closeTopMenuCompletion:^{
                [self.menuViewController view].hidden = YES;
                innerCompletion();
            }];
            break;
        }
        case WVTopMenuStateOpen:
            if(!self.menuViewController) return;
            [self sendStateEventNotification:WVTopMenuStateEventMenuDidOpen];
            [self menuWillShow];
            [self openTopMenuCompletion:innerCompletion];
            break;

        default:
            break;
    }
}

// these callbacks are called when the menu will become visible, not neccessarily when they will OPEN
- (void)menuWillShow {
    [self.menuViewController view].hidden = NO;
    [self.menuContainerView bringSubviewToFront:[self.menuViewController view]];
}

#pragma mark -
#pragma mark - State Event Notification

- (void)sendStateEventNotification:(WVTopMenuStateEvent)event {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:event]
                                                         forKey:@"eventType"];
    [[NSNotificationCenter defaultCenter] postNotificationName:WVTopMenuStateNotificationEvent
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark -
#pragma mark - Side Menu Positioning

- (void) setMenuFrameToClosedPosition {
    if(!self.menuViewController) return;
    CGRect topFrame = [self.menuViewController view].frame;
    topFrame.size.height = self.topMenuHeight;
    topFrame.origin.x = 0;
    topFrame.origin.y = (self.menuSlideAnimationEnabled) ? -1*topFrame.size.height / self.menuSlideAnimationFactor : 0;
    [self.menuViewController view].frame = topFrame;
    [self.menuViewController view].autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}

- (void)alignMenuControllerWithMainViewController {
    CGRect menuFrame = [self.menuViewController view].frame;
    menuFrame.size.width = [self.menuViewController view].frame.size.width;
    
    CGFloat yOffset = [self.mainViewController view].frame.origin.y;
    CGFloat yPositionDivider = (self.menuSlideAnimationEnabled) ? self.menuSlideAnimationFactor : 1.0;
    menuFrame.origin.y = yOffset / yPositionDivider - _topMenuHeight / yPositionDivider;
    
    [self.menuViewController view].frame = menuFrame;
}



#pragma mark -
#pragma mark - Side Menu Width

- (void)setMenuHeight:(CGFloat)topMenuHeight {
    [self setTopMenuHeight:topMenuHeight animated:YES];
}

- (void)setMenuHeight:(CGFloat)menuWidth animated:(BOOL)animated {
    [self setTopMenuHeight:menuWidth animated:animated];
}

- (void)setTopMenuHeight:(CGFloat)topMenuHeight animated:(BOOL)animated {
    _topMenuHeight = topMenuHeight;
    
    if(self.menuState != WVTopMenuStateOpen) {
        [self setMenuFrameToClosedPosition];
        return;
    }
    
    CGFloat offset = _topMenuHeight;
    void (^effects)() = ^ {
        [self alignMenuControllerWithMainViewController];
    };
    
    [self setMainViewControllerOffset:offset additionalAnimations:effects animated:animated completion:nil];
}

#pragma mark -
#pragma mark - MFSideMenuPanMode

- (BOOL) mainViewControllerPanEnabled {
    return ((self.panMode & WVTopMenuPanModeCenterViewController) == WVTopMenuPanModeCenterViewController);
}

- (BOOL) sideMenuPanEnabled {
    return ((self.panMode & WVTopMenuPanModeSideMenu) == WVTopMenuPanModeSideMenu);
}


#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
       self.menuState != WVTopMenuStateClosed) return YES;
    
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if([gestureRecognizer.view isEqual:[self.mainViewController view]])
            return [self mainViewControllerPanEnabled];
        
        if([gestureRecognizer.view isEqual:self.menuContainerView])
            return [self sideMenuPanEnabled];
        
        // pan gesture is attached to a custom view
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}


#pragma mark -
#pragma mark - UIGestureRecognizer Callbacks

// this method handles any pan event
// and sets the navigation controller's frame as needed
- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    UIView *view = [self.mainViewController view];
    
	if(recognizer.state == UIGestureRecognizerStateBegan) {
        // remember where the pan started
        _panGestureOrigin = view.frame.origin;
        self.panDirection = WVTopMenuPanDirectionNone;
	}
    
    if(self.panDirection == WVTopMenuPanDirectionNone) {
        CGPoint translatedPoint = [recognizer translationInView:view];
        if(translatedPoint.y > 0) {
            self.panDirection = WVTopMenuPanDirectionDown;
            if(self.menuViewController && self.menuState == WVTopMenuStateClosed) {
                [self menuWillShow];
            }
        } else if(translatedPoint.y < 0) {
            self.panDirection = WVTopMenuPanDirectionUp;
        }

    }
    
    if((self.menuState == WVTopMenuStateClosed && self.panDirection == WVTopMenuPanDirectionUp)
       || (self.menuState == WVTopMenuStateOpen && self.panDirection == WVTopMenuPanDirectionDown)) {
        self.panDirection = WVTopMenuPanDirectionNone;
        return;
    }
    
    if(self.panDirection == WVTopMenuPanDirectionUp) {
        [self handleUpPan:recognizer];
    } else if(self.panDirection == WVTopMenuPanDirectionDown) {
        [self handleDownPan:recognizer];
    }
}

- (void) handleDownPan:(UIPanGestureRecognizer *)recognizer {
    if(!self.menuViewController && self.menuState == WVTopMenuStateClosed) return;
    
    UIView *view = [self.mainViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = _panGestureOrigin;
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.y = MIN(translatedPoint.y, self.topMenuHeight);
    if(self.menuState == WVTopMenuStateOpen) {
        // menu is already open, the most the user can do is close it in this gesture
        translatedPoint.y = MIN(translatedPoint.y, 0);
    } else {
        // we are opening the menu
        translatedPoint.y = MAX(translatedPoint.y, 0);
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalY = translatedPoint.y + (.35*velocity.y);
        CGFloat viewHeight = view.frame.size.height;
        
        if(self.menuState == WVTopMenuStateClosed) {
            BOOL showMenu = (finalY > viewHeight/2) || (finalY > self.topMenuHeight/2);
            if(showMenu) {
                self.panGestureVelocity = velocity.y;
                [self setMenuState:WVTopMenuStateOpen];
            } else {
                self.panGestureVelocity = 0;
                [self setMainViewControllerOffset:0 animated:YES completion:nil];
            }
        } else {
            BOOL hideMenu = (finalY > adjustedOrigin.y);
            if(hideMenu) {
                self.panGestureVelocity = velocity.y;
                [self setMenuState:WVTopMenuStateClosed];
            } else {
                self.panGestureVelocity = 0;
                [self setMainViewControllerOffset:adjustedOrigin.y animated:YES completion:nil];
            }
        }
        
        self.panDirection = WVTopMenuPanDirectionNone;
	} else {
        [self setMainViewControllerOffset:translatedPoint.y];
    }
}

- (void) handleUpPan:(UIPanGestureRecognizer *)recognizer {
    if(self.menuState == WVTopMenuStateClosed) return;
    
    UIView *view = [self.mainViewController view];
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = _panGestureOrigin;
    translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                  adjustedOrigin.y + translatedPoint.y);
    
    translatedPoint.y = MIN(translatedPoint.y, self.topMenuHeight);
    if(self.menuState == WVTopMenuStateOpen) {
        // don't let the pan go less than 0 if the menu is already open
        translatedPoint.y = MAX(translatedPoint.y, 0);
    } else {
        // we are opening the menu
        translatedPoint.y = MIN(translatedPoint.y, 0);
    }
    
    [self setMainViewControllerOffset:translatedPoint.y];
    
	if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalY = translatedPoint.y + (.35*velocity.y);
        CGFloat viewHeight= view.frame.size.height;
        
        if(self.menuState == WVTopMenuStateClosed) {
            BOOL showMenu = (finalY < -1*viewHeight/2);
            if(showMenu) {
                self.panGestureVelocity = velocity.y;
                [self setMenuState:WVTopMenuStateClosed];
            } else {
                self.panGestureVelocity = 0;
                [self setMainViewControllerOffset:0 animated:YES completion:nil];
            }
        } else {
            BOOL hideMenu = (finalY < adjustedOrigin.y);
            if(hideMenu) {
                self.panGestureVelocity = velocity.y;
                [self setMenuState:WVTopMenuStateClosed];
            } else {
                self.panGestureVelocity = 0;
                [self setMainViewControllerOffset:adjustedOrigin.y animated:YES completion:nil];
            }
        }
	} else {
        [self setMainViewControllerOffset:translatedPoint.y];
    }
}

- (void)mainViewControllerTapped:(id)sender {
    if(self.menuState != WVTopMenuStateClosed) {
        [self setMenuState:WVTopMenuStateClosed];
    }
}

- (void)setUserInteractionStateForMainViewController {
    // disable user interaction on the current stack of view controllers if the menu is visible
    if([self.mainViewController respondsToSelector:@selector(viewControllers)]) {
        NSArray *viewControllers = [self.mainViewController viewControllers];
        for(UIViewController* viewController in viewControllers) {
            viewController.view.userInteractionEnabled = (self.menuState == WVTopMenuStateClosed);
        }
    }
}

#pragma mark -
#pragma mark - Center View Controller Movement

- (void)setMainViewControllerOffset:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(void))completion {
    [self setMainViewControllerOffset:offset additionalAnimations:nil
                               animated:animated completion:completion];
}

- (void)setMainViewControllerOffset:(CGFloat)offset
                 additionalAnimations:(void (^)(void))additionalAnimations
                             animated:(BOOL)animated
                           completion:(void (^)(void))completion {
    void (^innerCompletion)() = ^ {
        self.panGestureVelocity = 0.0;
        if(completion) completion();
    };
    
    if(animated) {
        CGFloat mainViewControllerYPosition = ABS([self.mainViewController view].frame.origin.y);
        CGFloat duration = [self animationDurationFromStartPosition:mainViewControllerYPosition toEndPosition:offset];
        
        [UIView animateWithDuration:duration animations:^{
            [self setMainViewControllerOffset:offset];
            if(additionalAnimations) additionalAnimations();
        } completion:^(BOOL finished) {
            innerCompletion();
        }];
    } else {
        [self setMainViewControllerOffset:offset];
        if(additionalAnimations) additionalAnimations();
        innerCompletion();
    }
}

- (void) setMainViewControllerOffset:(CGFloat)yOffset {
    CGRect frame = [self.mainViewController view].frame;
    frame.origin.y = yOffset;
    [self.mainViewController view].frame = frame;
    
    if(!self.menuSlideAnimationEnabled) return;
    
    if(yOffset > 0){
        [self alignMenuControllerWithMainViewController];
        //[self setMenuFrameToClosedPosition];
    } else if(yOffset < 0){
        [self setMenuFrameToClosedPosition];
    } else {
        [self setMenuFrameToClosedPosition];
    }
}

- (CGFloat)animationDurationFromStartPosition:(CGFloat)startPosition toEndPosition:(CGFloat)endPosition {
    CGFloat animationPositionDelta = ABS(endPosition - startPosition);
    
    CGFloat duration;
    if(ABS(self.panGestureVelocity) > 1.0) {
        // try to continue the animation at the speed the user was swiping
        duration = animationPositionDelta / ABS(self.panGestureVelocity);
    } else {
        // no swipe was used, user tapped the bar button item
        // TODO: full animation duration hard to calculate with two menu widths
        CGFloat menuHeight = _topMenuHeight;
        CGFloat animationPerecent = (animationPositionDelta == 0) ? 0 : menuHeight / animationPositionDelta;
        duration = self.menuAnimationDefaultDuration * animationPerecent;
    }
    
    return MIN(duration, self.menuAnimationMaxDuration);
}

@end





























