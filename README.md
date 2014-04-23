# WVTopMenu

This is an adaptation of [MFSideMenu](https://github.com/mikefrederick/MFSideMenu) that is meant to be used at the top of the screen.

=======

## Installation

####CocoaPods
WVTopMenu is available through a limited [CocoaPods](http://cocoapods.org) setup.

Add the following to your Podfile:

    pod "WVTopMenu", :git => 'https://github.com/Brimizer/WVTopMenu.git'

####Manually
Add the `WVTopMenu` folder to your project. 
Add QuartzCore to your project.

`WVTopMenu` uses ARC.

## Usage

###Basic Setup
In your app delegate:<br />
```objective-c
#import "WVTopMenu.h"

WVTopMenuContainerViewController *container = [WVTopMenuContainerViewController containerWithMainViewController:mainViewController menuViewController:menuViewController];

self.window.rootViewController = container;
[self.window makeKeyAndVisible];
```

###Opening & Closing Menus

```objective-c
// Toggle the top menu
[self.menuContainerViewController toggleTopMenuCompletion:^{}];

// Close the menu
[self.menuContainerViewController setMenuState:WVTopMenuStateClosed completion:^{}];

// Open the menu
[self.menuContainerViewController setMenuState:WVTopMenuStateOpen completion:^{}];
```

## Author

Daniel Brim
[@brimizer](http://twitter.com/brimizer)
brimizer@gmail.com

## License

WVTopMenu is available under the MIT license. See the LICENSE file for more info.

