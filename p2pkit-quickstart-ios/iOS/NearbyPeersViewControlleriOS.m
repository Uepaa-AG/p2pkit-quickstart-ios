//
//  NearbyPeersViewControlleriOS.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import "NearbyPeersViewControlleriOS.h"
#import "ColorPickerWheelViewController.h"

@interface NearbyPeersViewControlleriOS () {
    ConsoleViewController *consoleViewController_;
}

@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *consoleView;

@end

@implementation NearbyPeersViewControlleriOS

#pragma mark - Helpers

-(void)setup {
    
#if UPA_CONFIGURATION_TYPE != 0
    consoleViewController_ = [self.storyboard instantiateViewControllerWithIdentifier:@"consoleViewControlleriOS"];
    [self addChildViewController:consoleViewController_];
    [self.consoleView addSubview:consoleViewController_.view];
    [consoleViewController_ didMoveToParentViewController:self];
    
    [self.infoButton addTarget:self action:@selector(toggleConsoleView) forControlEvents:UIControlEventTouchUpInside];
    [self.consoleView setAlpha:0.0];
    [self.infoButton setHidden:NO];
#else
    [self.infoButton removeFromSuperview];
#endif
    
    [super setup];
}

-(void)presentColorPicker {

    ColorPickerWheelViewController *colorPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"colorPickerViewController"];

    [colorPickerVC setOnCompleteBlock:^(UIColor *color) {
        
        [self setOwnColor:color];
        [self.infoButton setHidden:NO];
    }];
    
    [self presentViewController:colorPickerVC animated:YES completion:^{
        [colorPickerVC setSelectedColor:[self getOwnColor]];
    }];
}

-(void)toggleConsoleView {
    
    if (self.consoleView.hidden) {
        [self.consoleView setHidden:NO];
        [UIView animateWithDuration:0.22 animations:^{
            [self.consoleView setAlpha:1.0];
        }];
    }
    else {
        [UIView animateWithDuration:0.15 animations:^{
            [self.consoleView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.consoleView setHidden:YES];
        }];
    }
}

-(void)showErrorDialog:(NSString*)message retryBlock:(dispatch_block_t)retryBlock {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"p2pkit Error" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        if (retryBlock) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                retryBlock();
            }]];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

@end

