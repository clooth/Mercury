//
//  BattleLayer.h
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <cocos2d.h>

#import "CCLayer.h"

@interface BattleLayer : CCLayer
{
    CCScene *battleScene;
}

+ (id)scene;

@end
