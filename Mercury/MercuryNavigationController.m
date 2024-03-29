//
//  MercuryNavigationController.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "MercuryNavigationController.h"
#import "BattleLayer.h"

@interface MercuryNavigationController ()

@end

@implementation MercuryNavigationController

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortraitUpsideDown;
}

- (void)directorDidReshapeProjection:(CCDirector *)director {
    if (director.runningScene == nil) {
        [director runWithScene:[BattleLayer scene]];
    }
}

@end