//
//  ConsoleViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//


#import "ConsoleViewController.h"


@interface ConsoleViewController ()<PPKControllerDelegate> {
    
    NSData *discoveryInfo_;
    BOOL discoveryEnabled_;
    
    NSDateFormatter* timeFormatter_;
    NSMutableString *logContent_;
}

@end

@implementation ConsoleViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
        timeFormatter_ = [[NSDateFormatter alloc] init];
        [timeFormatter_ setDateFormat:@"HH:mm:ss"];
        
        logContent_ = [NSMutableString new];
        
        [self setupP2PKit];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNotifications];
    [self setupUI];
}

-(void)viewWillAppear {
    [self updateUIState];
}

#pragma mark - Methods to override by subclass

-(void)setupNotifications {
#if TARGET_OS_IOS && UPA_CONFIGURATION_TYPE > 0
    @throw [NSException exceptionWithName:@"DidNotOverrideMethod" reason:@"You must override this method in your subclass" userInfo:nil];
#endif
}

-(void)sendLocalNotificationWhenInBackgroundForPeer:(PPKPeer*)peer withMessage:(NSString*)message {
#if UPA_CONFIGURATION_TYPE > 0
    @throw [NSException exceptionWithName:@"DidNotOverrideMethod" reason:@"You must override this method in your subclass" userInfo:nil];
#endif
}

#pragma mark - UI Actions

-(void)setupUI {
    @throw [NSException exceptionWithName:@"DidNotOverrideMethod" reason:@"You must override this method in your subclass" userInfo:nil];
}

-(void)updateUIState {
    @throw [NSException exceptionWithName:@"DidNotOverrideMethod" reason:@"You must override this method in your subclass" userInfo:nil];
}

-(void)setupP2PKit {
    
    if ([PPKController isEnabled]) {
        
        /* p2pkit also supports multiple observers */
        [PPKController addObserver:self];
        [self logKey:@"p2pkit Initialization" value:@"succeeded"];
        [self logKey:@"My Peer ID" value:[PPKController myPeerID]];
        
        discoveryEnabled_ = ([PPKController discoveryState] != PPKDiscoveryStateStopped);
    }
}

#pragma mark - PPKControllerDelegate

-(void)discoveryStateChanged:(PPKDiscoveryState)state {
    
    NSString *description;
    
    switch (state) {
        case PPKDiscoveryStateStopped:
            description = @"stopped";
            discoveryEnabled_ = NO;
            break;
        case PPKDiscoveryStateUnsupported:
            description = @"unsupported";
            discoveryEnabled_ = YES;
            break;
        case PPKDiscoveryStateUnauthorized:
            description = @"unauthorized";
            discoveryEnabled_ = YES;
            break;
        case PPKDiscoveryStateSuspended:
            description = @"suspended";
            discoveryEnabled_ = YES;
            break;
        case PPKDiscoveryStateServerConnectionUnavailable:
            description = @"offline";
            discoveryEnabled_ = YES;
            break;
        case PPKDiscoveryStateRunning:
            description = @"running";
            discoveryEnabled_ = YES;
            break;
    }
    
    [self updateUIState];
    [self logKey:@"Discovery State" value:description];
}

-(void)peerDiscovered:(PPKPeer*)peer {
    
    if (peer.discoveryInfo) {
        
        /* Try to read discovery info of peer as a string, otherwise just display number of bytes received */
        NSString *discoveryInfo = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
        if (!discoveryInfo || [discoveryInfo isEqualToString:@"(null)"]) {
            discoveryInfo = [NSString stringWithFormat:@"%ld bytes", (unsigned long)peer.discoveryInfo.length];
        }
        
        NSString *message = [NSString stringWithFormat:@"%@ (%@, %@)", peer.peerID, discoveryInfo, [self getDescriptionForProximityStrength:peer.proximityStrength]];
        [self logKey:@"Peer discovered" value:message];
    }
    else {
        [self logKey:@"Peer discovered" value:peer.peerID];
    }
    
    [self sendLocalNotificationWhenInBackgroundForPeer:peer withMessage:@"Peer discovered"];
}

-(void)peerLost:(PPKPeer *)peer {
    [self logKey:@"Peer lost" value:peer.peerID];
    [self sendLocalNotificationWhenInBackgroundForPeer:peer withMessage:@"Peer lost"];
}

-(void)discoveryInfoUpdatedForPeer:(PPKPeer*)peer {
    
    if (peer.discoveryInfo) {
        
        /* Try to read discovery info of peer as a string, otherwise just display number of bytes received */
        NSString *discoveryInfo = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
        if (!discoveryInfo || [discoveryInfo isEqualToString:@"(null)"]) {
            discoveryInfo = [NSString stringWithFormat:@"%ld bytes", (unsigned long)peer.discoveryInfo.length];
        }
        
        NSString *message = [NSString stringWithFormat:@"%@ (%@)", peer.peerID, discoveryInfo];
        [self logKey:@"Peer updated" value:message];
    }
    else {
        [self logKey:@"Peer updated" value:peer.peerID];
    }
    
    [self sendLocalNotificationWhenInBackgroundForPeer:peer withMessage:@"Peer updated"];
}

-(void)proximityStrengthChangedForPeer:(PPKPeer*)peer {
    
    NSString *message = [NSString stringWithFormat:@"%@ (%@)", peer.peerID, [self getDescriptionForProximityStrength:peer.proximityStrength]];
    [self logKey:@"Peer proximity" value:message];
}

-(NSString*)getDescriptionForProximityStrength:(PPKProximityStrength)proximityStrength {
    
    NSString *proximity = @"";
    switch (proximityStrength) {
        case PPKProximityStrengthImmediate:
            proximity = @"immediate";
            break;
        case PPKProximityStrengthStrong:
            proximity = @"strong";
            break;
        case PPKProximityStrengthMedium:
            proximity = @"medium";
            break;
        case PPKProximityStrengthWeak:
            proximity = @"weak";
            break;
        case PPKProximityStrengthExtremelyWeak:
            proximity = @"extremely weak";
            break;
        case PPKProximityStrengthUnknown:
            proximity = @"unknown";
            break;
    }
    
    return proximity;
}

#pragma mark - Helpers

-(BOOL)getDiscoveryEnabled {
    return discoveryEnabled_;
}

-(NSString*)getLogContent {
    return logContent_;
}


-(void)logKey:(NSString*)key value:(NSString*)value {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [logContent_ setString:[NSString stringWithFormat:@"%@ - %@: %@\n%@", [self getCurrentFormattedTime], key, value, logContent_]];
        [self updateUIState];
    });
}

-(NSString *)getCurrentFormattedTime {
    return [timeFormatter_ stringFromDate:[NSDate date]];
}

-(void)clearLog {
    [logContent_ setString:@""];
    [self updateUIState];
}

-(void)toggleDiscovery {
    
    if (discoveryEnabled_) {
        [[P2PKitController sharedInstance] stopDiscovery];
    }
    else {
        
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        NSData *colorData = [userDef objectForKey:@"ownColor"];
        [[P2PKitController sharedInstance] startOrUpdateDiscoveryWithDiscoveryInfo:colorData];
    }
}

@end
