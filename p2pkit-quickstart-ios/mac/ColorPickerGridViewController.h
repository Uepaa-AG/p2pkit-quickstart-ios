//
//  ColorPickerViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

@interface ColorPickerGridViewController : NSViewController

@property (copy) void (^onCompleteBlock) (NSColor*color);

@end
