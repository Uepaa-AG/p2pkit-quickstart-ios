//
//  JCRotateGestureRecognizer.h
//  JCWheelView
//
//  Created by 李京城 on 15/6/27.
//  Copyright (c) 2014 李京城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCRotateGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) CGFloat degrees;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger hoverIndex;

@end
