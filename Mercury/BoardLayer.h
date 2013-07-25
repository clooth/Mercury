//
//  BoardLayer.h
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <cocos2d.h>

#import "BoardPiece.h"

typedef NS_ENUM(int, Direction) {
    DirectionUp = 1,
    DirectionDown,
    DirectionLeft,
    DirectionRight,
    DirectionInvalid
};

@interface BoardLayer : CCLayer<CCTouchOneByOneDelegate>
{
    // Piece dragging
    BoardPiece *pieceBeingDragged;
    BoardPiece *tmpPieceBeingDragged;
    CGPoint dragOffset;
    
    // Matching
    NSMutableSet *matches;
    NSMutableSet *tmpMatches;
    int matchesToProcess;
}

#pragma mark - Setup methods

/** Sets up the turn time limit timer */
@property (nonatomic, strong) CCProgressTimer *turnTimer;
- (void)setupTurnTimer;

/** Sets up the touch events manager */
@property BOOL touchesEnabled;
- (void)setupTouchEvents;

#pragma mark - Board manipulation

@property (nonatomic, strong) NSMutableArray *pieces;
@property int columns;
@property int rows;

/** Clears and fills the board with random pieces */
- (void)clearAndFillBoard;

@end
