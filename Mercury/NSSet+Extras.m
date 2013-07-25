//
//  NSSet+Extras.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/25/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "NSSet+Extras.h"

@implementation NSSet (Extras)

- (NSSet *)collapsedSet
{
    NSMutableSet *newSet = [NSMutableSet set];
    for (id object in self) {
        if ([object isKindOfClass:[NSSet class]]) {
            [newSet unionSet:[object collapsedSet]];
        } else {
            [newSet unionSet:self];
        }
    }
    
    return newSet;
}

@end
