Kal - a calendar component for the iPhone
-----------------------------------------
![](http://farm9.staticflickr.com/8308/7898361456_debb9e2695.jpg)

This project aims to provide an open-source implementation of the month view in Apple's mobile calendar app (MobileCal). Using the UIAppearance proxy, the look can also be completely customized.  When the user taps a day on the calendar, any associated data for that day will be displayed in a table view directly below the calendar. As a client of the Kal component, you have 2 responsibilities:

1. Tell Kal which days need to be marked with a dot because they have associated data.
2. Provide UITableViewCells which display the details (if any) for the currently selected day.

In order to use Kal in your application, you will need to provide an implementation of the KalDataSource protocol to satisfy these responsibilities. Please see KalDataSource.h and the included demo app for more details.

Roadmap
-------------
**June 9, 2013**

For my purposes, I would like to be able to add multiple markers that are laid out in each tile. I want to try to keep the API consistant with the Kal project, but I haven't worked out if that's going to be a good idea yet.  The default look of Kal should always remain the Month View in Apple's Calendar app.

Release Notes
-------------

**June 9, 2013**

Bringing Kal in to the modern iOS age, requiring iOS 6

* Refactored to modern Objective-C 2.0
* Refactored to ARC
* CoreText Framework is now required.  It is used in implementing KalTileView textAlignment and edgeInsets.
* Pulled in [pegli/Kal image_manager branch](https://github.com/pegli/Kal/commits/image_manager) (at 5/8/13) 
    * adds a simple KalImageManager class to centralize how the path to an image is contructed.
    * adds kKalNotificationSelectedDate notification.
* Kal now better supports storyboards with the addition of `-(id)initWithCoder:` to KalViewController
    * It is still better to create an instance programmatically within another UIViewController so that you can use  `initWithSelectedDate:` and build it first with the correct date.  Once an instance is created, I couldn't change the date AND have it draw correctly, until it was first visable.
* Pulled in [peirlis/Kal UIAppearance branch](https://github.com/pierlis/Kal/commit/UIAppearance) (at 11/23/2012)
    * KalTileView now conforms to UIAppearanceContainer
    * Fixed bug from [peirlis/Kal UIAppearance branch](https://github.com/pierlis/Kal/commit/UIAppearance): `-(KalTileState)state:`  returned incorrect state
* Added more customizations for KalTileView. See updated "Holiday" example app for full UIAppearance example code:
    * `setTextAlignment:`
    * `setEdgeInsets:`
    * `setAdjacentHighlightColor:`
    * `setShadowOffset:forState:`
    * `setFont:forState:`
    * `setTextColor:forState:` from [peirlis/Kal UIAppearance branch](https://github.com/pierlis/Kal/commit/UIAppearance) 
    * `setShadowColor:forState:` from [peirlis/Kal UIAppearance branch](https://github.com/pierlis/Kal/commit/UIAppearance) 
    * `setReversesShadow:forState:` from [peirlis/Kal UIAppearance branch](https://github.com/pierlis/Kal/commit/UIAppearance)
* Added customizations for KalView
    * `setHeaderBackgroundImage:`
    * `setPreviousMonthButtonImage:`
    * `setNextMonthButtonImage:`
    * `setHeaderFont:`
    * `setHeaderTextColor:`
    * `setHeaderShadowColor:`
    * `setHeaderShadowOffset:`
    * `setWeekdayFont:`
    * `setWeekdayTextColor:`
    * `setWeekdayShadowColor:`
    * `setWeekdayShadowOffset:`
    * `setFooterShadowImage:`
* Appearance and customizations todos:
    * I would like to add custmisation methods for the last 2 UIImages that can not be overriden from outside Kal
	    * kal_grid_background.png (KalGridView.m)
	    * kal_tile.png (KalMonthView.m)
    * It might be nice to allow the header height to be set
        * The headerTitleLabel frame needs to be set better based on the header height and font.

**June 21, 2012**

Today I added VoiceOver/Accessibility support. Special thanks to Matt Gemmell's [excellent article](http://mattgemmell.com/2010/12/19/accessibility-for-iphone-and-ipad-apps/) on adding accessibility support to your iPhone app. I wish I would have done this a long time ago.

If your app is localized, then you will also want to localize the 4 new accessibility strings that I added in this release: "Previous month", "Next month", "Marked" and "Today".

**July 9, 2010**

This is the iOS 4.0 / iPhone4 release. New features include:

1) A refactored project file. Kal is now built as a static library in a separate Xcode project. Regardless of whether you are a new or existing user of Kal, please read the section entitled "Integrating Kal into Your Project" below.

2) The project now specifies iOS 4.0 as the Base SDK. So if you want to upgrade to this release of Kal, you must upgrade your SDK.

3) Added hi-res graphics for Retina Display support. Extra special thanks to Paul Calnan for sending me the hi-res graphics.

4) Added a new example app, "NativeCal," which demonstrates how to integrate Kal with the EventKit framework that Apple made available in iOS 4.

**NOTE** I'm not crazy about the KalDataSource asynchronous/synchronous API. I will probably be changing it in the future and updating the example apps to use GCD and blocks.

**March 11, 2010**

A lot of people have emailed me asking for support for selecting and displaying an arbitrary date on the calendar. So today I pushed some commits that make this easy to do. You can specify which date should be initially selected and shown when the calendar is first created by using -[KalViewController initWithSelectedDate:]. If you would like to programmatically switch the calendar to display the month for an arbitrary date and select that date, use -[KalViewController showAndSelectDate:].

**January 1, 2010**

I have made significant changes to the KalDataSource API so that the client can respond to the data request asynchronously. The Kal demo app, "Holidays," now includes 2 example datasources:

1. HolidayJSONDataSource - retrieves data asynchronously from http://keith.lazuka.org/holidays.json
2. HolidaySqliteDataSource - queries an Sqlite database inside the application bundle and responds synchronously (because the query is fast enough that it doesn't affect UI responsiveness too badly).

**December 19, 2009**

Initial public release on GitHub.

Example Usage
-------------

Note: All of the following example code assumes that it is being called from
within another UIViewController which is in a UINavigationController hierarchy.

How to display a very basic calendar (without any events):

    KalViewController *calendar = [[[KalViewController alloc] init] autorelease];
    [self.navigationController pushViewController:calendar animated:YES];

In most cases you will have some custom data that you want to attach
to the dates on the calendar. The first thing you must do is provide
an implementation of the KalDataSource protocol. Then all you need to do
to display your annotated calendar is instantiate the KalViewController
and tell it to use your KalDataSource implementation (in this case, "MyKalDataSource"):

    id<KalDataSource> source = [[MyKalDataSource alloc] init];
    KalViewController *calendar = [[[KalViewController alloc] initWithDataSource:source] autorelease];
    [self.navigationController pushViewController:calendar animated:YES];

NOTE: KalViewController does not retain its datasource. You probably will want to store a reference to the dataSource in an instance variable so that you can release it after the calendar has been destroyed.

Integrating Kal into Your Project
---------------------------------

Kal is compiled as a static library, and the recommended way to add it to your project is to use Xcode's "dependent project" facilities by following these step-by-step instructions:

1. Clone the Kal git repository: git clone git://github.com/klazuka/Kal.git. Make sure you store the repository in a permanent place because Xcode will need to reference the files every time you compile your project.
2. Locate the "Kal.xcodeproj" file under "Kal/src/". Drag Kal.xcodeproj and drop it onto the root of your Xcode project's "Groups and Files" sidebar. A dialog will appear -- make sure "Copy items" is unchecked and "Reference Type" is "Relative to Project" before clicking "Add".
3. Now you need to link the Kal static library to your project. Select the Kal.xcodeproj file that you just added to the sidebar. Under the "Details" table, you will see libKal.a. Check the checkbox on the far right for this file. This will tell Xcode to link against Kal when building your app.
4. Now you need to add Kal as a dependency of your project so that Xcode will compile it whenever you compile your project. Expand the "Targets" section of the sidebar and double-click your application's target. Under the "General" tab you will see a "Direct Dependencies" section. Click the "+" button, select "Kal" and click "Add Target".
5. Now you need to add the bundle of image resources internally used by Kal's UI. Locate "Kal.bundle" under "Kal/src" and drag and drop it into your project. A dialog will appear -- make sure "Create Folder References" is selected, "Copy items" is unchecked, and "Reference Type" is "Relative to Project" before clicking "Add".
6. Finally, we need to tell your project where to find the Kal headers. Open your "Project Settings" and go to the "Build" tab. Look for "Header Search Paths" and double-click it. Add the relative path from your project's directory to the "Kal/src" directory.
7. While you are in Project Settings, go to "Other Linker Flags" under the "Linker" section, and add "-all_load" to the list of flags.
8. You're ready to go. Just #import "Kal.h" anywhere you want to use KalViewController in your project.

Additional Notes
----------------

The Xcode project includes two demo apps:
1) "Holiday" demonstrates how to use Kal to display several 2009 and 2010 world holidays using both JSON and Sqlite datasources.
2) "NativeCal" demonstrates how to use Kal with the EventKit framework.

Kal is fully localized. The month name and days of the week will automatically
use the appropriate language and style for the iPhone's current regional settings.


