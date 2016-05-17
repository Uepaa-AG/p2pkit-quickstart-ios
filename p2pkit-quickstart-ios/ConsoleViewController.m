//
//  ConsoleViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ConsoleViewController.h"

@interface ConsoleViewController ()<PPKControllerDelegate,CLLocationManagerDelegate> {
    
    CLLocationManager* locMgr_;
    NSData *discoveryInfo_;
    BOOL discoveryEnabled_;
    BOOL geoEnabled_;
    BOOL messagingEnabled_;
    
    NSDateFormatter* timeFormatter_;
    NSMutableString *logContent_;
}

#if TARGET_OS_IOS
@property (weak, nonatomic) IBOutlet UISwitch *p2pToggleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *geoToggleSwitch;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
#else
@property (weak, nonatomic) IBOutlet NSButton *p2pToggleButton;
@property (weak, nonatomic) IBOutlet NSButton *geoToggleButton;
@property (strong, nonatomic) IBOutlet NSTextView *logTextView;
@property (weak, nonatomic) IBOutlet NSButton *clearButton;
@property (weak, nonatomic) IBOutlet NSButton *closeButton;
#endif

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

-(void)setupP2PKit {
    
    if ([PPKController isEnabled]) {
        
        /* p2pkit also supports multiple observers */
        [PPKController addObserver:self];
        [self logKey:@"My ID (p2pkit init success!)" value:[PPKController myPeerID]];
        
        discoveryEnabled_ = [PPKController p2pDiscoveryState] != PPKPeer2PeerDiscoveryStopped;
        geoEnabled_ = [PPKController geoDiscoveryState] != PPKGeoDiscoveryStopped;
        messagingEnabled_ = [PPKController onlineMessagingState] != PPKOnlineMessagingStopped;
        
        /* Subscribe to notification to receive updates when the user changes its color */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorUpdateNotification:) name:@"userSelectedNewColorNotification" object:nil];
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
        case PPKPeer2PeerDiscoveryUnsupported:
            description = @"unsupported";
            discoveryEnabled_ = YES;
            break;
        case PPKPeer2PeerDiscoveryUnauthorized:
            description = @"unauthorized";
            discoveryEnabled_ = YES;
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
        
        NSString *message = [NSString stringWithFormat:@"%@ (%@, %@)", peer.peerID, discoveryInfo, [self getDescriptionForProximityStrength:peer.proximityStrength]];
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

-(void)discoveryInfoUpdatedForPeer:(PPKPeer*)peer {
    
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

-(void)proximityStrengthChangedForPeer:(PPKPeer*)peer {
    
    NSString *message = [NSString stringWithFormat:@"%@ (%@)", peer.peerID, [self getDescriptionForProximityStrength:peer.proximityStrength]];
    [self logKey:@"P2P proximity" value:message];
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
    [self send:@"From iOS: Hello GEO!" to:peerID];
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
    
#if TARGET_OS_IOS
    if ([locMgr_ respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locMgr_ requestAlwaysAuthorization];
    }
#endif
    
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

-(void)setupNotifications {
    
#if TARGET_OS_IOS && UPA_CONFIGURATION_TYPE > 0
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeAlert);
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
#endif
}

-(void)sendLocalNotificationWhenInBackgroundForPeer:(PPKPeer*)peer withMessage:(NSString*)message {
    
#if TARGET_OS_IOS && UPA_CONFIGURATION_TYPE > 0
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
#if TARGET_OS_IOS

    [self.clearButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    [self.p2pToggleSwitch addTarget:self action:@selector(toggleP2PDiscovery) forControlEvents:UIControlEventValueChanged];
    [self.geoToggleSwitch addTarget:self action:@selector(toggleGeoDiscovery) forControlEvents:UIControlEventValueChanged];

#else
    
    [self setPreferredContentSize:NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.logTextView setBackgroundColor:[NSColor clearColor]];
    [self.logTextView setEditable:NO];
    
    [self.closeButton setTarget:self];
    [self.closeButton setAction:@selector(dismissView)];
    
    [self.clearButton setTarget:self];
    [self.clearButton setAction:@selector(clearLog)];
    
    [self.p2pToggleButton setTarget:self];
    [self.p2pToggleButton setAction:@selector(toggleP2PDiscovery)];
    
    [self.geoToggleButton setTarget:self];
    [self.geoToggleButton setAction:@selector(toggleGeoDiscovery)];
    
#endif
    
    [self updateUIState];
}

-(void)updateUIState {
#if TARGET_OS_IOS
    
    self.p2pToggleSwitch.on = discoveryEnabled_;
    self.geoToggleSwitch.on = (geoEnabled_ && messagingEnabled_);

    self.logTextView.text = logContent_;

#else
    
    if (self.logTextView) {
        NSAttributedString *attributedContent = [[NSAttributedString alloc] initWithString:logContent_ attributes:@{ NSForegroundColorAttributeName: [NSColor darkGrayColor] }];
        [self.logTextView.textStorage setAttributedString:attributedContent];
    }
    
    [self.p2pToggleButton setTitle:[NSString stringWithFormat:@"%@ P2P Discovery", (discoveryEnabled_ ? @"Stop" : @"Start")]];
    [self.geoToggleButton setTitle:[NSString stringWithFormat:@"%@ GEO Discovery", (geoEnabled_ && messagingEnabled_ ? @"Stop" : @"Start")]];
    
#endif
}

-(void)toggleP2PDiscovery {
    
    if (discoveryEnabled_) {
        [PPKController stopP2PDiscovery];
    }
    else {
        [PPKController startP2PDiscoveryWithDiscoveryInfo:discoveryInfo_ stateRestoration:NO];
    }
}

-(void)toggleGeoDiscovery {
    
    if (geoEnabled_ && messagingEnabled_) {
        [PPKController stopOnlineMessaging];
        [PPKController stopGeoDiscovery];
    }
    else {
        [PPKController startGeoDiscovery];
        [PPKController startOnlineMessaging];
    }
}

#if !TARGET_OS_IOS
-(void)dismissView {
    [self.presentingViewController dismissViewController:self];
}
#endif

@end
