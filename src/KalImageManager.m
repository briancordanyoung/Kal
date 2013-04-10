//
//  KalImageManager.m
//  Kal
//
//  Created by Paul Mietz Egli on 4/10/13.
//
//

#import "KalImageManager.h"

@implementation KalImageManager

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:[NSString stringWithFormat:@"Kal.bundle/%@", name]];
}

@end
