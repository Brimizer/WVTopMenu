//
//  UIViewController+MFSideMenuAdditions.h
//  MFSideMenuDemoBasic
//
//  Created by Michael Frederick on 4/2/13.
//  Copyright (c) 2013 Frederick Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WVTopMenuContainerViewController.h"

// category on UIViewController to provide reference to the menuContainerViewController in any of the contained View Controllers
@interface UIViewController (WVTopMenuAdditions)

@property(nonatomic,readonly,retain) WVTopMenuContainerViewController *menuContainerViewController;

@end

