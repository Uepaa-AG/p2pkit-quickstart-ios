//
//  JCWheelCenterView.m
//  JCWheelView
//
//  Created by 李京城 on 15/7/23.
//  Copyright (c) 2015年 lijingcheng. All rights reserved.
//

#import "JCWheelCenterView.h"

@interface JCWheelCenterView () {
    UIImageView *imageView_;
}

@end

@implementation JCWheelCenterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor clearColor];
        imageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wheel_arrow"]];

        CGFloat ratio = self.frame.size.height / imageView_.frame.size.height;
        imageView_.frame = CGRectMake(0, 0, imageView_.frame.size.width * ratio, imageView_.frame.size.height * ratio);
        
        CGFloat diff = imageView_.frame.size.height - imageView_.frame.size.width;
        imageView_.center = CGPointMake(self.center.x, self.center.y - (diff/2));
        
        [self addSubview:imageView_];
    }
    
    return self;
}

@end
