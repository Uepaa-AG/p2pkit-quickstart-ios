# Wait!
### Something big is coming, check out our preview branch and get first look at the most significant update to p2pkit yet!
### [Click here](https://github.com/Uepaa-AG/p2pkit-quickstart-ios/tree/preview)

[![p2pkit - proximity starts here](p2pkit-quickstart-ios.gif)](https://github.com/Uepaa-AG/p2pkit-quickstart-ios/tree/preview)

# p2pkit.io (beta) Quickstart
#### A hyperlocal interaction toolkit
p2pkit is an easy to use SDK that bundles together several discovery technologies kung-fu style! With just a few lines of code, p2pkit enables you to accurately discover and directly message users nearby.

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

Download p2pkit.framework (beta): [P2PKit.framework ZIP](http://p2pkit.io/maven2/ch/uepaa/p2p/p2pkit-ios/0.1.6/p2pkit-ios-0.1.6.zip) [SHA1](http://p2pkit.io/maven2/ch/uepaa/p2p/p2pkit-ios/0.1.6/p2pkit-ios-0.1.6.zip.sha1)

### Signup

Request your personal application key: http://p2pkit.io/signup.html

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

Initialize p2pkit with your personal application key

```objc
OBJECTIVE-C
[PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
```
```swift
SWIFT
PPKController.enableWithConfiguration("<YOUR APPLICATION KEY>", observer:self)
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
    PPKController.startP2PDiscovery();
    PPKController.startGeoDiscovery();
    PPKController.startOnlineMessaging();
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
OBJECTIVE-C
-(void)p2pPeerDiscovered:(NSString*)peerID {
	NSLog(@"%@ is here", peerID);
}

-(void)p2pPeerLost:(NSString*)peerID {
	NSLog(@"%@ is no longer here", peerID);
}
```
```swift
SWIFT
func p2pPeerDiscovered(peerID: String!) {
    NSLog("%@ is here", peerID);
}

func p2pPeerLost(peerID: String!) {
    NSLog("%@ is no longer here", peerID);
}
```
### Online Messaging

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
    NSLog("Message received from %@: %@", peerID, NSString(data: messageBody, encoding:NSUTF8StringEncoding)!);
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
    PPKController.sendMessage("Hello World".dataUsingEncoding(NSUTF8StringEncoding), withHeader: "SimpleChatMessage", to: peerID);
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
OBJECTIVE-C
    /* Avoid sending to many location updates, set a distance filter */
    [myCLLocationManager setDistanceFilter:200];
```

```swift
SWIFT
    /* Avoid sending to many location updates, set a distance filter */
    myCLLocationManager.distanceFilter = 200;
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
    PPKController.updateUserLocation(locations.last as! CLLocation);
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
            self.startLocationUpdates();

        case .Suspended, .Stopped:
            self.stopLocationUpdates();
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
    NSLog("%@ is around", peerID);
}

func geoPeerLost(peerID: String!) {
    NSLog("%@ is no longer around", peerID);
}
```

## Documentation

For more details and further information, please refer to the `PPKController.h` header file
```objc
<P2PKit/PPKController.h>
```
### p2pkit License
* By using P2PKit.framework you agree to abide by our License (which is included with P2PKit.framework) and Terms Of Service available at http://www.p2pkit.io/policy.html
* Please refer to "Third_party_licenses.txt" included with P2PKit.framework for 3rd party software that P2PKit.framework may be using - You will need to abide by their licenses as well
