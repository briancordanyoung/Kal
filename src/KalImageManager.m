//
//  KalImageManager.m
//  Kal
//
//  Created by Paul Mietz Egli on 4/10/13.
//
//

#import "KalImageManager.h"

@implementation KalImageManager

static NSString * imagePathFormat = @"Kal.bundle/%@";

+ (void)setImagePathFormat:(NSString *)format {
    imagePathFormat = [format copy];
}

+ (UIImage *)imageNamed:(NSString *)name {
    NSString * path = [NSString stringWithFormat:imagePathFormat, name];
    UIImage * result = [UIImage imageNamed:path];
    if (!result) {
        result = [UIImage imageWithContentsOfFile:path];
    }
    return result;
}

@end
