# p2pkit.io iOS Quickstart

#### A peer-to-peer proximity SDK for iOS and Android

p2pkit is an easy to use SDK that bundles together several proximity technologies kung-fu style! With p2pkit apps immediately understand their proximity to nearby devices and users, estimate their range and exchange information with them.

![p2pkit - proximity starts here](p2pkit-quickstart-ios.gif)


## Get Started

1. In order to use p2pkit you need an application key, you can obtain one here:
[Get your Application Key](http://p2pkit.io/signup.html)

2. This quickstart app requires p2pkit framework which needs to be downloaded separately, please follow the instructions here:
[Download p2pkit](http://p2pkit.io/developer/get-started/ios/#download)
3. Drag P2PKit.framework into your Xcode project folder. (Make sure the "Copy items if needed" is checked)

4. Head to the AppDelegate.m file and replace ``<YOUR APPLICATION KEY>`` with your new key:

```
[PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
```


> In general, a tutorial as well as all other documentation is available on the developer section of our website:
[http://p2pkit.io/developer](http://p2pkit.io/developer)


### Get Started Video

[![Get started video](https://i.ytimg.com/vi/_tL371MUNDg/mqdefault.jpg)](https://youtu.be/_tL371MUNDg)

[Watch video here](https://youtu.be/_tL371MUNDg)


### p2pkit License
* By using P2PKit you agree to abide by our Terms of Service, License Agreement and Policies which are available here: http://p2pkit.io/policy.html
* Please refer to "Third_party_licenses.txt" included with P2PKit.framework for 3rd party software that P2PKit.framework may be using - You will need to abide by their licenses as well
