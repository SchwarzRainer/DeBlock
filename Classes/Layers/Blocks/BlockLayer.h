/*
 * This file is part of Deblock.
 *
 *  Deblock is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Deblock is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Deblock in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  BlockLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//


typedef enum DMBlockType {
    DMBlockTypeOne,
    DMBlockTypeTwo,
    DMBlockTypeThree,
    DMBlockTypeFour,
    DMBlockTypeFive,
    DMBlockTypeCount,
    DMBlockTypeSpecial,
    DMBlockTypeFrozen,
} DMBlockType;

@class FieldLayer;

@interface BlockLayer : Layer<CocosNodeRGBA> {

@protected
    Texture2D                                   **textures;

@private
    DMBlockType                                 type;
    BOOL                                        destroyed;
    BOOL                                        destructible;
    
    NSInteger                                   targetRow, targetCol;
    NSUInteger                                  frames, frame;
    ccColor4B                                   blockColor;
    ccColor4F                                   modColor;
    
    IntervalAction                              *moveAction;
    Label                                       *label;
    
    ParticleSystem                              *dropEmitter;
}

@property (readwrite) DMBlockType               type;
@property (readwrite) BOOL                      destroyed;
/** Indicates whether this block can be destroyed when it is valid. */
@property (readwrite) BOOL                      destructible;
/** Indicates whether the conditions on this block mean algorithms should not considder it for destruction. */
@property (readonly) BOOL                       valid;
@property (readonly) BOOL                       needsLinksToDestroy;
@property (readwrite, retain) IntervalAction    *moveAction;

@property (readwrite) NSInteger                 targetRow;
@property (readwrite) NSInteger                 targetCol;

@property (readwrite) NSUInteger                frame;
@property (readonly) NSUInteger                 frames;
@property (readwrite) ccColor4F                 modColor;

+ (NSUInteger)minimumLevel;
+ (id)randomBlockForLevel:(NSUInteger)level withSize:(CGSize)size;
+ (ccColor4B)colorForType:(DMBlockType)aType;

- (id)initWithBlockSize:(CGSize)size;

+ (DMBlockType)randomType;
- (NSString *)labelString;
- (BOOL)moving;

- (NSMutableSet *)findLinkedBlocksInField:(FieldLayer *)field
                                    atRow:(NSInteger)aRow col:(NSInteger)aCol;
- (NSMutableSet *)findAdjecentBlocksInField:(FieldLayer *)field
                                      atRow:(NSInteger)aRow col:(NSInteger)aCol;
- (void)getLinksInField:(FieldLayer *)aField toSet:(NSMutableSet *)allLinkedBlocks
                recurse:(BOOL)recurse specialLinks:(BOOL)specialLinks;

- (void)blink;
- (void)crumble;

- (void)notifyDropped;
- (void)notifyCollapsed;
- (void)notifyDestroyed;

@end