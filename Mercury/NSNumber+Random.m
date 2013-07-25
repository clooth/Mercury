//
//  NSNumber+Random.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "NSNumber+Random.h"

@implementation NSNumber (Random)

+ (int)randomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

@end
