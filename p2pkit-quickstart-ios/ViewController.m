//
//  ViewController.m
//  p2pkit-quickstart-ios
//
//  Created by Christian Tschenett on 01/04/15.
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import "ViewController.h"
#import <P2PKit/P2PKit.h>
#import <CoreLocation/CoreLocation.h>

#define GPS_DEFAULT_DESIRED_ACCURACY 200
#define GPS_DEFAULT_DISTANCE_FILTER 200

@interface ViewController ()<PPKControllerDelegate,CLLocationManagerDelegate> {
    CLLocationManager* locMgr_;
}
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PPKController enableWithConfiguration:@"eyJhcHBJZCI6MTAxNiwidmFsaWRVbnRpbCI6MTY1MjcsImFwcFVVVUlEIjoiNDY1RUZCQUEtNkU5Qi00QTJGLUJBNjEtNkRGRjgxMjJFQkFFIiwic2lnbmF0dXJlIjoibmVCM3NVTjZhd3lUdWFoZmpCNHV2R01lMVhKc0hmR1RNRVFSYW9ZWnprK1hGaUM4NG1nQ3lmTzg1M3JaK3BoMDgwUGRMQ0lWVVdvbFJPNUJhV0hlVUYwbElZRy9FaXNxQzBNd0lyV2o2QmdSVm9yTEZqeXI4NmprNHB5YmloZFI3TVhESE93MElac3hoM25LZXRuaG1Ec0dmcVJEZTh1cmlwSTc0YjRteE84PSJ9" observer:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - PPKControllerDelegate

-(void)PPKControllerInitialized {
    [PPKController startP2PDiscovery];
    [PPKController startGeoDiscovery];
    [PPKController startOnlineMessaging];
    
    [self logKey:[PPKController userID] value:@"My ID (SDK init success!)"];
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
    [self logKey:@"SDK init error" value:description];
}

-(void)p2pDiscoveryStateChanged:(PPKPeer2PeerDiscoveryState)state {
    NSString *description;
    switch (state) {
        case PPKPeer2PeerDiscoveryStopped:
            description = @"stopped";
            break;
        case PPKPeer2PeerDiscoverySuspended:
            description = @"suspended";
            break;
        case PPKPeer2PeerDiscoveryRunning:
            description = @"running";
            break;
    }
    [self logKey:@"P2P state" value:description];
}

-(void)p2pPeerDiscovered:(NSString*)peerID {
    [self logKey:peerID value:@"P2P discovered"];
    
    [self send:@"Message: Hello P2P!" to:peerID];
}

-(void)p2pPeerLost:(NSString*)peerID {
    [self logKey:peerID value:@"P2P lost"];
}

-(void)onlineMessagingStateChanged:(PPKOnlineMessagingState)state {
    NSString *description;
    switch (state) {
        case PPKOnlineMessagingRunning:
            description = @"running";
            [self startLocationUpdates];
            break;
        case PPKOnlineMessagingSuspended:
            description = @"suspended";
            [self stopLocationUpdates];
            break;
        case PPKOnlineMessagingStopped:
            description = @"stopped";
            [self stopLocationUpdates];
            break;
    }
    [self logKey:@"Online messaging state" value:description];
}

-(void)messageReceived:(NSData*)messageBody header:(NSString*)messageHeader from:(NSString*)peerID
{
    [self logKey:peerID value:[[NSString alloc] initWithData:messageBody encoding:NSUTF8StringEncoding]];
}

-(void)geoDiscoveryStateChanged:(PPKGeoDiscoveryState)state {
    NSString *description;
    switch (state) {
        case PPKGeoDiscoveryRunning:
            description = @"running";
            [self startLocationUpdates];
            break;
        case PPKGeoDiscoverySuspended:
            description = @"suspended";
            [self stopLocationUpdates];
            break;
        case PPKGeoDiscoveryStopped:
            description = @"stopped";
            [self stopLocationUpdates];
            break;
    }
    [self logKey:@"GEO state" value:description];
}

-(void)geoPeerDiscovered:(NSString*)peerID {
    [self logKey:peerID value:@"GEO discovered"];
    
    [self send:@"Message: Hello GEO!" to:peerID];
}

-(void)geoPeerLost:(NSString*)peerID {
    [self logKey:peerID value:@"GEO lost"];
}

#pragma mark - Helpers

-(void)logKey:(NSString*)key value:(NSString*)value {
    self.logTextView.text = [NSString stringWithFormat:@"%@: %@\n%@", key, value, self.logTextView.text];
}

-(void)send:(NSString*)message to:(NSString*)peerID {
    [PPKController sendMessage:[message dataUsingEncoding:NSUTF8StringEncoding] withHeader:@"SimpleChatMessage" to:peerID];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count < 1) {
        return;
    }
    
    CLLocation *loc = [locations objectAtIndex:0];
    if (!loc) {
        return;
    }
    
    [PPKController updateUserLocation:loc];
}

#pragma mark - CLLocationManager Helpers

-(void)startLocationUpdates {
    if (locMgr_) {
        return;
    }
    
    locMgr_ = [CLLocationManager new];
    [locMgr_ setDelegate:self];
    [locMgr_ setDesiredAccuracy:GPS_DEFAULT_DESIRED_ACCURACY];
    [locMgr_ setDistanceFilter:GPS_DEFAULT_DISTANCE_FILTER];
    [locMgr_ setPausesLocationUpdatesAutomatically:NO];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([locMgr_ respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locMgr_ requestAlwaysAuthorization];
    }
#endif
    
    [locMgr_  startUpdatingLocation];
}

-(void)stopLocationUpdates {
    if (!locMgr_) {
        return;
    }
    
    [locMgr_ stopUpdatingLocation];
    [locMgr_ setDelegate:nil];
    locMgr_ = nil;
}

@end
