//
//  UIColor+Extra.m
//  Trends
//
//  Created by Alex Malkoff on 15.10.15.
//  Copyright © 2015 cpthooch. All rights reserved.
//

#import "UIColor+Extra.h"

@implementation UIColor (Extra)

+ (UIColor *)extra_colorWithHex:(unsigned long)hex {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}

@end
