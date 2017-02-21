//
//  ConsoleViewControlleriOS.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//


#import "ConsoleViewControlleriOS.h"

@interface ConsoleViewControlleriOS ()
@property (weak, nonatomic) IBOutlet UISwitch *discoveryToggleSwitch;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@end

@implementation ConsoleViewControlleriOS

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
    
#if UPA_CONFIGURATION_TYPE > 0
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
    
    [self.clearButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    [self.discoveryToggleSwitch addTarget:self action:@selector(toggleDiscovery) forControlEvents:UIControlEventValueChanged];
    [self updateUIState];
}

-(void)updateUIState {

    self.discoveryToggleSwitch.on = [self getDiscoveryEnabled];
    self.logTextView.text = [self getLogContent];
}

@end
