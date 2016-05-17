//
//  MainWindowController.m
//  p2pkit-quickstart-mac
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import "MainWindowController.h"
#import "P2PKitController.h"
#import "NearbyPeersViewController.h"

@interface MainWindowController () <PPKControllerDelegate> {
    P2PKitController *p2pkitController;
}
@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setBackgroundColor:[NSColor blackColor]];
    [self.window setTitleVisibility:NSWindowTitleHidden];
    
    p2pkitController = [[P2PKitController alloc] initWithNearbyPeersViewController:(NearbyPeersViewController*)self.contentViewController];
}

@end
