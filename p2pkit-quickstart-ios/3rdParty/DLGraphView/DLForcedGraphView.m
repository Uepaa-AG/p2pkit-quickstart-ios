#import "DLForcedGraphView.h"

@interface DLForcedGraphView ()

@property (nonatomic, strong, readwrite) DLGraphScene *graphScene;

@end

@implementation DLForcedGraphView

#if TARGET_OS_IPHONE
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.scene.scaleMode = SKSceneScaleModeResizeFill;
    [self presentScene:self.scene];
}
#else
- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    self.scene.scaleMode = SKSceneScaleModeResizeFill;
    [self presentScene:self.scene];
}
#endif

- (DLGraphScene *)graphScene
{
    if (!_graphScene) {
        _graphScene = [[DLGraphScene alloc] initWithSize:self.bounds.size];
    }
    return _graphScene;
}

- (SKScene *)scene
{
    return [self graphScene];
}

@end