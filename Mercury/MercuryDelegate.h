//
//  AppDelegate.h
//  Mercury
//
//  Created by Nico Hämäläinen on 7/10/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <cocos2d.h>

#import "MercuryNavigationController.h"

@interface MercuryDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    MercuryNavigationController *navigationController;
    CCDirectorIOS *director;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly) MercuryNavigationController *navigationController;
@property (readonly) CCDirectorIOS *director;
@end
