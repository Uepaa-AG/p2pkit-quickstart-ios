#import <SpriteKit/SpriteKit.h>


@class DLEdge;


@protocol DLGraphSceneDelegate <NSObject>

-(void)configureVertex:(SKShapeNode *)vertex atIndex:(NSUInteger)index;
-(void)tapOnVertex:(SKNode*)vertex atIndex:(NSUInteger)index;

@end


@interface DLGraphScene : SKScene

@property (nonatomic, weak) id<DLGraphSceneDelegate> delegate;

- (void)addEdge:(DLEdge *)edge;
- (void)updateEdge:(DLEdge *)edge;
- (void)removeEdge:(DLEdge *)edge;

@end