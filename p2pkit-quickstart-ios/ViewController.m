//
//  ViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "ViewController.h"
#import <P2PKit/P2PKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<PPKControllerDelegate,CLLocationManagerDelegate> {
    CLLocationManager* locMgr_;
    
    BOOL p2pkitEnabled_;
    BOOL p2pkitFirstInit_;
    
    BOOL discoveryEnabled_;
    BOOL geoEnabled_;
    BOOL messagingEnabled_;
}

@property (weak, nonatomic) IBOutlet UISwitch *masterToggleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *discoveryToggleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *geoToggleSwitch;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p2pkitFirstInit_ = YES;
    
    [self setupUI];
    [self enableP2PKit];
}

-(void)enableP2PKit {
    [PPKController enableWithConfiguration:@"<YOUR APP KEY>" observer:self];
}

-(void)disableP2PKit {
    
    [PPKController disable];
    p2pkitEnabled_ = NO;
}

#pragma mark - PPKControllerDelegate

-(void)PPKControllerInitialized {
    
    p2pkitEnabled_ = YES;
    [self updateUIState];
    
    if (p2pkitFirstInit_) {
        [PPKController startP2PDiscovery];
        [PPKController startGeoDiscovery];
        [PPKController startOnlineMessaging];
        
        p2pkitFirstInit_ = NO;
    }
    
    [self logKey:@"My ID (p2pkit init success!)" value:[PPKController myPeerID]];
}

-(void)PPKControllerFailedWithError:(NSError*)error {
    
    NSString *description;
    
    switch ((PPKErrorCode) error.code) {
        case PPKErrorAppKeyInvalid:
            description = @"Invalid app key";
            break;
        case PPKErrorAppKeyExpired:
            description = @"Expired app key";
            break;
        case PPKErrorOnlineProtocolVersionNotSupported:
            description = @"Server protocol mismatch";
            break;
        case PPKErrorOnlineAppKeyInvalid:
            description = @"Invalid app key";
            break;
        case PPKErrorOnlineAppKeyExpired:
            description = @"Expired app key";
            break;
    }
    
    p2pkitEnabled_ = NO;
    [self updateUIState];
    
    [self logKey:@"SDK init error" value:description];
}

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

-(void)p2pPeerDiscovered:(NSString*)peerID {
    [self logKey:@"P2P discovered" value:peerID];
}

-(void)p2pPeerLost:(NSString*)peerID {
    [self logKey:@"P2P lost" value:peerID];
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

#pragma mark - Helpers

-(void)logKey:(NSString*)key value:(NSString*)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.text = [NSString stringWithFormat:@"%@: %@\n%@", key, value, self.logTextView.text];
    });
}

-(void)send:(NSString*)message to:(NSString*)peerID {
    [PPKController sendMessage:[message dataUsingEncoding:NSUTF8StringEncoding] withHeader:@"SimpleChatMessage" to:peerID];
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

#pragma mark - UI Actions

-(void)setupUI {
    [self.clearButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    
    [self.masterToggleSwitch addTarget:self action:@selector(toggleP2PKitEnable) forControlEvents:UIControlEventValueChanged];
    [self.discoveryToggleSwitch addTarget:self action:@selector(toggleP2PDiscovery) forControlEvents:UIControlEventValueChanged];
    [self.geoToggleSwitch addTarget:self action:@selector(toggleGeoDiscovery) forControlEvents:UIControlEventValueChanged];
    
    [self updateUIState];
}

-(void)updateUIState {
    self.masterToggleSwitch.on = p2pkitEnabled_;
    self.discoveryToggleSwitch.on = discoveryEnabled_;
    self.geoToggleSwitch.on = (geoEnabled_ && messagingEnabled_);
    
    self.discoveryToggleSwitch.enabled = p2pkitEnabled_;
    self.geoToggleSwitch.enabled = p2pkitEnabled_;
}

-(void)toggleP2PKitEnable {
    
    if (self.masterToggleSwitch.on) {
        [self enableP2PKit];
    }
    else {
        [self disableP2PKit];
        [self updateUIState];
    }
}

-(void)toggleP2PDiscovery {
    
    if (self.discoveryToggleSwitch.on) {
        [PPKController startP2PDiscovery];
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

-(void)clearLog {
    self.logTextView.text = @"";
}

@end
