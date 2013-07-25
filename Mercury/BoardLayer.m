//
//  BoardLayer.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <cocos2d/cocos2d.h>
#import "BoardLayer.h"

@implementation BoardLayer
{
    BOOL isAnimatingSwap;
}

@synthesize turnTimer;
@synthesize touchesEnabled;

@synthesize pieces;
@synthesize rows;
@synthesize columns;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setupTurnTimer];
        [self setupTouchEvents];
        
        columns = kBoardColumns;
        rows = kBoardRows;
        
        matches = [NSMutableSet new];
        tmpMatches = [NSMutableSet new];
        
        [self setupBoard];
    }

    return self;
}

#pragma mark - Setup methods

- (void)setupTurnTimer
{
    CCSprite *timerProgressBarSprite = [CCSprite spriteWithFile:@"Sprites/turntimer_progress.png"];

    turnTimer = [CCProgressTimer progressWithSprite:timerProgressBarSprite];
    [turnTimer setType:kCCProgressTimerTypeBar];
    [turnTimer setPercentage:100]; // Start from "full"
    [turnTimer setMidpoint:ccp(0, 0)];
    [turnTimer setBarChangeRate:ccp(1, 0)];
    
    NSLog(@"Created turn timer");
    
    // TODO: Change location when GUI finished
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    [turnTimer setPosition:ccp(windowSize.width / 2.0, windowSize.height)];
    [turnTimer setZOrder:3.0];
    [turnTimer setVisible:YES];
    
    [self addChild:turnTimer];
}

- (void)setupTouchEvents
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:0
                                                       swallowsTouches:YES];
    touchesEnabled = YES;
}

- (void)setupBoard
{
    // Single dimensional array with our board pieces
    pieces = [NSMutableArray new];
    for (int idx = 0; idx < (rows * columns); idx++)
        [pieces addObject:[BoardPiece randomPiece]];
    
    // Starting coordinates for piece drawing
    float boardPieceX = kBoardPieceOffsetX;
    float boardPieceY = kBoardPieceOffsetY;
    
    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
            BoardPiece *piece = pieces[col + (row * columns)];
            [piece setPosition:ccp(boardPieceX, boardPieceY)];
            [self addChild:piece.sprite];
            boardPieceX += kBoardPieceWidth;
        }
        boardPieceY += kBoardPieceHeight;
        boardPieceX = kBoardPieceOffsetX;
    }
}

#pragma mark - Board manipulation and animation methods
- (void)updateBoardAfterSwap:(float)duration
{
    isAnimatingSwap = YES;

    float pieceY = kBoardPieceOffsetY;
    float pieceX = kBoardPieceOffsetX;
    
    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
            BoardPiece *piece = pieces[col + (row * columns)];
            
            if (piece.sprite.position.x != pieceX || piece.sprite.position.y != pieceY)
            {
                CCMoveTo *moveAction = [CCMoveTo actionWithDuration:duration position:ccp(pieceX, pieceY)];
                CCEaseInOut *moveEase = [CCEaseInOut actionWithAction:moveAction rate:2];
                CCCallFunc *animCallFunc = [CCCallFunc actionWithTarget:self selector:@selector(didFinishSwappingPiece)];
                
                NSMutableArray *pieceEffects = [NSMutableArray arrayWithObject:moveEase];
                
                if (piece.sprite.opacity == 0) {
                    [pieceEffects addObject:[CCFadeIn actionWithDuration:duration]];
                }
                
                CCSpawn *effectSpawn = [CCSpawn actionWithArray:pieceEffects];
                
                CCSequence *animSequence = [CCSequence actions:effectSpawn, animCallFunc, nil];
                
                [piece runAction:animSequence];
            }
            pieceX += kBoardPieceWidth;
        }
        pieceY += kBoardPieceHeight;
        pieceX = kBoardPieceOffsetX;
    }
}

- (void)didFinishSwappingPiece
{
    isAnimatingSwap = NO;
}

- (void)turnEnded
{
    touchesEnabled = NO;

    [matches removeAllObjects];

    for (int idx = (rows * columns) - 1; idx >= 0; idx--)
        [self findMatchesForPiece:pieces[idx] atIndex:idx];
    
    if (matches.count > 0)
    {
        NSLog(@"Found %d matches on board", matches.count);
        
        matchesToProcess = matches.count;
        
        NSMutableArray *matchesArray = [NSMutableArray arrayWithArray:matches.allObjects];
        
        [self processMatches:matchesArray];
    }
    else
    {
        touchesEnabled = YES;
        NSLog(@"No matches found on board");
        [self printBoard];
    }
}

- (void)processMatchSet:(NSMutableSet *)matchSet
{
    for (BoardPiece *piece in matchSet)
    {
        // Fade out gems quickly
        CCFadeOut *fadeOutAction = [CCFadeOut actionWithDuration:0.25];
        CCScaleTo *zoomInAction = [CCScaleTo actionWithDuration:0.25 scale:2.0];
        CCSpawn *effectSpawn = [CCSpawn actionOne:fadeOutAction two:zoomInAction];
        
        // Check if we've completed all the matches
        CCCallBlock *completionBlock = [CCCallBlock actionWithBlock:^{
            matchesToProcess--;
            
            if (matchesToProcess == 0) {
                NSLog(@"Finished clearing matches");
                [self clearAndFillBoard];
                double delayInSeconds = 0.75;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self turnEnded];
                });
            }
        }];
        
        CCSequence *actionSequence = [CCSequence actionOne:effectSpawn two:completionBlock];
        [piece runAction:actionSequence];
    }
}

- (void)processMatches:(NSMutableArray *)matchesArray
{
    if (matchesArray.count == 0) return;
    NSMutableSet *matchSet = [matchesArray lastObject];
    
    [self processMatchSet:matchSet];

    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [matchesArray removeObject:matchSet];
        [self processMatches:matchesArray];
    });
}

- (void)findMatchesTo:(Direction)direction
              ofPiece:(BoardPiece *)piece
            withIndex:(int)index
{
    int x = 0;
    int y = 0;
    int nextIndex = 0;

    // Validate position
    switch (direction) {
        case DirectionUp:
            y = index / columns;
            nextIndex = index - columns; // Move one row up
            if (y == 0) return;
            break;
            
        case DirectionDown:
            y = index / columns;
            nextIndex = index + columns; // Move one row down
            if (y == rows-1) return;
            break;
            
        case DirectionLeft:
            x = index % columns;
            nextIndex = index - 1; // Move one column left
            if (x == 0) return;
            break;
            
        case DirectionRight:
            x = index % columns;
            nextIndex = index + 1; // Move one column right
            if (x == columns - 1) return;
            break;

        default:
            return;
    }
    
    [tmpMatches addObject:piece];
    
    BoardPiece *nextPiece = pieces[nextIndex];

    if ([nextPiece matchesTypeOf:piece] == YES)
    {
        BoardPiece *pieceToAdd = (direction == DirectionUp) ? piece : nextPiece;
        [tmpMatches addObject:pieceToAdd];
        [self findMatchesTo:direction ofPiece:nextPiece withIndex:nextIndex];
    }
}

- (void)findMatchesForPiece:(BoardPiece *)piece atIndex:(int)index
{
    NSMutableSet *matchesSet = [NSMutableSet set];
    for (Direction direction = DirectionUp; direction < DirectionInvalid; direction++) {
        [tmpMatches removeAllObjects];
        [self findMatchesTo:direction ofPiece:piece withIndex:index];
        if (tmpMatches.count > 2) {
            NSMutableSet *existingMatchSet = [self findMatchSetWithPiece:piece];
            if (existingMatchSet != nil) {
                [existingMatchSet addObjectsFromArray:tmpMatches.allObjects];
            } else {
                [matchesSet addObjectsFromArray:tmpMatches.allObjects];
            }
        }
    }

    if (matchesSet.count > 0) {
        [matches addObject:matchesSet];
    }
}

- (void)clearAndFillBoard
{
    NSSet *allMatches = [matches collapsedSet];

    NSMutableSet *usedPieces = [NSMutableSet set];
    for (int col = 0; col < columns; col++) {
        for (int row = 0; row < rows; row++) {
            int thisIndex = (row * columns) + col;
            BoardPiece *thisPiece = pieces[thisIndex];
            for (int newRow = row; newRow < rows; newRow++) {
                int newIndex = (newRow * columns) + col;
                BoardPiece *newPiece = pieces[newIndex];
                
                // Was this piece on the matches?
                if (![allMatches containsObject:newPiece] && ![usedPieces containsObject:newPiece])
                {
                    [usedPieces addObject:newPiece];
                    // TODO: Animate this somehow
                    [pieces replaceObjectAtIndex:thisIndex withObject:newPiece];
                    [pieces replaceObjectAtIndex:newIndex withObject:thisPiece];
                    break;
                }
            }
        }
    }
    
    for (BoardPiece *piece in allMatches)
    {
        int pieceIndex = [pieces indexOfObject:piece];
        int x = pieceIndex % columns;
        BoardPiece *newPiece = [BoardPiece randomPiece];
        [newPiece.sprite setOpacity:0];
        [newPiece setPosition:ccp(kBoardPieceOffsetX + (x * kBoardPieceWidth), (rows+1) * kBoardPieceHeight)];
        [self addChild:newPiece.sprite];
        [pieces replaceObjectAtIndex:pieceIndex withObject:newPiece];
        [self removeChild:piece.sprite];
    }

    [self updateBoardAfterSwap:0.25];
}


#pragma mark - Touch handlers
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!touchesEnabled) return NO;
    
    // TODO: Start turn timer
    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    for (BoardPiece *piece in pieces)
    {
        // Not dragging a gem and touch location is the current piece
        if (!pieceBeingDragged && CGRectContainsPoint(piece.sprite.boundingBox, touchLocation))
        {
            pieceBeingDragged = [BoardPiece pieceWithType:piece.type];
            [pieceBeingDragged setPosition:piece.sprite.position];
            [self addChild:pieceBeingDragged.sprite];
            
            tmpPieceBeingDragged = piece;
            piece.sprite.opacity = 128;
            
            dragOffset = ccp(touchLocation.x - piece.boundingBox.origin.x - (kBoardPieceWidth/2),
                             touchLocation.y - piece.boundingBox.origin.y - (kBoardPieceHeight/2));
            
            [pieceBeingDragged.sprite setZOrder:10];
            
            NSLog(@"Started dragging piece");

            return YES;
        }
    }

    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!touchesEnabled) return;
        
    if (pieceBeingDragged)
    {
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        touchLocation.x -= dragOffset.x;
        touchLocation.y -= dragOffset.y;
        [pieceBeingDragged setPosition:touchLocation];
        
        // Do swap
        BoardPiece *swapPiece = nil;
        for (BoardPiece *piece in pieces)
        {
            if (piece != tmpPieceBeingDragged && piece.sprite.numberOfRunningActions == 0 && CGRectContainsPoint(piece.boundingBox, touchLocation))
            {
                swapPiece = piece;
                break;
            }
        }
        
        // We have a piece to swap with and we're not animating
        if (swapPiece && !isAnimatingSwap)
        {
            int swapPieceIndex = [pieces indexOfObject:swapPiece];
            int dragPieceIndex = [pieces indexOfObject:tmpPieceBeingDragged];
            
            [pieces replaceObjectAtIndex:swapPieceIndex withObject:tmpPieceBeingDragged];
            [pieces replaceObjectAtIndex:dragPieceIndex withObject:swapPiece];
            
            NSLog(@"Replaced %@ with %@", swapPiece, tmpPieceBeingDragged);
            
            [self updateBoardAfterSwap:0.05];
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self removeChild:pieceBeingDragged.sprite];
    tmpPieceBeingDragged.sprite.opacity = 255.0;
    tmpPieceBeingDragged = nil;
    pieceBeingDragged = nil;
    dragOffset = CGPointZero;
    [self turnEnded];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self ccTouchEnded:touch withEvent:event];
}

#pragma mark - Turn timer handler

- (void)update:(ccTime)delta
{
    [turnTimer setPercentage:turnTimer.percentage-(delta*20)];
    if (turnTimer.percentage <= 0)
    {
        // TODO: Implement dragging end trigger
        // [self endPieceDragging];
    }
}


- (void)printBoard
{
    NSString *boardString = @"\r\n";
    for (int y = rows-1; y >= 0; y--) {
        for (int x = columns-1; x >= 0; x--) {
            int pieceIndex = x+(y*columns);
            BoardPiece *thisPiece = pieces[pieceIndex];
            boardString = [boardString stringByAppendingString:[NSString stringWithFormat:@"%d", thisPiece.type]];
        }
        boardString = [boardString stringByAppendingString:@"\r\n"];
    }
    NSLog(@"%@", boardString);
}

- (NSMutableSet *)findMatchSetWithPiece:(BoardPiece *)piece
{
    for (NSMutableSet *matchSet in matches) {
        if ([[matchSet allObjects] indexOfObject:piece] != NSNotFound) {
            return matchSet;
        }
    }
    
    return nil;
}

@end
