//
//  NearbyPeersViewControllerMac.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import "NearbyPeersViewControllerMac.h"
#import "ColorPickerGridViewController.h"

@interface NearbyPeersViewControllerMac () {
    ConsoleViewController *consoleViewController_;
}

@property (weak, nonatomic) IBOutlet NSButton *infoButton;

@end

@implementation NearbyPeersViewControllerMac

#pragma mark - Helpers

-(void)setup {
    
#if UPA_CONFIGURATION_TYPE != 0
    consoleViewController_ = [self.storyboard instantiateControllerWithIdentifier:@"consoleViewController"];
    [self.infoButton setTarget:self];
    [self.infoButton setAction:@selector(toggleConsoleView)];
    [self.infoButton setHidden:NO];
#else
    [self.infoButton removeFromSuperview];
#endif
    
    [super setup];
}

-(void)presentColorPicker {

    ColorPickerGridViewController *colorPickerVC = [self.storyboard instantiateControllerWithIdentifier:@"colorPickerViewController"];
    
    [colorPickerVC setOnCompleteBlock:^(UIColor *color) {

        [self setOwnColor:color];
    }];
    
    [self presentViewController:colorPickerVC asPopoverRelativeToRect:[self getOwnNodeRect] ofView:self.view preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}

-(void)toggleConsoleView {
    
    [self presentViewControllerAsSheet:consoleViewController_];
}

-(void)showErrorDialog:(NSString*)message retryBlock:(dispatch_block_t)retryBlock {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"p2pkit Error"];
        [alert setInformativeText:message];
        [alert addButtonWithTitle:@"OK"];
        
        if (retryBlock) [alert addButtonWithTitle:@"Retry"];
        
        NSModalResponse response = [alert runModal];
        if (retryBlock && response == NSAlertSecondButtonReturn) {
            retryBlock();
        }
    });
}

@end
