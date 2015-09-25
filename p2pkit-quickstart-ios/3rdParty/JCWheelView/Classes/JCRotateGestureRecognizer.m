//
//  JCRotateGestureRecognizer.m
//  JCWheelView
//
//  Created by 李京城 on 15/6/27.
//  Copyright (c) 2014 李京城. All rights reserved.
//

#import "JCRotateGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "JCWheelView.h"
#import "JCWheelItem.h"

@implementation JCRotateGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = (touches.count == 1) ? UIGestureRecognizerStateBegan : UIGestureRecognizerStateFailed;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateChanged;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    CGPoint currentLocation = [touch locationInView:self.view];
    CGPoint previousLocation = [touch previousLocationInView:self.view];
    
    self.degrees = atan2((currentLocation.y - center.y), (currentLocation.x - center.x)) - atan2((previousLocation.y - center.y), (previousLocation.x - center.x));
    
    JCWheelView *wheelView = (JCWheelView *)self.view;
    
    for (JCWheelItem *itemView in self.view.subviews) {
        CGPoint itemViewCenterPoint = CGPointMake(CGRectGetMidX(itemView.bounds), CGRectGetMidY(itemView.bounds));
        
        CGPoint itemCenterPointInWindow = [itemView convertPoint:itemViewCenterPoint toView:nil];
        CGRect baseWheelItemRectInWindow = [wheelView.baseWheelItem.superview convertRect:wheelView.baseWheelItem.frame toView:nil];
        
        if (CGRectContainsPoint(baseWheelItemRectInWindow, itemCenterPointInWindow)) {
            CGPoint itemCenterPointInBaseWheelItem = [itemView convertPoint:itemViewCenterPoint toView:wheelView.baseWheelItem];
            
            if ([self point:itemCenterPointInBaseWheelItem at:itemView]) {
                break;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.state == UIGestureRecognizerStateBegan) {
        for (JCWheelItem *itemView in self.view.subviews) {
            CGPoint touchPoint = [self locationInView:itemView];
            
            if ([self point:touchPoint at:itemView]) {
                self.degrees = DEGREES_TO_RADIANS(180) + atan2(self.view.transform.a, self.view.transform.b) + atan2(itemView.transform.a, itemView.transform.b);
                break;
            }
        }
    }
    else if (self.state == UIGestureRecognizerStateChanged) {
        JCWheelView *wheelView = (JCWheelView *)self.view;
        
        for (JCWheelItem *itemView in self.view.subviews) {
            CGPoint itemViewCenterPoint = CGPointMake(CGRectGetMidX(itemView.bounds), CGRectGetMidY(itemView.bounds));
            
            CGPoint itemCenterPointInWindow = [itemView convertPoint:itemViewCenterPoint toView:nil];
            CGRect baseWheelItemRectInWindow = [wheelView.baseWheelItem.superview convertRect:wheelView.baseWheelItem.frame toView:nil];
            
            if (CGRectContainsPoint(baseWheelItemRectInWindow, itemCenterPointInWindow)) {
                CGPoint itemCenterPointInBaseWheelItem = [itemView convertPoint:itemViewCenterPoint toView:wheelView.baseWheelItem];
                
                if ([self point:itemCenterPointInBaseWheelItem at:itemView]) {
                    self.degrees = DEGREES_TO_RADIANS(180) + atan2(self.view.transform.a, self.view.transform.b) + atan2(itemView.transform.a, itemView.transform.b);
                    break;
                }
            }
        }
    }
    
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark -

-(BOOL)point:(CGPoint)point at:(JCWheelItem *)itemView
{
    if (CGPathContainsPoint(itemView.bezierPath.CGPath, NULL, point, NO)) {
        self.hoverIndex = itemView.tag;
        self.selectedIndex = itemView.tag;
        return YES;
    }
    
    return NO;
}

@end
