//
//  MainWindowController.m
//  p2pkit-quickstart-mac
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import "MainWindowController.h"
#import "P2PKitController.h"
#import "NearbyPeersViewControllerMac.h"


@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setBackgroundColor:[NSColor blackColor]];
    [self.window setTitleVisibility:NSWindowTitleHidden];
    
    [[P2PKitController sharedInstance] enableWithNearbyPeersViewController:(NearbyPeersViewControllerMac*)self.contentViewController];
}

@end
