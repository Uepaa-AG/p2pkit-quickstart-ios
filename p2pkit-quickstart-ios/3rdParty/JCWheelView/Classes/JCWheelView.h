//
//  JCWheelView.h
//  JCWheelView
//
//  Created by 李京城 on 15/6/27.
//  Copyright (c) 2014 李京城. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(d) ((d) * M_PI / 180)
#define RADIANS_TO_DEGREES(d) ((d) * 180 / M_PI)

@class JCWheelItem;
@class JCWheelView;
@class JCWheelCenterView;
@protocol JCWheelViewDelegate <NSObject>
- (NSInteger)numberOfItemsInWheelView:(JCWheelView *)wheelView;
@optional
-(void)wheelView:(JCWheelView *)wheelView didSelectItemAtIndex:(NSInteger)index;
-(void)wheelView:(JCWheelView *)wheelView didHoverItemAtIndex:(NSInteger)index;
@end

@interface JCWheelView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) JCWheelCenterView *centerView;
@property (nonatomic, assign, readonly) NSInteger numberOfItems;

//After rotating the wheel for locating the selected item
@property (nonatomic, strong, readonly) JCWheelItem *baseWheelItem;

@property (nonatomic, weak) id<JCWheelViewDelegate> delegate;


-(void)selectItemAtIndex:(NSInteger)index;

@end
