//
//  KalImageManager.h
//  Kal
//
//  Created by Paul Mietz Egli on 4/10/13.
//
//

#import <UIKit/UIKit.h>

@interface KalImageManager : NSObject
+ (void)setImagePathFormat:(NSString *)format;
+ (UIImage *)imageNamed:(NSString *)name;
@end
