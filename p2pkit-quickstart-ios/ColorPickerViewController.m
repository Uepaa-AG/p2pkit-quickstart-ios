//
//  ColorPickerViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "JCWheelView.h"


#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]


@interface ColorPickerViewController () <JCWheelViewDelegate>

@property (nonatomic, weak) IBOutlet JCWheelView *wheelView;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, copy) NSArray *colors;

@end


@implementation ColorPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colors = @[RGB(233, 65, 76), RGB(236, 99, 51), RGB(239, 136, 51), RGB(244, 173, 51),
                    RGB(251, 213, 51), RGB(164, 243, 54), RGB(122, 234, 71), RGB(103, 219, 226),
                    RGB(51, 155, 247), RGB(122, 115, 232), RGB(218, 84, 216), RGB(232, 73, 148)];
    
    _selectedColor = self.colors.firstObject;
    
    self.wheelView.delegate = self;
    
    self.colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 88)];
    self.colorView.layer.cornerRadius = self.colorView.frame.size.width/2;
    self.colorView.layer.masksToBounds = YES;
    self.colorView.backgroundColor = self.colors.firstObject;
    
    [self.colorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithCurrentColor)]];
    
    [self.view addSubview:self.colorView];
}

- (void)viewDidLayoutSubviews {
    
    [self.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    }];
}

-(void)setSelectedColor:(UIColor *)selectedColor {
    
    [self.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger index, BOOL *stop) {

        if ([color isEqual:selectedColor]) {
            [self.colorView setBackgroundColor:color];
            [self.wheelView selectItemAtIndex:index];
            _selectedColor = color;
            *stop = YES;
        }
    }];
}

-(void)dismissWithCurrentColor {
    
    if (self.onCompleteBlock) self.onCompleteBlock(self.selectedColor);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JCWheelViewDelegate

- (NSInteger)numberOfItemsInWheelView:(JCWheelView *)wheelView
{
    return self.colors.count;
}

- (void)wheelView:(JCWheelView *)wheelView didSelectItemAtIndex:(NSInteger)index
{
    self.colorView.backgroundColor = self.colors[index];
    _selectedColor = self.colors[index];
    [self dismissWithCurrentColor];
}

-(void)wheelView:(JCWheelView *)wheelView didHoverItemAtIndex:(NSInteger)index {
    self.colorView.backgroundColor = self.colors[index];
}

@end
