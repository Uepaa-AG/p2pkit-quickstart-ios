//
//  NearbyPeersViewController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>

#import "NearbyPeersViewController.h"
#import "DLForcedGraphView.h"
#import "DLEdge.h"
#import "ColorPickerViewController.h"


@interface NearbyPeersViewController () <DLGraphSceneDelegate> {
    
    DLGraphScene *graphScene_;
    
    UIColor *ownColor_;
    SKShapeNode *ownNode_;
    
    NSMutableDictionary *nearbyPeers_;
    NSMutableDictionary *peerNodes_;
    
    NSData *discoveryInfo_;
    NSUInteger nextNodeIndex_;
}

@property (strong, nonatomic) IBOutlet DLForcedGraphView *graphView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *consoleView;

@end


@implementation NearbyPeersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    nearbyPeers_ = [NSMutableDictionary new];
    peerNodes_ = [NSMutableDictionary new];
    nextNodeIndex_ = 0;
    graphScene_ = self.graphView.graphScene;
    graphScene_.delegate = self;
}

-(void)updateDiscoveryInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userSelectedNewColorNotification" object:[self dataFromColor:ownColor_]];
}

#pragma mark - Node handling

-(void)addNodeForPeer:(PPKPeer*)peer {
    
    [nearbyPeers_ setObject:peer forKey:@(nextNodeIndex_)];
    
    DLEdge *edge = DLMakeEdge(0, nextNodeIndex_);
    edge.repulsion = [self getRepulsionForProximityStrength:peer.proximityStrength];
    edge.attraction = [self getAttractionForProximityStrength:peer.proximityStrength];
    edge.unknownConnection = (peer.proximityStrength == PPKProximityStrengthUnknown);
    edge.immediateConnection = (peer.proximityStrength == PPKProximityStrengthImmediate);
    [graphScene_ addEdge:edge];
}

-(CGFloat)getRepulsionForProximityStrength:(PPKProximityStrength)proximityStrength {
    
    CGFloat repulsion;
    switch (proximityStrength) {
        case PPKProximityStrengthExtremelyWeak:
            repulsion = 2500.f;
            break;
        case PPKProximityStrengthWeak:
            repulsion = 2000.f;
            break;
        case PPKProximityStrengthMedium:
            repulsion = 1500.f;
            break;
        case PPKProximityStrengthStrong:
            repulsion = 1100.f;
            break;
        case PPKProximityStrengthImmediate:
            repulsion = 700.f;
            break;
        default:
            repulsion = 1500.f;
            break;
    }
    
    return repulsion;
}

-(CGFloat)getAttractionForProximityStrength:(PPKProximityStrength)proximityStrength {
    
    CGFloat attraction;
    switch (proximityStrength) {
        case PPKProximityStrengthExtremelyWeak:
            attraction = 0.025f;
            break;
        case PPKProximityStrengthWeak:
            attraction = 0.03f;
            break;
        case PPKProximityStrengthMedium:
            attraction = 0.05f;
            break;
        case PPKProximityStrengthStrong:
            attraction = 0.07f;
            break;
        case PPKProximityStrengthImmediate:
            attraction = 0.12f;
            break;
        default:
            attraction = 0.05f;
            break;
    }
    
    return attraction;
}

-(void)updateColorForPeer:(PPKPeer*)peer {
    
    NSNumber *index = [nearbyPeers_ allKeysForObject:peer].firstObject;
    SKShapeNode *node = peerNodes_[index];
    [self setColor:[self colorFromData:peer.discoveryInfo] forNode:node animated:YES];
}

-(void)updateProximityStrengthForPeer:(PPKPeer*)peer {
    
    NSNumber *index = [nearbyPeers_ allKeysForObject:peer].firstObject;
    
    DLEdge *edge = DLMakeEdge(0, index.intValue);
    edge.repulsion = [self getRepulsionForProximityStrength:peer.proximityStrength];
    edge.attraction = [self getAttractionForProximityStrength:peer.proximityStrength];
    edge.unknownConnection = (peer.proximityStrength == PPKProximityStrengthUnknown);
    edge.immediateConnection = (peer.proximityStrength == PPKProximityStrengthImmediate);
    [graphScene_ updateEdge:edge];
    
    [self updateStrokesForAllNodes];
}

-(void)removeNodeForPeer:(PPKPeer*)peer {
    
    NSNumber *index = [nearbyPeers_ allKeysForObject:peer].firstObject;
    [graphScene_ removeEdge:DLMakeEdge(0, index.integerValue)];
    [peerNodes_ removeObjectForKey:index];
    [nearbyPeers_ removeObjectForKey:index];
}

-(void)removeNodesForAllPeers {
    
    [nearbyPeers_ enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, PPKPeer *peer, BOOL *stop) {
        [graphScene_ removeEdge:DLMakeEdge(0, index.integerValue)];
    }];
    
    [peerNodes_ removeAllObjects];
    [nearbyPeers_ removeAllObjects];
}

#pragma mark - DLGraphSceneDelegate

-(void)configureVertex:(SKShapeNode*)vertex atIndex:(NSUInteger)index {
    
    if(index == 0) {
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.3, 1.3);
        [vertex setPath:CGPathCreateMutableCopyByTransformingPath(vertex.path, &transform)];
        
        CGFloat mass = vertex.physicsBody.mass;
        vertex.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:vertex.frame.size.width/2];
        vertex.physicsBody.mass = mass;
        vertex.physicsBody.allowsRotation = NO;
        
        SKLabelNode *label = [SKLabelNode new];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setText:@"me"];
        [vertex addChild:label];
        
        ownNode_ = vertex;
        [self setColor:ownColor_ forNode:ownNode_ animated:NO];
        
    } else {
        
        PPKPeer *peer = [nearbyPeers_ objectForKey:@(index)];
        [peerNodes_ setObject:vertex forKey:@(index)];
        [self setColor:[self colorFromData:peer.discoveryInfo] forNode:vertex animated:NO];
    }
    
    [vertex setLineWidth:2.0];
    nextNodeIndex_++;
    
    [self updateStrokesForAllNodes];
}

-(void)tapOnVertex:(SKNode *)vertex atIndex:(NSUInteger)index {
    if (index == 0) [self presentColorPicker];
}

#pragma mark - Helpers

-(void)setup {
    
    DLEdge *edge = DLMakeEdge(0, 0);
    edge.repulsion = 1100.f;
    edge.attraction = 0.07f;
    [graphScene_ addEdge:edge];
    
#if UPA_CONFIGURATION_TYPE == 0
    [self.infoButton removeFromSuperview];
#else
    [self.infoButton addTarget:self action:@selector(toggleConsoleView) forControlEvents:UIControlEventTouchUpInside];
#endif
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSData *colorData = [userDef objectForKey:@"ownColor"];
    
    if (colorData != nil) {
        [self setOwnColor:[self colorFromData:colorData]];
    }
    else {
        [self presentColorPicker];
    }
}

-(void)presentColorPicker {
    
    ColorPickerViewController *colorPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"colorPickerViewController"];
    
    [colorPickerVC setOnCompleteBlock:^(UIColor *color) {
        
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        [userDef setObject:[self dataFromColor:color] forKey:@"ownColor"];
        [userDef synchronize];
        
        [self setOwnColor:color];
    }];
    
    [self presentViewController:colorPickerVC animated:YES completion:^{
        [colorPickerVC setSelectedColor:ownColor_];
    }];
}

-(void)setOwnColor:(UIColor*)color {
    
    ownColor_ = color;
    if (ownNode_) {
        [self setColor:ownColor_ forNode:ownNode_ animated:NO];
    }
    
    [self.infoButton setHidden:NO];
    [self updateDiscoveryInfo];
}

-(void)setColor:(UIColor*)color forNode:(SKShapeNode*)node animated:(BOOL)animated {
    
    [node setFillColor:color];
    
    if (animated) {
        
        SKAction *moveNode = [SKAction moveBy:CGVectorMake((ownNode_.position.x-node.position.x) * 0.33, (ownNode_.position.y-node.position.y) * 0.33) duration:0.25];
        SKAction *changeColor = [SKAction customActionWithDuration:0.25 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            node.yScale = (elapsedTime/0.25 * 1.0);
            node.xScale = (elapsedTime/0.25 * 1.0);
        }];
        
        [node runAction:[SKAction group:@[moveNode, changeColor]]];
    }
}

-(void)updateStrokesForAllNodes {
    
    UIColor *highlightColor = [UIColor whiteColor];
    
    __block BOOL hasImmediatePeers = NO;
    [nearbyPeers_ enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, PPKPeer *peer, BOOL * _Nonnull stop) {
        
        SKShapeNode *node = peerNodes_[index];
        if (peer.proximityStrength == PPKProximityStrengthImmediate) {
            [node setStrokeColor:highlightColor];
            hasImmediatePeers = YES;
        }
        else {
            [node setStrokeColor:node.fillColor];
        }
    }];
    
    [ownNode_ setStrokeColor:(hasImmediatePeers ? highlightColor : ownNode_.fillColor)];
}

-(void)toggleConsoleView {
    
    CGRect frame = CGRectMake(0, (self.consoleView.hidden ? 0 : self.view.frame.size.height), self.view.frame.size.width, self.view.frame.size.height);
    
    if (self.consoleView.hidden) {
        [self.consoleView setHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            self.consoleView.frame = frame;
        }];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            [self.consoleView setFrame:frame];
        } completion:^(BOOL finished) {
            [self.consoleView setHidden:YES];
        }];
    }
    
}

-(UIColor*)colorFromData:(NSData*)data {
    
    u_int8_t colorArrayRGB[3];
    [data getBytes:&colorArrayRGB length:3];
    return [UIColor colorWithRed:(colorArrayRGB[0]/255.0) green:(colorArrayRGB[1]/255.0) blue:(colorArrayRGB[2]/255.0) alpha:1.0];
}

-(NSData*)dataFromColor:(UIColor*)color {
    
    const CGFloat *colors = CGColorGetComponents(color.CGColor);
    u_int8_t colorArrayRGB[3];

    colorArrayRGB[0] = colors[0] * 255.0;
    colorArrayRGB[1] = colors[1] * 255.0;
    colorArrayRGB[2] = colors[2] * 255.0;

    NSMutableData *data = [NSMutableData dataWithCapacity:3];
    [data appendBytes:&colorArrayRGB length:3];
    
    return data;
}

@end
