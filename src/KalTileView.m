/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalImageManager.h"
#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"
#import <CoreText/CoreText.h>

extern const CGSize kTileSize;

// UIAppearanceContainer

static NSString *kAppearanceBackgroundImageAttribute      = @"backgroundImage";
static NSString *kAppearanceTextColorAttribute            = @"textColor";
static NSString *kAppearanceFontAttribute                 = @"font";
static NSString *kAppearanceShadowColorImageAttribute     = @"shadowColor";
static NSString *kAppearanceMarkerImageImageAttribute     = @"markerImage";
static NSString *kAppearanceShadowOffsetAttribute         = @"shadowOffset";
static NSString *kAppearanceReversesShadowImageAttribute  = @"reversesShadow";
static NSString *kAppearanceTextAlignmentAttribute        = @"textAlignment";
static NSString *kAppearanceEdgeInsetsAttribute           = @"edgeInsets";
static NSString *kAppearanceAdjacentHighlightColorAttribute = @"adjacentHighlightColor";




static NSMutableDictionary *defaultAppearance = nil;


// KalTileView

@interface KalTileView()
+ (void)setAppearance:(NSMutableDictionary *)appearance value:(id)value forKey:(NSString *)key state:(KalTileState)state;
+ (BOOL)appearance:(NSDictionary *)appearance hasValue:(id *)outValue forKey:(NSString *)key state:(KalTileState)state;
- (id)attributeForKey:(NSString *)key state:(KalTileState)state;
@end

@implementation KalTileView

@synthesize date;

+ (void)initialize
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    defaultAppearance = [[NSMutableDictionary alloc] init];
    
      /* Position */
      [self setAppearance:defaultAppearance
                    value:[NSValue valueWithUIEdgeInsets: UIEdgeInsetsMake(12, 5, 5, 5)]
                   forKey:kAppearanceEdgeInsetsAttribute
                    state:KalTileStateNormal];
      
      [self setAppearance:defaultAppearance
                    value:[NSNumber numberWithInteger: NSTextAlignmentCenter]
                   forKey:kAppearanceTextAlignmentAttribute
                    state:KalTileStateNormal];

    /* Background */
    [self setAppearance:defaultAppearance
                  value:[[KalImageManager imageNamed:@"kal_tile_today.png"]
                             stretchableImageWithLeftCapWidth:6
                             topCapHeight:0]
                 forKey:kAppearanceBackgroundImageAttribute
                  state:KalTileStateToday];
    
    [self setAppearance:defaultAppearance
                  value:[[KalImageManager imageNamed:@"kal_tile_today_selected.png"]
                             stretchableImageWithLeftCapWidth:6
                             topCapHeight:0]
                 forKey:kAppearanceBackgroundImageAttribute
                  state:KalTileStateToday | KalTileStateSelected];
    
    [self setAppearance:defaultAppearance
                  value:[[KalImageManager imageNamed:@"kal_tile_selected.png"]
                             stretchableImageWithLeftCapWidth:1
                             topCapHeight:0]
                 forKey:kAppearanceBackgroundImageAttribute
                  state:KalTileStateSelected];
    
    [self setAppearance:defaultAppearance
                  value:[UIColor colorWithPatternImage:
                            [KalImageManager imageNamed:@"kal_tile_text_fill.png"]]
                 forKey:kAppearanceTextColorAttribute
                  state:KalTileStateNormal];

    /* Font */
    [self setAppearance:defaultAppearance
                  value:[UIFont boldSystemFontOfSize:24.f]
                 forKey:kAppearanceFontAttribute
                  state:KalTileStateNormal];
    
    /* Text */
    [self setAppearance:defaultAppearance
                  value:[UIColor whiteColor]
                 forKey:kAppearanceTextColorAttribute
                  state:KalTileStateToday];
    
    [self setAppearance:defaultAppearance
                  value:[UIColor whiteColor]
                 forKey:kAppearanceTextColorAttribute
                  state:KalTileStateSelected];
    
    [self setAppearance:defaultAppearance
                  value:[UIColor colorWithPatternImage:
                            [KalImageManager imageNamed:@"kal_tile_dim_text_fill.png"]]
                 forKey:kAppearanceTextColorAttribute
                  state:KalTileStateAdjacent];
    
      /* Shadow */
    [self setAppearance:defaultAppearance
                  value:[UIColor whiteColor]
                 forKey:kAppearanceShadowColorImageAttribute
                  state:KalTileStateNormal];
    
    [self setAppearance:defaultAppearance
                  value:[UIColor blackColor]
                 forKey:kAppearanceShadowColorImageAttribute
                  state:KalTileStateToday];
    
    [self setAppearance:defaultAppearance
                  value:[UIColor blackColor]
                 forKey:kAppearanceShadowColorImageAttribute
                  state:KalTileStateSelected];
    
    [self setAppearance:defaultAppearance
                  value:nil
                 forKey:kAppearanceShadowColorImageAttribute
                  state:KalTileStateAdjacent];
    
      /* Shaow Offset */
      [self setAppearance:defaultAppearance
                    value:[NSValue valueWithCGPoint: CGPointMake( 0, 1) ]
                   forKey:kAppearanceShadowOffsetAttribute
                    state:KalTileStateNormal];

      /* Marker */
    [self setAppearance:defaultAppearance
                  value:[KalImageManager imageNamed:@"kal_marker.png"]
                 forKey:kAppearanceMarkerImageImageAttribute
                  state:KalTileStateNormal];
    
    [self setAppearance:defaultAppearance
                  value:[KalImageManager imageNamed:@"kal_marker_today.png"]
                 forKey:kAppearanceMarkerImageImageAttribute
                  state:KalTileStateToday];
    
    [self setAppearance:defaultAppearance
                  value:[KalImageManager imageNamed:@"kal_marker_selected.png"]
                 forKey:kAppearanceMarkerImageImageAttribute
                  state:KalTileStateSelected];
    
    [self setAppearance:defaultAppearance
                  value:[KalImageManager imageNamed:@"kal_marker_dim.png"]
                 forKey:kAppearanceMarkerImageImageAttribute
                  state:KalTileStateAdjacent];
      
      /* Highlight Color when clicking on a day in an adjacent month */
    [self setAppearance:defaultAppearance
                  value:[UIColor colorWithWhite:0.25f alpha:0.3f]
                 forKey:kAppearanceAdjacentHighlightColorAttribute
                  state:KalTileStateNormal];
  });
}

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    origin = frame.origin;
    [self setIsAccessibilityElement:YES];
    [self setAccessibilityTraits:UIAccessibilityTraitButton];
    appearance = [[NSMutableDictionary alloc] init];
    [self resetState];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
    KalTileState state = self.state;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIFont *font = [self fontForState:state];
    CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], font.pointSize, kCGEncodingMacRoman);
    
    CGContextTranslateCTM(ctx, 0, kTileSize.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    UIColor *textColor = [self textColorForState:state];
    UIColor *shadowColor = [self shadowColorForState:state];
    UIImage *markerImage = [self markerImageForState:state];
    UIImage *backgroundImage = [self backgroundImageForState:state];
    UIEdgeInsets insets = [self edgeInsets];
    UITextAlignment alignment = [self textAlignment];
    
    [backgroundImage drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
    
    if (flags.marked)
    {
        //      [markerImage drawInRect:CGRectMake(21.f, 5.f, 4.f, 5.f)];
        //      NSLog(@"Marker Image Size: h %d w %d", (int) markerImage.size.height,  (int)  markerImage.size.width);
        CGFloat markerLeft = (kTileSize.width / 2) - (markerImage.size.width / 2);
        
        CGRect markerDrawRect = CGRectMake(markerLeft, insets.bottom, markerImage.size.width, markerImage.size.height);
        [markerImage drawInRect: markerDrawRect];
        
        //      NSLog(@"Marker Draw Rect: x %d  y %d   w %d  h %d",
        //            (int) markerDrawRect.origin.x ,
        //            (int) markerDrawRect.origin.y ,
        //            (int) markerDrawRect.size.width,
        //            (int) markerDrawRect.size.height);
        //
        //      CGRect oldMarkerDrawRect = CGRectMake(21.f, 5.f, 4.f, 5.f);
        //      NSLog(@"Old    Draw Rect: x %d  y %d   w %d  h %d",
        //            (int) oldMarkerDrawRect.origin.x ,
        //            (int) oldMarkerDrawRect.origin.y ,
        //            (int) oldMarkerDrawRect.size.width,
        //            (int) oldMarkerDrawRect.size.height);
    }
    
    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    const char *day = [dayText cStringUsingEncoding:NSUTF8StringEncoding];
    CGSize textSize = [dayText sizeWithFont: font];
    
    // Use some CoreText functions to calculate the
    // exact height of the actual number font glyphs used.
    NSDictionary *dayTextAttributes = @{NSFontAttributeName: font};
    NSAttributedString *dayTextWithFont =
        [[NSAttributedString alloc] initWithString:dayText  attributes:dayTextAttributes];
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(dayTextWithFont));
    CGRect actualTextRect = CTLineGetImageBounds( line, ctx );
    CGSize actualTextSize = actualTextRect.size;
    
    CGFloat textX, textY;
    
    textY = (kTileSize.height - actualTextSize.height - insets.top);
    
    // Align Numbers Text
    textX = roundf(0.5f * (kTileSize.width - textSize.width)); // Centered and Justified
    if (alignment == NSTextAlignmentLeft) textX = insets.left;
    if (alignment == NSTextAlignmentRight)  textX = kTileSize.width - actualTextSize.width - insets.right;
    
    // Draw the Numbers Shadow
    if (shadowColor) {
        [shadowColor setFill];
        int sign = [self reversesShadowForState:state] ? -1 : 1;
        CGSize shadowOffset = [self shadowOffsetForState: state];
        CGContextShowTextAtPoint(ctx, textX + shadowOffset.width, textY - sign * shadowOffset.height, day, n >= 10 ? 2 : 1);
    }
    
    // Draw the Numbers Text
    [textColor setFill];
    CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
    
    // Highlighting an day of an adjacent month
    if (self.highlighted) {
        [self.adjacentHighlightColor setFill];
        CGContextFillRect(ctx, CGRectMake(0.f, 0.f, kTileSize.width, kTileSize.height));
    }
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  frame.origin = origin;
  frame.size = kTileSize;
  self.frame = frame;
  
  date = nil;
  flags.type = KalTileTypeRegular;
  flags.highlighted = NO;
  flags.selected = NO;
  flags.marked = NO;
}

- (void)setDate:(KalDate *)aDate
{
  if (date == aDate)
    return;

  date = aDate;

  [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
  if (flags.selected == selected)
    return;

  // workaround since I cannot draw outside of the frame in drawRect:
  if (![self isToday]) {
    CGRect rect = self.frame;
    if (selected) {
      rect.origin.x--;
      rect.size.width++;
      rect.size.height++;
    } else {
      rect.origin.x++;
      rect.size.width--;
      rect.size.height--;
    }
    self.frame = rect;
  }
  
  flags.selected = selected;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
  if (flags.highlighted == highlighted)
    return;
  
  flags.highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
  if (flags.marked == marked)
    return;
  
  flags.marked = marked;
  [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
  if (flags.type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
  CGRect rect = self.frame;
  if (tileType == KalTileTypeToday) {
    rect.origin.x--;
    rect.size.width++;
    rect.size.height++;
  } else if (flags.type == KalTileTypeToday) {
    rect.origin.x++;
    rect.size.width--;
    rect.size.height--;
  }
  self.frame = rect;
  
  flags.type = tileType;
  [self setNeedsDisplay];
}

- (KalTileState)state
{
    
    KalTileState currentState = KalTileStateNormal;
    
    if (flags.selected) currentState = (currentState | KalTileStateSelected);
    if (flags.highlighted) currentState = (currentState | KalTileStateHighlighted);
    if (flags.marked) currentState = (currentState | KalTileStateMarked);
    if (flags.type == KalTileTypeAdjacent) currentState = (currentState | KalTileStateAdjacent);
    if (flags.type == KalTileTypeToday) currentState = (currentState | KalTileStateToday);
    if (flags.type == (KalTileTypeAdjacent | KalTileTypeToday))
    {
        currentState = (currentState | KalTileStateAdjacent | KalTileStateToday);
    }
    
    return currentState;
}


- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }


#pragma mark -
#pragma mark Appearance

- (void)setBackgroundImage:(UIImage *)image forState:(KalTileState)state
{
  [KalTileView setAppearance:appearance
                       value:image
                      forKey:kAppearanceBackgroundImageAttribute
                       state:state];
  [self setNeedsDisplay];
}

- (void)setMarkerImage:(UIImage *)image forState:(KalTileState)state
{
  [KalTileView setAppearance:appearance
                       value:image
                      forKey:kAppearanceMarkerImageImageAttribute
                       state:state];
  [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)color forState:(KalTileState)state
{
  [KalTileView setAppearance:appearance
                       value:color
                      forKey:kAppearanceTextColorAttribute
                       state:state];
  [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font forState:(KalTileState)state
{
    [KalTileView setAppearance:appearance
                         value:font
                        forKey:kAppearanceFontAttribute
                         state:state];
    [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)color forState:(KalTileState)state
{
  [KalTileView setAppearance:appearance
                       value:color
                      forKey:kAppearanceShadowColorImageAttribute
                       state:state];
  [self setNeedsDisplay];
}

- (void)setShadowOffset:(CGSize)shadowOffset forState:(KalTileState)state
{
    [KalTileView setAppearance:appearance
                         value:[NSValue valueWithCGSize: shadowOffset]
                        forKey:kAppearanceShadowOffsetAttribute
                         state:state];
    [self setNeedsDisplay];
}

- (void)setReversesShadow:(NSInteger)flag forState:(KalTileState)state
{
    [KalTileView setAppearance:appearance
                         value:[NSNumber numberWithBool:flag]
                        forKey:kAppearanceReversesShadowImageAttribute
                         state:state];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [KalTileView setAppearance:appearance
                         value:[NSNumber numberWithInteger:textAlignment]
                        forKey:kAppearanceTextAlignmentAttribute
                         state:KalTileStateNormal];
    [self setNeedsDisplay];
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    [KalTileView setAppearance:appearance
                         value:[NSValue valueWithUIEdgeInsets:edgeInsets]
                        forKey:kAppearanceEdgeInsetsAttribute
                         state:KalTileStateNormal];
    [self setNeedsDisplay];
}

- (void)setAdjacentHighlightColor:(UIColor *)color
{
    [KalTileView setAppearance:appearance
                         value:color
                        forKey:kAppearanceAdjacentHighlightColorAttribute
                         state:KalTileStateNormal];
    [self setNeedsDisplay];
}

- (UIImage *)markerImageForState:(KalTileState)state
{
  return [self attributeForKey:kAppearanceMarkerImageImageAttribute state:state];
}

- (UIImage *)backgroundImageForState:(KalTileState)state
{
  return [self attributeForKey:kAppearanceBackgroundImageAttribute state:state];
}

- (UIColor *)textColorForState:(KalTileState)state
{
  return [self attributeForKey:kAppearanceTextColorAttribute state:state];
}

- (UIFont *)fontForState:(KalTileState)state
{
    return [self attributeForKey:kAppearanceFontAttribute state:state];
}

- (UIColor *)shadowColorForState:(KalTileState)state
{
    return [self attributeForKey:kAppearanceShadowColorImageAttribute state:state];
}

- (CGSize)shadowOffsetForState:(KalTileState)state
{
    return [[self attributeForKey:kAppearanceShadowOffsetAttribute state:state] CGSizeValue];
}

- (BOOL)reversesShadowForState:(KalTileState)state
{
  return [[self attributeForKey:kAppearanceReversesShadowImageAttribute state:state] boolValue];
}

- (NSTextAlignment)textAlignment
{
    return [[self attributeForKey:kAppearanceTextAlignmentAttribute state:KalTileStateNormal] integerValue];
}

- (UIEdgeInsets)edgeInsets
{
    return [[self attributeForKey:kAppearanceEdgeInsetsAttribute state:KalTileStateNormal] UIEdgeInsetsValue];
}

- (UIColor *)adjacentHighlightColor
{
    return [self attributeForKey:kAppearanceAdjacentHighlightColorAttribute state:KalTileStateNormal];
}


#pragma mark -

+ (void)setAppearance:(NSMutableDictionary *)appearance value:(id)value forKey:(NSString *)key state:(KalTileState)state
{
  NSMutableDictionary *valueForState = [appearance objectForKey:key];
  if (valueForState == nil) {
    valueForState = [NSMutableDictionary dictionary];
    [appearance setObject:valueForState forKey:key];
  }
  [valueForState setObject:(value ?: [NSNull null]) forKey:[NSNumber numberWithUnsignedInteger:state]];
}

+ (BOOL)appearance:(NSDictionary *)appearance hasValue:(id *)outValue forKey:(NSString *)key state:(KalTileState)state
{
  NSDictionary *valueForState = [appearance objectForKey:key];
  if (!valueForState) { return NO; }
  
  // Returns the attribute with the highest number of common bits with state
  int maxNumberOfBits = -1;
  id bestValue = nil;
  
  for (NSNumber *stateNumber in valueForState) {
    int storedState = [stateNumber intValue];
  
    // does state match?
    if ((storedState & state) != storedState) { continue; }
  
    // does state match more ?
    int numberOfBits;
    for (numberOfBits = 0; storedState; numberOfBits++) { storedState &= storedState - 1; }
    if (numberOfBits <= maxNumberOfBits) { continue; }
  
    // best result so far :-)
    maxNumberOfBits = numberOfBits;
    bestValue = [valueForState objectForKey:stateNumber];
  }
  
  if (bestValue == nil) {
    return NO;
  }
  
  if (outValue) {
    *outValue = (bestValue == [NSNull null]) ? nil : bestValue;
  }
  return YES;
}

- (id)attributeForKey:(NSString *)key state:(KalTileState)state
{
  id value;
  
  if ([KalTileView appearance:appearance hasValue:&value forKey:key state:state]) {
    return value;
  }
  
  if ([KalTileView appearance:defaultAppearance hasValue:&value forKey:key state:state]) {
    return value;
  }
  
  return nil;
}


@end
