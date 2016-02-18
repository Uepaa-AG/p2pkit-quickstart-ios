# p2pkit.io iOS Quickstart
#### A hyperlocal interaction toolkit

p2pkit is an easy to use SDK that bundles together several proximity technologies kung-fu style! With p2pkit apps immediately understand their proximity to nearby devices and users, 'verify' their identity, and exchange information with them.

![p2pkit - proximity starts here](p2pkit-quickstart-ios.gif)

## Table of Contents

**[Download](#download)**  
**[Signup](#signup)**  
**[Setup](#setup)**  
**[Initialization](#initialization)**  
**[P2P Discovery](#p2p-discovery)**  
**[Proximity Ranging (beta)](#proximity-ranging-beta)**  
**[Online Messaging (beta)](#online-messaging-beta)**  
**[GEO Discovery (beta)](#geo-discovery-beta)**  
**[Documentation](#documentation)**  
**[p2pkit License](#p2pkit-license)**  

### Get started video

[![Get started video](https://i.ytimg.com/vi/_tL371MUNDg/mqdefault.jpg)](https://youtu.be/_tL371MUNDg)

[Watch video here](https://youtu.be/_tL371MUNDg)

### Download

Download p2pkit.framework (1.1.1): [P2PKit.framework ZIP](http://p2pkit.io/maven2/ch/uepaa/p2p/p2pkit-ios/1.1.1/p2pkit-ios-1.1.1.zip) [SHA1](http://p2pkit.io/maven2/ch/uepaa/p2p/p2pkit-ios/1.1.1/p2pkit-ios-1.1.1.zip.sha1)

Release Notes can be found here: http://p2pkit.io/changelog.html

### Signup

Request your evaluation/testing application key: http://p2pkit.io/signup.html

### Setup

**If you are using [CocoaPods](https://cocoapods.org/), then add these lines to your Podfile:**

```ruby
platform :ios, '7.1'
pod 'p2pkit'
```

#### Manual setup without CocoaPods

**P2PKit.framework supports both Objective-C and Swift**

1: Add p2pkit
* Drag P2PKit.framework into your Xcode project folder. (Make sure the "Copy items if needed" is checked)

2: Add dependencies
* Click on Targets -> your app name -> and then the 'Build Phases' tab
* Expand 'Link Binary With Libraries' and make sure P2PKit.framework is in the list, if not then add it!
* Click the + button and add the additional dependencies mentioned below:
 * CoreBluetooth.framework
 * CoreLocation.framework
 * libicucore.tbd
 * CFNetwork.framework
 * Security.framework
 * Foundation.framework

 **p2pkit is built with ARC (automatic reference counting) and supports iOS 7.1 and above**

### Initialization

Import the p2pkit header

```objc
OBJECTIVE-C
#import <P2PKit/P2Pkit.h>
```

```
SWIFT
If you are using Swift you would need to import P2PKit.framework in your project's "Objective-C Bridging Header" file (#import <P2PKit/P2Pkit.h>). If you do not yet have an "Objective-C Bridging Header" file in your project please refer to the Swift documentation for instructions how to create one.
```

Initialize p2pkit with your personal application key

```objc
OBJECTIVE-C
[PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
```
```swift
SWIFT
PPKController.enableWithConfiguration("<YOUR APPLICATION KEY>", observer:self)
```

Conform to the `PPKControllerDelegate` protocol by implementing the optional methods, you could then start P2P discovery when p2pkit is ready

```objc
OBJECTIVE-C
-(void)PPKControllerInitialized {
	[PPKController startP2PDiscoveryWithDiscoveryInfo:nil];
}
```
```swift
SWIFT
func PPKControllerInitialized() {
    PPKController.startP2PDiscoveryWithDiscoveryInfo(nil);
}
```

p2pkit is using the CoreBluetooth State Preservation and Restoration API. State restoration enables p2pkit-enabled apps to continue to discover and be discovered even if the application has crashed or was terminated by the OS. In order for state restoration to work, you would need to `startP2PDiscoveryWithDiscoveryInfo:` when the application is relaunched.

**Note:** Please make sure you `stopP2PDiscovery` when your end-user no longer wishes to discover or be discovered.


### P2P Discovery

With p2p discovery you can understand your proximity to nearby devices and exchange information with them. p2pkit supports discovery, lost and payload APIs.

For starts, add BLE (Bluetooth low energy) permissions to your `Info.plist` file
```
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>bluetooth-peripheral</string>
</array>
```


Start p2p discovery and feel free to pass in additional data (such as your own user ID) which will be discovered by other peers nearby

```objc
OBJECTIVE-C
	NSData *myDiscoveryInfo = [@"Hello from Objective-C!" dataUsingEncoding:NSUTF8StringEncoding];
	[PPKController startP2PDiscoveryWithDiscoveryInfo:myDiscoveryInfo];
```
```swift
SWIFT
	let myDiscoveryInfo = "Hello from Swift!".dataUsingEncoding(NSUTF8StringEncoding)
	PPKController.startP2PDiscoveryWithDiscoveryInfo(myDiscoveryInfo)
```
At a later stage, publish new discovery info which will be pushed to nearby peers

```objc
OBJECTIVE-C
	NSData *myDiscoveryInfo = [@"p2pkit is awesome!" dataUsingEncoding:NSUTF8StringEncoding];
	[PPKController pushNewP2PDiscoveryInfo:myDiscoveryInfo];
```
```swift
SWIFT
	let myDiscoveryInfo = "p2pkit is awesome!".dataUsingEncoding(NSUTF8StringEncoding)
	PPKController.pushNewP2PDiscoveryInfo(myDiscoveryInfo)
```

Implement `PPKControllerDelegate` protocol to receive P2P discovery events and access peer info

```objc
OBJECTIVE-C
-(void)p2pPeerDiscovered:(PPKPeer*)peer {
	NSString *discoveryInfoString = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
	NSLog(@"%@ is here with discovery info: %@", peer.peerID, discoveryInfoString);
}

-(void)p2pPeerLost:(PPKPeer*)peer {
	NSLog(@"%@ is no longer here", peer.peerID);
}
```

```swift
SWIFT
func p2pPeerDiscovered(peer: PPKPeer!) {
    let discoveryInfoString = NSString(data: peer.discoveryInfo, encoding:NSUTF8StringEncoding)
    NSLog("%@ is here with discovery info: %@", peer.peerID, discoveryInfoString!)
}

func p2pPeerLost(peer: PPKPeer!) {
    NSLog("%@ is no longer here", peer.peerID)
}
```

Receive the updated discovery info from a peer

```objc
OBJECTIVE-C
-(void)discoveryInfoUpdatedForPeer:(PPKPeer*)peer {
	NSString *discoveryInfo = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
	NSLog(@"%@ has updated discovery info: %@", peer.peerID, discoveryInfo);
}
```
```swift
SWIFT
func discoveryInfoUpdatedForPeer(peer: PPKPeer!) {
	let discoveryInfo = NSString(data: peer.discoveryInfo, encoding: NSUTF8StringEncoding)
	NSLog("%@ has updated discovery info: %@", peer.peerID, discoveryInfo!)
}
```

### Proximity Ranging (beta)

Proximity Ranging adds context to the discovery events by providing 5 levels of proximity strength (from “immediate” to “extremely weak”). You could associate "proximity strength" with distance, but due to the unreliable nature of signal strength (different hardware, environmental conditions, etc.) we preferred not to associate the two. Nevertheless, in many cases you will be able to determine who is the closest peer to you (if he is significantly closer than others).

**Note: This feature is in beta and you should only use it for evaluation and testing purposes.**

Please enable the Beta feature first

```objc
OBJECTIVE-C
    [PPKController enableProximityRanging];
```
```swift
SWIFT
    PPKController.enableProximityRanging()
```

Proximity Strength is a property of to the `PPKPeer` object. Updates are received when the proximity strength of a nearby peer changes, for updates you would need to implement the delegate method `-(void)proximityStrengthChangedForPeer:(PPKPeer*)peer`.

```objc
OBJECTIVE-C
-(void)proximityStrengthChangedForPeer:(PPKPeer*)peer {
    if (peer.proximityStrength > PPKProximityStrengthWeak) {
        NSLog(@"%@ is in range, do something with it", peer.peerID);
    }
    else {
        NSLog(@"%@ is not yet in range", peer.peerID);
    }
}
```
```swift
SWIFT
func proximityStrengthChangedForPeer(peer: PPKPeer!) {
    if (peer.proximityStrength.rawValue > PPKProximityStrength.Weak.rawValue) {
        NSLog("%@ is in range, do something with it", peer.peerID);
    }
    else {
        NSLog("%@ is not yet in range", peer.peerID);
    }
}
```

**Note** If the proximity strength for a peer cannot be determined, the proximity strength value will be `PPKProximityStrengthUnknown`

### Online Messaging (beta)

Start by enabling the online messaging feature first

```objc
OBJECTIVE-C
	[PPKController startOnlineMessaging];
```
```swift
SWIFT
    PPKController.startOnlineMessaging()
```

Implement `PPKControllerDelegate` protocol to receive online messages

```objc
OBJECTIVE-C
-(void)messageReceived:(NSData*)messageBody header:(NSString*)messageHeader from:(NSString*)peerID {
	NSLog(@"Message received from %@: %@", peerID,
		[[NSString alloc] initWithData:messageBody encoding:NSUTF8StringEncoding]);
}
```
```swift
SWIFT
func messageReceived(messageBody: NSData!, header messageHeader: String!, from peerID: String!) {
    NSLog("Message received from %@: %@", peerID, NSString(data: messageBody, encoding:NSUTF8StringEncoding)!)
}
```

Send online messages to discovered peers

```objc
OBJECTIVE-C
    [PPKController sendMessage:[@"Hello World" dataUsingEncoding:NSUTF8StringEncoding]
                   withHeader:@"SimpleChatMessage" to:peerID];
```
```swift
SWIFT
    PPKController.sendMessage("Hello World".dataUsingEncoding(NSUTF8StringEncoding), withHeader: "SimpleChatMessage", to: peerID)
```

### GEO Discovery (beta)

Start by enabling the GEO Discovery first

```objc
OBJECTIVE-C
	[PPKController startGeoDiscovery];
```
```swift
SWIFT
    PPKController.startGeoDiscovery()
```

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
OBJECTIVE-C
    /* Avoid sending to many location updates, set a distance filter */
    [myCLLocationManager setDistanceFilter:200];
```

```swift
SWIFT
    /* Avoid sending to many location updates, set a distance filter */
    myCLLocationManager.distanceFilter = 200
```

```objc
OBJECTIVE-C
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [PPKController updateUserLocation:[locations lastObject]];
}
```
```swift
SWIFT
func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    PPKController.updateUserLocation(locations.last as! CLLocation)
}
```

Be smart and only report GEO locations when `PPKGeoDiscoveryRunning`. Implement `PPKControllerDelegate` protocol to report your GEO location when you have internet connectivity

```objc
OBJECTIVE-C
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
```swift
SWIFT
func geoDiscoveryStateChanged(state: PPKGeoDiscoveryState) {

    switch state {
        case .Running:
            self.startLocationUpdates()

        case .Suspended, .Stopped:
            self.stopLocationUpdates()
    }
}
```
Implement `PPKControllerDelegate` protocol to receive GEO discovery events

```objc
OBJECTIVE-C
-(void)geoPeerDiscovered:(NSString*)peerID {
	NSLog(@"%@ is around", peerID);
}

-(void)geoPeerLost:(NSString*)peerID {
	NSLog(@"%@ is no longer around", peerID);
}
```
```swift
SWIFT
func geoPeerDiscovered(peerID: String!) {
    NSLog("%@ is around", peerID)
}

func geoPeerLost(peerID: String!) {
    NSLog("%@ is no longer around", peerID)
}
```

## Documentation

For more details and further information, please refer to the `P2PKit.h` header file
```objc
<P2PKit/P2PKit.h>
```
### p2pkit License
* By using P2PKit.framework you agree to abide by our Terms of Service, License Agreement and Policies which are available at the following address: http://p2pkit.io/policy.html
* Please refer to "Third_party_licenses.txt" included with P2PKit.framework for 3rd party software that P2PKit.framework may be using - You will need to abide by their licenses as well
