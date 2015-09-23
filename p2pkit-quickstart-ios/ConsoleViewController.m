//
//  ConsoleViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "ConsoleViewController.h"
#import <P2PKit/P2PKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "NearbyPeersViewController.h"

@interface ConsoleViewController ()<PPKControllerDelegate,CLLocationManagerDelegate> {
    
    CLLocationManager* locMgr_;
    NSDateFormatter* timeFormatter_;
    NSData *discoveryInfo_;
    BOOL discoveryEnabled_;
    BOOL geoEnabled_;
    BOOL messagingEnabled_;
}

@property (weak, nonatomic) IBOutlet UISwitch *p2pToggleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *geoToggleSwitch;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end

@implementation ConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupNotifications];
    
    @try {
        
        /* p2pkit also supports multiple observers */
        [PPKController addObserver:self];
        [self logKey:@"My ID (p2pkit init success!)" value:[PPKController myPeerID]];
        
        discoveryEnabled_ = [PPKController p2pDiscoveryState] != PPKPeer2PeerDiscoveryStopped;
        geoEnabled_ = [PPKController geoDiscoveryState] != PPKGeoDiscoveryStopped;
        messagingEnabled_ = [PPKController onlineMessagingState] != PPKOnlineMessagingStopped;
        
        /* Subscribe to notification to receive updates when the user changes its color */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorUpdateNotification:) name:@"userSelectedNewColorNotification" object:nil];
    }
    @catch (NSException *exception) {
        /* In case p2pkit was not initialized correctly */
    }
}

-(void)colorUpdateNotification:(NSNotification*)notification {
    discoveryInfo_ = notification.object;
}

#pragma mark - PPKControllerDelegate

-(void)p2pDiscoveryStateChanged:(PPKPeer2PeerDiscoveryState)state {
    
    NSString *description;
    
    switch (state) {
        case PPKPeer2PeerDiscoveryStopped:
            description = @"stopped";
            discoveryEnabled_ = NO;
            break;
        case PPKPeer2PeerDiscoverySuspended:
            description = @"suspended";
            discoveryEnabled_ = YES;
            break;
        case PPKPeer2PeerDiscoveryRunning:
            description = @"running";
            discoveryEnabled_ = YES;
            break;
    }
    
    [self updateUIState];
    [self logKey:@"P2P state" value:description];
}

-(void)p2pPeerDiscovered:(PPKPeer*)peer {
    
    if (peer.discoveryInfo) {
        
        /* Try to read discovery info of peer as a string, otherwise just display number of bytes received */
        NSString *discoveryInfo = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
        if (!discoveryInfo || [discoveryInfo isEqualToString:@"(null)"]) {
            discoveryInfo = [NSString stringWithFormat:@"%ld bytes", (unsigned long)peer.discoveryInfo.length];
        }
        
        NSString *message = [NSString stringWithFormat:@"%@ (%@)", peer.peerID, discoveryInfo];
        [self logKey:@"P2P discovered" value:message];
    }
    else {
        [self logKey:@"P2P discovered" value:peer.peerID];
    }
    
    [self sendLocalNotificationWhenInBackgroundForPeer:peer withMessage:@"Discovered new peer"];
}

-(void)p2pPeerLost:(PPKPeer *)peer {
    [self logKey:@"P2P lost" value:peer.peerID];
    [self sendLocalNotificationWhenInBackgroundForPeer:peer withMessage:@"Lost peer"];
}

-(void)didUpdateP2PDiscoveryInfoForPeer:(PPKPeer*)peer {
    
    if (peer.discoveryInfo) {
        
        /* Try to read discovery info of peer as a string, otherwise just display number of bytes received */
        NSString *discoveryInfo = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
        if (!discoveryInfo || [discoveryInfo isEqualToString:@"(null)"]) {
            discoveryInfo = [NSString stringWithFormat:@"%ld bytes", (unsigned long)peer.discoveryInfo.length];
        }
        
        NSString *message = [NSString stringWithFormat:@"%@ (%@)", peer.peerID, discoveryInfo];
        [self logKey:@"P2P updated" value:message];
    }
    else {
        [self logKey:@"P2P updated" value:peer.peerID];
    }
    
    [self sendLocalNotificationWhenInBackgroundForPeer:peer withMessage:@"Updated peer"];
}

-(void)onlineMessagingStateChanged:(PPKOnlineMessagingState)state {
    
    NSString *description;
    
    switch (state) {
        case PPKOnlineMessagingRunning:
            description = @"running";
            messagingEnabled_ = YES;
            [self startLocationUpdates];
            break;
        case PPKOnlineMessagingSuspended:
            description = @"suspended";
            messagingEnabled_ = YES;
            [self stopLocationUpdates];
            break;
        case PPKOnlineMessagingStopped:
            description = @"stopped";
            messagingEnabled_ = NO;
            [self stopLocationUpdates];
            break;
    }
    
    [self updateUIState];
    [self logKey:@"Online messaging state" value:description];
}

-(void)messageReceived:(NSData*)messageBody header:(NSString*)messageHeader from:(NSString*)peerID {
    [self logKey:peerID value:[[NSString alloc] initWithData:messageBody encoding:NSUTF8StringEncoding]];
}

-(void)geoDiscoveryStateChanged:(PPKGeoDiscoveryState)state {
    
    NSString *description;
    
    switch (state) {
        case PPKGeoDiscoveryRunning:
            description = @"running";
            geoEnabled_ = YES;
            [self startLocationUpdates];
            break;
        case PPKGeoDiscoverySuspended:
            description = @"suspended";
            geoEnabled_ = YES;
            [self stopLocationUpdates];
            break;
        case PPKGeoDiscoveryStopped:
            description = @"stopped";
            geoEnabled_ = NO;
            [self stopLocationUpdates];
            break;
    }
    
    [self updateUIState];
    [self logKey:@"GEO state" value:description];
}

-(void)geoPeerDiscovered:(NSString*)peerID {
    [self logKey:@"GEO discovered" value:peerID];
}

-(void)geoPeerLost:(NSString*)peerID {
    [self logKey:@"GEO lost" value:peerID];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [PPKController updateUserLocation:[locations lastObject]];
}

#pragma mark - CLLocationManager Helpers

-(void)startLocationUpdates {
    
    if (locMgr_) {
        return;
    }
    
    locMgr_ = [CLLocationManager new];
    [locMgr_ setDelegate:self];
    [locMgr_ setDesiredAccuracy:200];
    
    /* Avoid sending to many location updates, set a distance filter */
    [locMgr_ setDistanceFilter:200];
    
    if ([locMgr_ respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locMgr_ requestAlwaysAuthorization];
    }
    
    [locMgr_ startUpdatingLocation];
}

-(void)stopLocationUpdates {
    
    if (!locMgr_) {
        return;
    }
    
    [locMgr_ stopUpdatingLocation];
    [locMgr_ setDelegate:nil];
    locMgr_ = nil;
}

#pragma mark - Helpers

-(void)send:(NSString*)message to:(NSString*)peerID {
    [PPKController sendMessage:[message dataUsingEncoding:NSUTF8StringEncoding] withHeader:@"SimpleChatMessage" to:peerID];
}

-(void)logKey:(NSString*)key value:(NSString*)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.text = [NSString stringWithFormat:@"%@ - %@: %@\n%@", [self getCurrentFormattedTime], key, value, self.logTextView.text];
    });
}

-(NSString *)getCurrentFormattedTime {
    return [timeFormatter_ stringFromDate:[NSDate date]];
}

-(void)clearLog {
    self.logTextView.text = @"";
}

-(void)setupNotifications {
    
#if UPA_CONFIGURATION_TYPE > 0
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeAlert);
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
#endif
}

-(void)sendLocalNotificationWhenInBackgroundForPeer:(PPKPeer*)peer withMessage:(NSString*)message {

#if UPA_CONFIGURATION_TYPE > 0
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            
            UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if ([notificationSettings types] & UIUserNotificationTypeBadge) {
                
                UILocalNotification *notification = [UILocalNotification new];
                notification.alertBody = [NSString stringWithFormat:@"%@ (%@)", message, peer.peerID];
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
    });
#endif
}

#pragma mark - UI Actions

-(void)setupUI {
    
    timeFormatter_ = [[NSDateFormatter alloc] init];
    [timeFormatter_ setDateFormat:@"HH:mm:ss"];
    [self.clearButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    [self.p2pToggleSwitch addTarget:self action:@selector(toggleP2PDiscovery) forControlEvents:UIControlEventValueChanged];
    [self.geoToggleSwitch addTarget:self action:@selector(toggleGeoDiscovery) forControlEvents:UIControlEventValueChanged];
    [self updateUIState];
}

-(void)updateUIState {
    self.p2pToggleSwitch.on = discoveryEnabled_;
    self.geoToggleSwitch.on = (geoEnabled_ && messagingEnabled_);
}

-(void)toggleP2PDiscovery {
    
    if (self.p2pToggleSwitch.on) {
        [PPKController startP2PDiscoveryWithDiscoveryInfo:discoveryInfo_];
    }
    else {
        [PPKController stopP2PDiscovery];
    }
}

-(void)toggleGeoDiscovery {
    
    if (self.geoToggleSwitch.on) {
        [PPKController startGeoDiscovery];
        [PPKController startOnlineMessaging];
    }
    else {
        [PPKController stopOnlineMessaging];
        [PPKController stopGeoDiscovery];
    }
}

@end
