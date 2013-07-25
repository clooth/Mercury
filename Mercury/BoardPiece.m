//
//  BoardPiece.m
//  Mercury
//
//  Created by Nico Hämäläinen on 7/17/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "BoardPiece.h"

@implementation BoardPiece

+ (BoardPiece *)pieceWithType:(BoardPieceType)type
{
    BoardPiece *piece = [[BoardPiece alloc] init];
    piece.type = type;
    
    // Sprite
    switch (type)
    {
        case PieceTypeWater:
            piece.sprite = [CCSprite spriteWithFile:@"Assets/Sprites/water.png"];
            break;
            
        case PieceTypeGrass:
            piece.sprite = [CCSprite spriteWithFile:@"Assets/Sprites/grass.png"];
            break;
            
        case PieceTypeFire:
            piece.sprite = [CCSprite spriteWithFile:@"Assets/Sprites/fire.png"];
            break;
            
        case PieceTypeHoly:
            piece.sprite = [CCSprite spriteWithFile:@"Assets/Sprites/light.png"];
            break;
            
        case PieceTypeDark:
            piece.sprite = [CCSprite spriteWithFile:@"Assets/Sprites/dark.png"];
            break;

        case PieceTypeHealth:
            piece.sprite = [CCSprite spriteWithFile:@"Assets/Sprites/health.png"];
            break;
            
        default:
            [NSException raise:@"Invalid Board Piece value" format:@"Value of %d is invalid", type];
            break;
    }
    
    piece.sprite.zOrder = 9;
    
    return piece;
}

+ (BoardPiece *)randomPiece
{
    BoardPieceType randomType = (BoardPieceType) [NSNumber randomNumberBetween:1 to:PieceTypeInvalid-1];
    BoardPiece *piece = [BoardPiece pieceWithType:randomType];
    return piece;
}

- (void)setPosition:(CGPoint)position
{
    [self.sprite setPosition:position];
}

- (BOOL)matchesType:(BoardPieceType)type
{
    return (self.type == type);
}

- (BOOL)matchesTypeOf:(BoardPiece *)piece
{
    return [self matchesType:piece.type];
}

- (CCAction *)runAction:(CCAction *)action
{
    return [self.sprite runAction:action];
}

- (CGRect)boundingBox
{
    return self.sprite.boundingBox;
}

@end

