//
//  ColorPickerViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "ColorPickerGridViewController.h"


#define RGB(r, g, b) [NSColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]


@interface ColorPickerGridViewController ()

@property (nonatomic, copy) NSDictionary *colors;

@end

@implementation ColorPickerGridViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSMutableDictionary *colors = [NSMutableDictionary new];

    colors[@"(2,3)"] = RGB(233, 65, 76); // Red
    colors[@"(0,0)"] = RGB(236, 99, 51); // Dark orange
    colors[@"(0,1)"] = RGB(239, 136, 51); // Medium Orange
    colors[@"(0,2)"] = RGB(244, 173, 51); // Light orange

    colors[@"(0,3)"] = RGB(251, 213, 51); // Yellow
    colors[@"(1,3)"] = RGB(164, 243, 54); // Neon
    colors[@"(1,2)"] = RGB(122, 234, 71); // Green
    colors[@"(1,1)"] = RGB(103, 219, 226); // Light blue

    colors[@"(1,0)"] = RGB(51, 155, 247); // Blue
    colors[@"(2,0)"] = RGB(122, 115, 232); // Violet
    colors[@"(2,1)"] = RGB(218, 84, 216); // Purple
    colors[@"(2,2)"] = RGB(232, 73, 148); // Pink
    
    self.colors = colors;
    [self drawColorSwatches];
}

-(void)drawColorSwatches {
    
    NSUInteger columns = [self numberOfColumns];
    NSUInteger rows = [self numberOfRows];
    
    CGFloat cellWidth = [self cellWidth];
    CGFloat cellHeight = [self cellHeight];
    
    for (NSUInteger i=0; i < columns; i++) {
        for (NSUInteger j=0; j < rows; j++) {
            NSRect frame = NSMakeRect(i*cellWidth, j*cellHeight, cellWidth, cellHeight);
            NSColor *color = [self colorAtColumn:i row:j];
            
            NSView *colorSwatch = [[NSView alloc] initWithFrame:frame];
            [colorSwatch setWantsLayer:YES];
            [colorSwatch.layer setBackgroundColor:color.CGColor];
            
            [self.view addSubview:colorSwatch];
        }
    }
}

-(CGFloat)cellWidth {
    NSUInteger columns = [self numberOfColumns];
    return (self.view.frame.size.width) / columns;
}

-(CGFloat)cellHeight {
    NSUInteger rows = [self numberOfRows];
    return (self.view.frame.size.height) / rows;
}

-(NSUInteger)numberOfColumns {
    return 3;
}

-(NSUInteger)numberOfRows {
    return 4;
}

-(NSColor*)colorAtColumn:(NSUInteger)column row:(NSUInteger)row {
    NSString *key = [NSString stringWithFormat:@"(%lu,%lu)", (unsigned long)column,(unsigned long)row];
    return self.colors[key];
}

#pragma mark - Helpers

-(void)mouseDown:(NSEvent*)theEvent {
    NSPoint position = [self.view convertPoint:theEvent.locationInWindow fromView:nil];
    
    NSUInteger column = position.x / [self cellWidth];
    NSUInteger row = position.y / [self cellHeight];
    
    NSColor *color = [self colorAtColumn:column row:row];
    
    if (self.onCompleteBlock) {
        self.onCompleteBlock(color);
        [self dismissViewController:self];
    }
}

@end
