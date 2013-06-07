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
        NSLog(@"Could not find imageNamed: %@",name);
        result = [UIImage imageWithContentsOfFile:path];
        if (!result) NSLog(@"Could not find image at path: %@",path);
    }

    return result;
}

@end
