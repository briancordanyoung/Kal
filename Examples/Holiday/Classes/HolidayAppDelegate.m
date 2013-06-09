/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "HolidayAppDelegate.h"
#import "HolidaySqliteDataSource.h"
#import "HolidaysDetailViewController.h"
#import "Kal.h"
#import "KalTileView.h"
#import "KalView.h"

@implementation HolidayAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
    
    /*
     * Kal supports using UIAppearance proxy to customize the entire look of the
     * control. Examples:
     */
    //    id kalViewAppearance = [KalView appearance];
    //    [kalViewAppearance setHeaderFont:[UIFont fontWithName:@"AmericanTypewriter" size: 20]];
    //    [kalViewAppearance setWeekdayFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size: 10]];
    //    [kalViewAppearance setHeaderShadowColor:[UIColor colorWithWhite:1.000 alpha:1.000]];
    
    
    
    //    id kalTileViewAppearance = [KalTileView appearance];
    //
    //    [kalTileViewAppearance setTextAlignment: UITextAlignmentLeft];
    //    [kalTileViewAppearance setEdgeInsets: UIEdgeInsetsMake(5, 5, 0, 7)];
    //    [kalTileViewAppearance setAdjacentHighlightColor: [UIColor colorWithWhite:0.289 alpha:0.210]];
    //
    //    [kalTileViewAppearance setShadowOffset: CGSizeMake(0, 5)
    //                                  forState: KalTileStateNormal];
    //    [kalTileViewAppearance setFont:[UIFont fontWithName:@"AmericanTypewriter" size: 10]
    //                          forState:KalTileTypeRegular];
    //    [kalTileViewAppearance setTextColor:[UIColor colorWithWhite:0.7 alpha:1]
    //                               forState:KalTileStateAdjacent];
    //    [kalTileViewAppearance setTextColor:[UIColor colorWithRed:0.275 green:1.000 blue:0.000 alpha:1.000]
    //                               forState:KalTileStateMarked];
    //    [kalTileViewAppearance setTextColor:[UIColor colorWithRed:0.000 green:0.988 blue:1.000 alpha:1.000]
    //                               forState:KalTileStateMarked | KalTileStateSelected];
    //    [kalTileViewAppearance setTextColor:[UIColor whiteColor]
    //                               forState:KalTileStateAdjacent | KalTileStateSelected];
    //    UIColor *todayTextColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_text_fill.png"]];
    //    [kalTileViewAppearance setTextColor:todayTextColor
    //                               forState:KalTileStateToday];
    //    [kalTileViewAppearance setTextColor:[UIColor colorWithRed:1.000 green:0.000 blue:0.165 alpha:1.000]
    //                               forState:KalTileStateToday | KalTileStateSelected];
    //
    //    [kalTileViewAppearance setShadowColor:[UIColor whiteColor]
    //                                 forState:KalTileStateToday];
    //    [kalTileViewAppearance setShadowColor:[UIColor colorWithWhite:0 alpha:0.2]
    //                                 forState:KalTileStateSelected];
    //    [kalTileViewAppearance setShadowColor:[UIColor colorWithWhite:0 alpha:0.2]
    //                                 forState:KalTileStateToday | KalTileStateSelected];
    //
    //    [kalTileViewAppearance setReversesShadow:YES
    //                                    forState:KalTileStateSelected];

    
    
    
  /*
   *    Kal Initialization
   *
   * When the calendar is first displayed to the user, Kal will automatically select today's date.
   * If your application requires an arbitrary starting date, use -[KalViewController initWithSelectedDate:]
   * instead of -[KalViewController init].
   */
    
  NSDate *aDayWithMarkers = [NSDate dateWithTimeIntervalSince1970: 1323216000];
  kal = [[KalViewController alloc] initWithSelectedDate: aDayWithMarkers];
  kal.title = @"Holidays";

  /*
   *    Kal Configuration
   *
   * This demo app includes 2 example datasources for the Kal component. Both datasources
   * contain 2009-2011 holidays, however, one datasource retrieves the data
   * from a remote web server using JSON while the other datasource retrieves the data
   * from a local Sqlite database. For this demo, I am going to set it up to just use
   * the Sqlite database.
   */
  kal.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(showAndSelectToday)];
  kal.delegate = self;
  dataSource = [[HolidaySqliteDataSource alloc] init];
  kal.dataSource = dataSource;

  
  // Setup the navigation stack and display it.
  navController = [[UINavigationController alloc] initWithRootViewController:kal];
  [window addSubview:navController.view];
  [window makeKeyAndVisible];
}

// Action handler for the navigation bar's right bar button item.
- (void)showAndSelectToday
{
  [kal showAndSelectDate:[NSDate date]];
}

#pragma mark UITableViewDelegate protocol conformance

// Display a details screen for the selected holiday/row.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Holiday *holiday = [dataSource holidayAtIndexPath:indexPath];
  HolidaysDetailViewController *vc = [[HolidaysDetailViewController alloc] initWithHoliday:holiday];
  [navController pushViewController:vc animated:YES];
}

#pragma mark -


@end
