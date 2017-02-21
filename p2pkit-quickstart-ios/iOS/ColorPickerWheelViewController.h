//
//  ColorPickerViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

@interface ColorPickerWheelViewController : UIViewController

@property (nonatomic) UIColor *selectedColor;
@property (copy) void (^onCompleteBlock) (UIColor*color);

@end
