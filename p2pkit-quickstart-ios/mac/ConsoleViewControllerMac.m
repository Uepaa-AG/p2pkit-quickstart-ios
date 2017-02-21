//
//  ConsoleViewControllerMac.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//


#import "ConsoleViewControllerMac.h"

@interface ConsoleViewControllerMac ()
@property (weak, nonatomic) IBOutlet NSButton *discoveryToggleButton;
@property (strong, nonatomic) IBOutlet NSTextView *logTextView;
@property (weak, nonatomic) IBOutlet NSButton *clearButton;
@property (weak, nonatomic) IBOutlet NSButton *closeButton;
@end

@implementation ConsoleViewControllerMac

-(void)setupNotifications {
    // do nothing
}

-(void)sendLocalNotificationWhenInBackgroundForPeer:(PPKPeer*)peer withMessage:(NSString*)message {
    
#if UPA_CONFIGURATION_TYPE > 0
    dispatch_async(dispatch_get_main_queue(), ^{

        NSUserNotification *notification = [NSUserNotification new];
        notification.title = message;
        notification.informativeText = peer.peerID;
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
    });
#endif
}

-(void)setupUI {
    
    [self setPreferredContentSize:NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.logTextView setBackgroundColor:[NSColor clearColor]];
    [self.logTextView setEditable:NO];
    
    [self.closeButton setTarget:self];
    [self.closeButton setAction:@selector(dismissView)];
    
    [self.clearButton setTarget:self];
    [self.clearButton setAction:@selector(clearLog)];
    
    [self.discoveryToggleButton setTarget:self];
    [self.discoveryToggleButton setAction:@selector(toggleDiscovery)];
    
    [self updateUIState];
}

-(void)updateUIState {

    if (self.logTextView) {
        NSAttributedString *attributedContent = [[NSAttributedString alloc] initWithString:[self getLogContent] attributes:@{ NSForegroundColorAttributeName: [NSColor darkGrayColor] }];
        [self.logTextView.textStorage setAttributedString:attributedContent];
    }
    
    [self.discoveryToggleButton setTitle:[NSString stringWithFormat:@"%@ Discovery", ([self getDiscoveryEnabled] ? @"Stop" : @"Start")]];
    
}

-(void)dismissView {
    [self.presentingViewController dismissViewController:self];
}

@end
