//
//  Enemy.h
//  Mercury
//
//  Created by Nico Hämäläinen on 7/24/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <cocos2d.h>

@interface Enemy : NSObject

@property (nonatomic, readwrite) int health;
@property (nonatomic, readwrite) int attack;

@end
