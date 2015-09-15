# p2pkit.io (developer preview) Quickstart
#### A hyperlocal interaction toolkit

p2pkit is an easy to use SDK that bundles together several proximity technologies kung-fu style! With p2pkit apps immediately understand their proximity to nearby devices and users, verify their identity, and exchange information with them.

![p2pkit - proximity starts here](p2pkit-quickstart-ios.gif)

## Quickstart video
[![Get started video](https://i.ytimg.com/vi_webp/_tL371MUNDg/mqdefault.webp)](https://youtu.be/_tL371MUNDg)

[Watch video here](https://youtu.be/_tL371MUNDg)

## Table of Contents

**[Download](#download)**  
**[Signup](#signup)**  
**[Setup Xcode project](#setup-xcode-project)**  
**[Initialization](#initialization)**  
**[P2P Discovery](#p2p-discovery)**  
**[Online Messaging (beta)](#online-messaging-beta)**  
**[GEO Discovery (beta)](#geo-discovery-beta)**  
**[Documentation](#documentation)**  
**[p2pkit License](#p2pkit-license)**  


### Download

Download p2pkit.framework (1.0.1-preview): [P2PKit.framework ZIP](http://p2pkit.io/ios-preview/P2PKit-ios-1.0.1-preview.zip) [SHA1](http://p2pkit.io/ios-preview/P2PKit-ios-1.0.1-preview.zip.sha1)

##### (this preview expires on Sept 30th, 2015)

### Signup

We would love you to signup here: http://p2pkit.io/signup.html

However, for this preview version no application key is required as it already includes one (expires on the 30th of September 2015).

### Setup Xcode project
**P2PKit.framework supports both Objective-C and Swift**

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
OBJECTIVE-C
#import <P2PKit/P2Pkit.h>
```

```
SWIFT
If you are using Swift you would need to import P2PKit.framework in your project's "Objective-C Bridging Header" file (#import <P2PKit/P2Pkit.h>). If you do not yet have an "Objective-C Bridging Header" file in your project please refer to the Swift documentation for instructions how to create one.
```

Initialize the developer preview of p2pkit

```objc
OBJECTIVE-C
[PPKController enableDeveloperPreviewWithObserver:self];
```
```swift
SWIFT
PPKController.enableDeveloperPreviewWithObserver(self)
```

Conform to the `PPKControllerDelegate` protocol by implementing the optional methods, you could then start P2P discovery, GEO discovery or online messaging when p2pkit is ready

```objc
OBJECTIVE-C
-(void)PPKControllerInitialized {
	[PPKController startP2PDiscovery];
	[PPKController startGeoDiscovery];
	[PPKController startOnlineMessaging];
}
```
```swift
SWIFT
func PPKControllerInitialized() {
    PPKController.startP2PDiscovery()
    PPKController.startGeoDiscovery()
    PPKController.startOnlineMessaging()
}
```

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
-(void)didUpdateP2PDiscoveryInfoForPeer:(PPKPeer*)peer {
	NSString *discoveryInfo = [[NSString alloc] initWithData:peer.discoveryInfo encoding:NSUTF8StringEncoding];
	NSLog(@"%@ has updated discovery info: %@", peer.peerID, discoveryInfo);
}
```
```swift
SWIFT
func didUpdateP2PDiscoveryInfoForPeer(peer: PPKPeer!) {
	let discoveryInfo = NSString(data: peer.discoveryInfo, encoding: NSUTF8StringEncoding)
	NSLog("%@ has updated discovery info: %@", peer.peerID, discoveryInfo!)
}
```

### Online Messaging (beta)

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

For more details and further information, please refer to the `PPKController.h` header file
```objc
<P2PKit/PPKController.h>
```
### p2pkit License
* By using P2PKit.framework you agree to abide by our License, Terms Of Service and other policies which are included with P2PKit.framework
* Please refer to "Third_party_licenses.txt" included with P2PKit.framework for 3rd party software that P2PKit.framework may be using - You will need to abide by their licenses as well
