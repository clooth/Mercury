//
//  BattleLayer.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "BattleLayer.h"
#import "BoardLayer.h"

@implementation BattleLayer

+ (id)scene
{
    CCScene *scene = [CCScene node];
    BattleLayer *battleLayer = [BattleLayer node];
    [scene addChild:battleLayer];
    
    return scene;
}

- (void)startRound
{
    battleScene = [CCScene node];
    BoardLayer *boardLayer = [BoardLayer node];
    [battleScene addChild:boardLayer];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionJumpZoom transitionWithDuration:1.0 scene:battleScene]];
}

- (void)onEnter
{
    [super onEnter];
    [self startRound];
}
@end
