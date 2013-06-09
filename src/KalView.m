/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

static NSString *kAppearancePreviousMonthButtonImageAttribute  = @"previousMonthButtonImage";
static NSString *kAppearanceNextMonthButtonImageAttribute      = @"nextMonthButtonImage";

static NSString *kAppearanceHeaderBackgroundImageAttribute     = @"headerBackgroundImage";

static NSString *kAppearanceHeaderFontAttribute                = @"headerFont";
static NSString *kAppearanceHeaderTextColorAttribute           = @"headerTextColor";
static NSString *kAppearanceHeaderShadowColorAttribute         = @"headerShadowColor";
static NSString *kAppearanceHeaderShadowOffsetAttribute        = @"headerShadowOffset";

static NSString *kAppearanceWeekdayFontAttribute               = @"weekdayFont";
static NSString *kAppearanceWeekdayTextColorAttribute          = @"weekdayTextColor";
static NSString *kAppearanceWeekdayShadowColorAttribute        = @"weekdayShadowColor";
static NSString *kAppearanceWeekdayShadowOffsetAttribute       = @"weekdayShadowOffset";

static NSString *kAppearanceFooterShadowImageAttribute         = @"footerShadowImage";


static NSMutableDictionary *defaultAppearance = nil;


@interface KalView ()
- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;
@end

// TODO: Make the headerView height adjustable
static const CGFloat kHeaderHeight = 44.f;
static const CGFloat kMonthLabelHeight = 17.f;

@implementation KalView

@synthesize delegate, tableView;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        defaultAppearance = [NSMutableDictionary new];
        
        /* Header */
        [self setAppearance:defaultAppearance
                      value:[KalImageManager imageNamed:@"kal_left_arrow.png"]
                     forKey:kAppearancePreviousMonthButtonImageAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[KalImageManager imageNamed:@"kal_right_arrow.png"]
                     forKey:kAppearanceNextMonthButtonImageAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[KalImageManager imageNamed:@"kal_grid_background.png"]
                     forKey:kAppearanceHeaderBackgroundImageAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[UIFont boldSystemFontOfSize:22.f]
                     forKey:kAppearanceHeaderFontAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[UIColor colorWithPatternImage:[KalImageManager imageNamed:@"kal_header_text_fill.png"]]
                     forKey:kAppearanceHeaderTextColorAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[UIColor whiteColor]
                     forKey:kAppearanceHeaderShadowColorAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[NSValue valueWithCGSize: CGSizeMake(0.f, 1.f)]
                     forKey:kAppearanceHeaderShadowOffsetAttribute];
        
        /* Weekday */
        [self setAppearance:defaultAppearance
                      value:[UIFont boldSystemFontOfSize:10.f]
                     forKey:kAppearanceWeekdayFontAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f]
                     forKey:kAppearanceWeekdayTextColorAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[UIColor whiteColor]
                     forKey:kAppearanceWeekdayShadowColorAttribute];
        
        [self setAppearance:defaultAppearance
                      value:[NSValue valueWithCGSize: CGSizeMake(0.f, 1.f) ]
                     forKey:kAppearanceWeekdayShadowOffsetAttribute];
        

        /* Shadow Below Calendar */
        [self setAppearance:defaultAppearance
                      value:[KalImageManager imageNamed:@"kal_grid_shadow.png"]
                     forKey:kAppearanceFooterShadowImageAttribute];
    });
}

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
  if ((self = [super initWithFrame:frame])) {
    delegate = theDelegate;
    logic = theLogic;
    [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    appearance = [NSMutableDictionary new];

      
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, kHeaderHeight)];
    headerView.backgroundColor = [UIColor grayColor];
    [self addSubviewsToHeaderView:headerView];
    [self addSubview:headerView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, frame.size.width, frame.size.height - kHeaderHeight)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubviewsToContentView:contentView];
    [self addSubview:contentView];
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
  return nil;
}

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)slideDown { [gridView slideDown]; }
- (void)slideUp { [gridView slideUp]; }

- (void)showPreviousMonth
{
  if (!gridView.transitioning)
    [delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
  if (!gridView.transitioning)
    [delegate showFollowingMonth];
}

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
  const CGFloat kChangeMonthButtonWidth = 46.0f;
  const CGFloat kChangeMonthButtonHeight = 30.0f;
  const CGFloat kMonthLabelWidth = 200.0f;
  const CGFloat kHeaderVerticalAdjust = 3.f;
  
  // Header background gradient
  backgroundView = [[UIImageView alloc] initWithImage:[self headerBackgroundImage]];
  CGRect imageFrame = headerView.frame;
  imageFrame.origin = CGPointZero;
  backgroundView.frame = imageFrame;
  [headerView addSubview:backgroundView];
  
  // Create the previous month button on the left side of the view
  CGRect previousMonthButtonFrame = CGRectMake(self.left,
                                               kHeaderVerticalAdjust,
                                               kChangeMonthButtonWidth,
                                               kChangeMonthButtonHeight);
  previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
  [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
  [previousMonthButton setImage:[self previousMonthButtonImage] forState:UIControlStateNormal];
  previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:previousMonthButton];
  
  // Draw the selected month name centered and at the top of the view
  CGRect monthLabelFrame = CGRectMake((self.width/2.0f) - (kMonthLabelWidth/2.0f),
                                      kHeaderVerticalAdjust,
                                      kMonthLabelWidth,
                                      kMonthLabelHeight);
  headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
  headerTitleLabel.backgroundColor = [UIColor clearColor];
  headerTitleLabel.font = [self headerFont];
    // TODO: center label vertically based on font size
  headerTitleLabel.textAlignment = UITextAlignmentCenter;
  headerTitleLabel.textColor = [self headerTextColor];
  headerTitleLabel.shadowColor = [self headerShadowColor];
  headerTitleLabel.shadowOffset = [self headerShadowOffset];
  [self setHeaderTitleText:[logic selectedMonthNameAndYear]];
  [headerView addSubview:headerTitleLabel];
  
  // Create the next month button on the right side of the view
  CGRect nextMonthButtonFrame = CGRectMake(self.width - kChangeMonthButtonWidth,
                                           kHeaderVerticalAdjust,
                                           kChangeMonthButtonWidth,
                                           kChangeMonthButtonHeight);
  nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
  [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
  [nextMonthButton setImage:[self nextMonthButtonImage] forState:UIControlStateNormal];
  nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
  nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:nextMonthButton];
  
  // Add column labels for each weekday (adjusting based on the current locale's first weekday)
  NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
  NSArray *fullWeekdayNames = [[[NSDateFormatter alloc] init] standaloneWeekdaySymbols];
  NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
  NSUInteger i = firstWeekday - 1;
    
  NSMutableArray *weekdayLabelList = [NSMutableArray new];
  for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += 46.f, i = (i+1)%7) {
    CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, kHeaderHeight - 29.f);
    UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
    weekdayLabel.backgroundColor = [UIColor clearColor];
    weekdayLabel.font = [self weekdayFont];
    weekdayLabel.textAlignment = UITextAlignmentCenter;
    weekdayLabel.textColor = [self weekdayTextColor];
    weekdayLabel.shadowColor = [self weekdayShadowColor];
    weekdayLabel.shadowOffset = [self weekdayShadowOffset];
    weekdayLabel.text = weekdayNames[i];
    [weekdayLabel setAccessibilityLabel:fullWeekdayNames[i]];
    [headerView addSubview:weekdayLabel];
    [weekdayLabelList addObject: weekdayLabel];
  }
  weekdayLabels = [NSArray arrayWithArray: weekdayLabelList];
}

- (void)addSubviewsToContentView:(UIView *)contentView
{
  // Both the tile grid and the list of events will automatically lay themselves
  // out to fit the # of weeks in the currently displayed month.
  // So the only part of the frame that we need to specify is the width.
  CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, 0.f);

  // The tile grid (the calendar body)
  gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:delegate];
  [gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
  [contentView addSubview:gridView];

  // The list of events for the selected day
  tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
  tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [contentView addSubview:tableView];
  
  // Drop shadow below tile grid and over the list of events for the selected day
  shadowView = [[UIImageView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
  shadowView.image = [self footerShadowImage];
  shadowView.height = shadowView.image.size.height;
  [contentView addSubview:shadowView];
  
  // Trigger the initial KVO update to finish the contentView layout
  [gridView sizeToFit];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object == gridView && [keyPath isEqualToString:@"frame"]) {
    
    /* Animate tableView filling the remaining space after the
     * gridView expanded or contracted to fit the # of weeks
     * for the month that is being displayed.
     *
     * This observer method will be called when gridView's height
     * changes, which we know to occur inside a Core Animation
     * transaction. Hence, when I set the "frame" property on
     * tableView here, I do not need to wrap it in a
     * [UIView beginAnimations:context:].
     */
    CGFloat gridBottom = gridView.top + gridView.height;
    CGRect frame = tableView.frame;
    frame.origin.y = gridBottom;
    frame.size.height = tableView.superview.height - gridBottom;
    tableView.frame = frame;
    shadowView.top = gridBottom;
    
  } else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"]) {
    [self setHeaderTitleText:change[NSKeyValueChangeNewKey]];
    
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)setHeaderTitleText:(NSString *)text
{
  [headerTitleLabel setText:text];
  [headerTitleLabel sizeToFit];
  headerTitleLabel.left = floorf(self.width/2.f - headerTitleLabel.width/2.f);
}

- (void)jumpToSelectedMonth { [gridView jumpToSelectedMonth]; }

- (void)selectDate:(KalDate *)date { [gridView selectDate:date]; }

- (BOOL)isSliding { return gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates { [gridView markTilesForDates:dates]; }

- (KalDate *)selectedDate { return gridView.selectedDate; }

- (void)dealloc
{
  [logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
  
  [gridView removeObserver:self forKeyPath:@"frame"];
}






#pragma mark - Appearance


- (void)setHeaderBackgroundImage:(UIImage *)image
{
    [KalView setAppearance:appearance
                     value:image
                    forKey:kAppearanceHeaderBackgroundImageAttribute];
    backgroundView.image = image;
}

- (void)setPreviousMonthButtonImage:(UIImage *)image
{
    [KalView setAppearance:appearance
                     value:image
                    forKey:kAppearancePreviousMonthButtonImageAttribute];
    previousMonthButton.imageView.image = image;
}

- (void)setNextMonthButtonImage:(UIImage *)image
{
    [KalView setAppearance:appearance
                     value:image
                    forKey:kAppearanceNextMonthButtonImageAttribute];
    nextMonthButton.imageView.image = image;
}



- (void)setHeaderFont:(UIFont *)font
{
    [KalView setAppearance:appearance
                     value:font
                    forKey:kAppearanceHeaderFontAttribute];
    headerTitleLabel.font = font;
}

- (void)setHeaderTextColor:(UIColor *)color
{
    [KalView setAppearance:appearance
                     value:color
                    forKey:kAppearanceHeaderTextColorAttribute];
    headerTitleLabel.textColor = color;
}

- (void)setHeaderShadowColor:(UIColor *)color
{
    [KalView setAppearance:appearance
                     value:color
                    forKey:kAppearanceHeaderShadowColorAttribute];
    headerTitleLabel.shadowColor = color;
}

- (void)setHeaderShadowOffset:(CGSize)offset
{
    [KalView setAppearance:appearance
                     value:[NSValue valueWithCGSize: offset]
                    forKey:kAppearanceHeaderShadowOffsetAttribute];
    headerTitleLabel.shadowOffset = offset;
}


- (void)setWeekdayFont:(UIFont *)font
{
    [KalView setAppearance:appearance
                     value:font
                    forKey:kAppearanceWeekdayFontAttribute];
    for (UILabel *label in weekdayLabels)    label.font = font;
}

- (void)setWeekdayTextColor:(UIColor *)color
{
    [KalView setAppearance:appearance
                     value:color
                    forKey:kAppearanceWeekdayTextColorAttribute];
    for (UILabel *label in weekdayLabels)    label.textColor = color;
}

- (void)setWeekdayShadowColor:(UIColor *)color
{
    [KalView setAppearance:appearance
                     value:color
                    forKey:kAppearanceWeekdayShadowColorAttribute];
    for (UILabel *label in weekdayLabels)    label.shadowColor = color;
}

- (void)setWeekdayShadowOffset:(CGSize)offset
{
    [KalView setAppearance:appearance
                     value:[NSValue valueWithCGSize: offset]
                    forKey:kAppearanceWeekdayShadowOffsetAttribute];
    for (UILabel *label in weekdayLabels)    label.shadowOffset = offset;
}

- (void)setFooterShadowImage:(UIImage *)image
{
    [KalView setAppearance:appearance
                     value:image
                    forKey:kAppearanceFooterShadowImageAttribute];
    backgroundView.image = image;
    shadowView.image = image;
    shadowView.height = shadowView.image.size.height;
}



- (UIImage *)previousMonthButtonImage
{
    return [self attributeForKey:kAppearancePreviousMonthButtonImageAttribute];
}

- (UIImage *)nextMonthButtonImage
{
    return [self attributeForKey:kAppearanceNextMonthButtonImageAttribute];
}

- (UIImage *)headerBackgroundImage
{
    return [self attributeForKey:kAppearanceHeaderBackgroundImageAttribute];
}

- (UIFont *)headerFont
{
    return [self attributeForKey:kAppearanceHeaderFontAttribute];
}

- (UIColor *)headerTextColor
{
    return [self attributeForKey:kAppearanceHeaderTextColorAttribute];
}

- (UIColor *)headerShadowColor
{
    return [self attributeForKey:kAppearanceHeaderShadowColorAttribute];
}

- (CGSize)headerShadowOffset
{
    return [[self attributeForKey:kAppearanceHeaderShadowOffsetAttribute] CGSizeValue];
}

- (UIFont *)weekdayFont
{
    return [self attributeForKey:kAppearanceWeekdayFontAttribute];
}

- (UIColor *)weekdayTextColor
{
    return [self attributeForKey:kAppearanceWeekdayTextColorAttribute];
}

- (UIColor *)weekdayShadowColor
{
    return [self attributeForKey:kAppearanceWeekdayShadowColorAttribute];
}

- (CGSize)weekdayShadowOffset
{
    return [[self attributeForKey:kAppearanceWeekdayShadowOffsetAttribute] CGSizeValue];
}

- (UIImage *)footerShadowImage
{
    return [self attributeForKey:kAppearanceFooterShadowImageAttribute];
}


#pragma mark -

+ (void)setAppearance:(NSMutableDictionary *)appearance value:(id)value forKey:(NSString *)key
{
    if (value)
    {
        [appearance setObject:value forKey:key];
    } else {
        [appearance removeObjectForKey:key];
    }
}

+ (BOOL)appearance:(NSDictionary *)appearance hasValue:(id *)outValue forKey:(NSString *)key
{
    id value = [appearance objectForKey:key];
    if (!value) { return NO; }
        
    if (outValue) {
        *outValue = value;
    }
    return YES;
}

- (id)attributeForKey:(NSString *)key
{
    id value;
    
    if ([KalView appearance:appearance hasValue:&value forKey:key]) {
        return value;
    }
    
    if ([KalView appearance:defaultAppearance hasValue:&value forKey:key]) {
        return value;
    }
    
    return nil;
}


@end


