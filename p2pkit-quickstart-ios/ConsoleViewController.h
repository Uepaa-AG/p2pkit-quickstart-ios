//
//  ConsoleViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>
#import "P2PKitController.h"
@interface ConsoleViewController : UIViewController

-(void)clearLog;
-(BOOL)getDiscoveryEnabled;
-(NSString*)getLogContent;
-(void)toggleDiscovery;
@end

