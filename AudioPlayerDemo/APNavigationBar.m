//
//  APNavigationBar.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-16.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APNavigationBar.h"

@implementation APNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    UIColor *colorFlat = UIColorFromRGB(0x3e3e47);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [colorFlat CGColor]);
    CGContextFillRect(context, rect);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width, 120);
    return newSize;
}

@end
