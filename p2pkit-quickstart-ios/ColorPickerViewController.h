//
//  ColorPickerViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorPickerViewController : UIViewController

@property (nonatomic) UIColor *selectedColor;
@property (copy) void (^onCompleteBlock) (UIColor*color);

@end
