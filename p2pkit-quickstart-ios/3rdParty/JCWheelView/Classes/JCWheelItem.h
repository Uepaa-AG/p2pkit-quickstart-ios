//
//  JCWheelItem.h
//  JCWheelView
//
//  Created by 李京城 on 15/6/27.
//  Copyright (c) 2014 李京城. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCWheelView;
@interface JCWheelItem : UIView

@property (nonatomic, strong) UIBezierPath *bezierPath;

- (instancetype)initWithWheelView:(JCWheelView *)wheelView;

@end
