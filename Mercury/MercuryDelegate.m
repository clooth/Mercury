//
//  AppDelegate.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/10/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//
#import <cocos2d/cocos2d.h>
#import <CocosDenshion/SimpleAudioEngine.h>

#import "MercuryDelegate.h"

@implementation MercuryDelegate

@synthesize window;
@synthesize navigationController;
@synthesize director;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // CCGLView
    CCGLView *glView = [CCGLView viewWithFrame:window.bounds
                                   pixelFormat:kEAGLColorFormatRGBA8
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];
    
    // Director
    director = (CCDirectorIOS*) [CCDirector sharedDirector];
    [director setWantsFullScreenLayout:YES];
    [director setDisplayStats:YES];
    [director setAnimationInterval:1.0/60]; // FPS
    [director setView:glView];
    [director setProjection:kCCDirectorProjection2D];
    
    if ( ![director enableRetinaDisplay:YES]) {
        DDLogInfo(@"Running on a non-retina device.");
    }
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:NO];
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];
    [sharedFileUtils setiPadSuffix:@"-ipad"];
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];
    
    navigationController = [[MercuryNavigationController alloc] initWithRootViewController:director];
    [navigationController setNavigationBarHidden:YES];
    [director setDelegate:navigationController];
    
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if ([navigationController visibleViewController] == director) {
        [director pause];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([navigationController visibleViewController] == director) {
        [director stopAnimation];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([navigationController visibleViewController] == director) {
        [director startAnimation];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
    if ([navigationController visibleViewController] == director) {
        [director resume];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CC_DIRECTOR_END();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
