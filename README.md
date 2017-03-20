# p2pkit.io iOS & Mac Quickstart

#### A peer-to-peer proximity SDK for iOS, OS X and Android

p2pkit is an easy to use SDK that bundles together several proximity technologies kung-fu style! With p2pkit apps immediately understand their proximity to nearby devices and users, estimate their range and exchange information with them.

![p2pkit - proximity starts here](p2pkit-quickstart-ios.gif)


## Get Started

1. Using p2pkit requires an application key, start by creating a p2pkit account here:
[Create p2pkit account](http://p2pkit.io/signup.html)

2. Once you have an account you can log-in to the console and create an application key: [Create your Application Key](https://p2pkit-console.uepaa.ch/login)

  NOTE: p2pkit validates bundleID/package_name so don't forget to add ``ch.uepaa.p2pkit-quickstart-ios`` to the known BundleID/package_names when creating your application key

3. This quickstart app requires p2pkit framework which needs to be downloaded separately, please follow the instructions here:
[Download p2pkit](http://p2pkit.io/developer/get-started/ios/#download)

4. Drag P2PKit.framework to the <code>p2pkit-quickstart-ios/dependencies/[ios/osx]</code> folder for the appropriate platform (iOS/Mac).

5. Head to the P2PKitController.m file and replace ``<YOUR APPLICATION KEY>`` with your new key:

  ```
  [PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
  ```


> In general, a tutorial as well as all other documentation is available on the developer section of our website:
[http://p2pkit.io/developer](http://p2pkit.io/developer)


### Get Started Video

[![Get started video](https://i.ytimg.com/vi/baXSvr4m6wI/mqdefault.jpg)](https://www.youtube.com/watch?v=baXSvr4m6wI)

[Watch video here](https://www.youtube.com/watch?v=baXSvr4m6wI)


### p2pkit License
* By using P2PKit you agree to abide by our Terms of Service, License Agreement and Policies which are available here: http://p2pkit.io/policy.html
* Please refer to "Third_party_licenses.txt" included with P2PKit.framework for 3rd party software that P2PKit.framework may be using - You will need to abide by their licenses as well
