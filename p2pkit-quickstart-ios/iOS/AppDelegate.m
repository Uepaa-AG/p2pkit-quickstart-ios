//
//  AppDelegate.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "AppDelegate.h"
#import "P2PKitController.h"
#import "NearbyPeersViewControlleriOS.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [[P2PKitController sharedInstance] enableWithNearbyPeersViewController:(NearbyPeersViewControlleriOS*)self.window.rootViewController];
    return YES;
}

-(void)applicationWillTerminate:(UIApplication*)application {
    [[P2PKitController sharedInstance] disable];
}

@end
