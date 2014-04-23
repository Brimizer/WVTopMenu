//
//  UIViewController+MFSideMenuAdditions.m
//  MFSideMenuDemoBasic
//
//  Created by Michael Frederick on 4/2/13.
//  Copyright (c) 2013 Frederick Development. All rights reserved.
//

#import "UIViewController+WVTopMenuAdditions.h"


@implementation UIViewController (WVTopMenuAdditions)

@dynamic menuContainerViewController;

- (WVTopMenuContainerViewController *)menuContainerViewController {
    id containerView = self;
    while (![containerView isKindOfClass:[WVTopMenuContainerViewController class]] && containerView) {
        if ([containerView respondsToSelector:@selector(parentViewController)])
            containerView = [containerView parentViewController];
        if ([containerView respondsToSelector:@selector(splitViewController)] && !containerView)
            containerView = [containerView splitViewController];
    }
    return containerView;
}

@end