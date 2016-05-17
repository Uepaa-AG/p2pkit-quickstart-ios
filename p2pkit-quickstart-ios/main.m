//
//  main.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#if TARGET_OS_IOS

#import "AppDelegate.h"
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

#else

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}

#endif
