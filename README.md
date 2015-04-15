# p2pkit.io (beta) Quickstart

Rocket science in candy wrap! With just a few lines of code, p2pkit packs a punch by enabling you to accurately discover and directly message users nearby!

### Table of Contents


**[Download](#download)**  
**[Signup](#signup)**  
**[Setup Xcode project](#setup-xcode-project)**  
**[Initialization](#initialization)**  
**[P2P Discovery](#p2p-discovery)**  
**[Online Messaging](#online-messaging)**  
**[GEO Discovery](#geo-discovery)**  
**[Documentation](#documentation)**  
**[p2pkit License](#p2pkit-license)**  


### Download

Download p2pkit.framework (beta): [P2PKit.framework ZIP](http://p2pkit.io/maven2/ch/uepaa/p2p/p2pkit-ios/0.1.4/p2pkit-ios-0.1.4.zip) [SHA1](http://p2pkit.io/maven2/ch/uepaa/p2p/p2pkit-ios/0.1.4/p2pkit-ios-0.1.4.zip.sha1)

### Signup

Request your personal application key: http://p2pkit.io/signup.html

### Setup Xcode project

1: Add p2pkit

* Drag P2PKit.framework into your Xcode project folder. (Make sure the "Copy items if needed" is checked)

2: Add dependencies
* Click on Targets -> your app name -> and then the 'Build Phases' tab
* Expand 'Link Binary With Libraries' and make sure P2PKit.framework is in the list, if not then add it!
* Click the + button and add the additional dependencies mentioned below:
 * CoreBluetooth.framework
 * CoreLocation.framework
 * libicucore.dylib
 * CFNetwork.framework
 * Security.framework
 * Foundation.framework

 **p2pkit is built with ARC (automatic reference counting)**
 
### Initialization

Import the p2pkit header

```objc
#import <P2PKit/P2PKit.h>
```

Initialize p2pkit with your personal application key

```objc
[PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
```

Implement `PPKControllerDelegate` protocol and start P2P discovery,GEO discovery or online messaging when p2pkit is ready

```objc
-(void)PPKControllerInitialized {
	[PPKController startP2PDiscovery];
	[PPKController startGeoDiscovery];
	[PPKController startOnlineMessaging];
}
```

### P2P Discovery

Add BLE (Bluetooth low energy) permissions to your `Info.plist` file
```
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>bluetooth-peripheral</string>
</array>
```

Implement `PPKControllerDelegate` protocol to receive P2P discovery events

```objc
-(void)p2pPeerDiscovered:(NSString*)peerID {
	NSLog(@"%@ is here", peerID);
}

-(void)p2pPeerLost:(NSString*)peerID {
	NSLog(@"%@ is no longer here", peerID);
}
```

### Online Messaging

Implement `PPKControllerDelegate` protocol to receive online messages

```objc
-(void)messageReceived:(NSData*)messageBody header:(NSString*)messageHeader 
	   from:(NSString*)peerID 
{
	NSLog(@"Message received from %@: %@", peerID,
		[[NSString alloc] initWithData:messageBody encoding:NSUTF8StringEncoding]);
}
```

Send online messages to discovered peers

```objc
    [PPKController sendMessage:[@"Hello World" dataUsingEncoding:NSUTF8StringEncoding] 
                   withHeader:@"SimpleChatMessage" to:destination_];
```

### GEO Discovery

Add location permissions to your `Info.plist` file
```
<key>NSLocationAlwaysUsageDescription</key>
<string>Your description here</string>
// OR
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your description here</string>

<key>UIBackgroundModes</key>
<array>
	<string>location</string>
</array>
```

Use `CLLocationManager` and implement `CLLocationManagerDelegate` protocol to report your GEO location

```objc
    /* Avoid sending to many location updates, set a distance filter */
    [myCLLocationManager setDistanceFilter:200];
```

```objc
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [PPKController updateUserLocation:[locations lastObject]];
}
```
Be smart and only report GEO locations when `PPKGeoDiscoveryRunning`. Implement `PPKControllerDelegate` protocol to report your GEO location when you have internet connectivity

```objc
-(void)geoDiscoveryStateChanged:(PPKGeoDiscoveryState)state {

 	switch (state) {
    	case PPKGeoDiscoveryRunning:
        	[self startLocationUpdates];
            break;
            
        case PPKGeoDiscoverySuspended:
        case PPKGeoDiscoveryStopped:
            [self stopLocationUpdates];
            break;
	}
}
```

Implement `PPKControllerDelegate` protocol to receive GEO discovery events

```objc
-(void)geoPeerDiscovered:(NSString*)peerID {
	NSLog(@"%@ is around", peerID);
}

-(void)geoPeerLost:(NSString*)peerID {
	NSLog(@"%@ is no longer around", peerID);
}
```

## Documentation

For more details and further information, please refer to the PPKController.h header file
```objc
<P2PKit/PPKController.h>
```
### p2pkit License
* By using P2PKit.framework you agree to abide by our License (which is included with P2PKit.framework) and Terms Of Service available at http://www.p2pkit.io/policy.html
* Please refer to "Third_party_licenses.txt" included with P2PKit.framework for 3rd party software that P2PKit.framework may be using - You will need to abide by their licenses as well
