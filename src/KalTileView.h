/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

enum {
  KalTileTypeRegular   = 0,
  KalTileTypeAdjacent  = 1 << 0,
  KalTileTypeToday     = 1 << 1,
};
typedef char KalTileType;

enum {
  KalTileStateNormal      = 0,
  KalTileStateAdjacent    = 1 << 0,
  KalTileStateToday       = 1 << 1,
  KalTileStateSelected    = 1 << 2,
  KalTileStateHighlighted = 1 << 3,
  KalTileStateMarked      = 1 << 4,
};
typedef NSUInteger KalTileState;

@class KalDate;

@interface KalTileView : UIView <UIAppearanceContainer>
{
  KalDate *date;
  CGPoint origin;
  NSMutableDictionary *appearance;
  struct {
    unsigned int selected : 1;
    unsigned int highlighted : 1;
    unsigned int marked : 1;
    unsigned int type : 2;
  } flags;
}

@property (nonatomic, strong) KalDate *date;
@property (nonatomic) KalTileType type;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isMarked) BOOL marked;
@property (nonatomic, getter=isToday, readonly) BOOL today;
@property (nonatomic, readonly) BOOL belongsToAdjacentMonth;
@property (nonatomic, readonly) KalTileState state;

- (void)resetState;

// NSInteger instead of BOOL, in order to comply with the UIAppearanceContainer constraints
- (void)setReversesShadow:(NSInteger)flag
				 forState:(KalTileState)state UI_APPEARANCE_SELECTOR;

// an image that will be drawn at size {47,45}
- (void)setBackgroundImage:(UIImage *)image
				  forState:(KalTileState)state UI_APPEARANCE_SELECTOR;

// an image that will be drawn at size {4,5}
- (void)setMarkerImage:(UIImage *)image
			  forState:(KalTileState)state UI_APPEARANCE_SELECTOR;

- (void)setTextColor:(UIColor *)color
			forState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (void)setFont:(UIFont *)font forState:(KalTileState)state;
- (void)setShadowColor:(UIColor *)color
			  forState:(KalTileState)state UI_APPEARANCE_SELECTOR;

- (void)setShadowOffset:(CGSize)shadowOffset
               forState:(KalTileState)state UI_APPEARANCE_SELECTOR;

- (void)setTextAlignment:(NSTextAlignment)textAlignment UI_APPEARANCE_SELECTOR;
- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets UI_APPEARANCE_SELECTOR;
- (void)setAdjacentHighlightColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (BOOL)reversesShadowForState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)backgroundImageForState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)markerImageForState:(KalTileState)state UI_APPEARANCE_SELECTOR;        
- (UIColor *)textColorForState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (UIColor *)shadowColorForState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (UIFont *)fontForState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (CGSize)shadowOffsetForState:(KalTileState)state UI_APPEARANCE_SELECTOR;
- (NSTextAlignment)textAlignment UI_APPEARANCE_SELECTOR;
- (UIEdgeInsets)edgeInsets UI_APPEARANCE_SELECTOR;
- (UIColor *)adjacentHighlightColor UI_APPEARANCE_SELECTOR;

@end
