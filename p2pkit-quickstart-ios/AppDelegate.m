//
//  AppDelegate.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "AppDelegate.h"
#import "P2PKitController.h"
#import "NearbyPeersViewController.h"


@interface AppDelegate () <PPKControllerDelegate> {
    P2PKitController *p2pkitController;
}
@end


@implementation AppDelegate

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {

    p2pkitController = [[P2PKitController alloc] initWithNearbyPeersViewController:(NearbyPeersViewController*)self.window.rootViewController];
    return YES;
}

@end
