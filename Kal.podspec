#
# Be sure to run `pod spec lint Kal.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
   s.name         = "Kal"
  s.version      = "1.3"
  s.summary      = "A calendar component for the iPhone (the UI is designed to match MobileCal) but with UIAppearance conformance for customization."
  s.description  = <<-DESC
		This project aims to provide an open-source implementation of the month view in Apple's mobile calendar app (MobileCal). Using the UIAppearance proxy, the look can also be completely customized. When the user taps a day on the calendar, any associated data for that day will be displayed in a table view directly below the calendar.

Tell Kal which days need to be marked with a dot because they have associated data.
Provide UITableViewCells which display the details (if any) for the currently selected day.
In order to use Kal in your application, you will need to provide an implementation of the KalDataSource protocol to satisfy these responsibilities. Please see KalDataSource.h and the included demo app for more details.
                    DESC
  s.homepage     = ""
  s.license      = {
    :type => 'MIT license',
    :text => <<-LICENSE
Copyright (c) 2009 Keith Lazuka

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
     LICENSE
  }
  s.author       = { "Brian Young" => "brian@cordanyoung.com" }
  s.source       = { :git => "https://github.com/briancordanyoung/Kal.git", :tag => "1.3.0" }
  s.platform     = :ios, '6.0'
  s.source_files = 'src/*.{h,m}'
  s.resources = 'src/assets/*.png'
  s.framework    = 'UIKit'
  s.requires_arc = true
end