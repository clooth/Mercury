//
//  BoardPiece.h
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#pragma mark - Different board piece types
typedef NS_ENUM(int, BoardPieceType) {
    PieceTypeWater = 1,
    PieceTypeGrass,
    PieceTypeFire,
    PieceTypeHoly,
    PieceTypeDark,
    PieceTypeHealth,
    PieceTypeInvalid
};

@interface BoardPiece : NSObject

@property (nonatomic, strong) CCSprite *sprite;
@property BoardPieceType type;

+ (BoardPiece *)pieceWithType:(BoardPieceType)type;
+ (BoardPiece *)randomPiece;

- (BOOL)matchesType:(BoardPieceType)type;
- (BOOL)matchesTypeOf:(BoardPiece *)piece;

// cocos2d proxies
- (void)setPosition:(CGPoint)position;
- (CCAction *)runAction:(CCAction *)action;

- (CGRect)boundingBox;

@end

