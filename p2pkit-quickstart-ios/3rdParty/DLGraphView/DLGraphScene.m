#import "DLGraphScene.h"
#import "DLEdge.h"


@interface DLGraphScene () {
    NSMutableSet *touchedNodes_;
    NSMutableArray *edges_;
    
    BOOL touchDidMove_;
    BOOL contentCreated_;
}

@property (atomic, strong) NSMutableDictionary *vertexes;
@property (atomic, strong) NSMutableDictionary *connections;

@end


@implementation DLGraphScene

@synthesize delegate;

#pragma mark - SKScene

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        _connections = [NSMutableDictionary dictionary];
        _vertexes = [NSMutableDictionary dictionary];

        _repulsion = 900.f;
        _attraction = 0.1f;
        
        edges_ = [NSMutableArray new];
        touchedNodes_ = [NSMutableSet new];
        
        touchDidMove_ = NO;
        contentCreated_ = NO;
    }

    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    if (!contentCreated_) {
        [self createSceneContents];
        contentCreated_ = YES;
    }
}

- (void)didChangeSize:(CGSize)oldSize {
    
    [super didChangeSize:oldSize];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

    for (SKNode *node in self.children) {
        CGPoint newPosition;
        newPosition.x = MIN(node.position.x, self.frame.size.width);
        newPosition.y = MIN(node.position.y, self.frame.size.height);
        node.position = newPosition;
    }
}

- (void)update:(NSTimeInterval)currentTime {
    
    [self.vertexes enumerateKeysAndObjectsUsingBlock:^(NSNumber *index1, SKShapeNode *v, BOOL *stop) {
        
        if ([touchedNodes_ containsObject:v]) return;
        
        NSUInteger i = index1.integerValue;
        
        __block CGFloat vForceX = 0;
        __block CGFloat vForceY = 0;
        
        [self.vertexes enumerateKeysAndObjectsUsingBlock:^(NSNumber *index2, SKShapeNode *u, BOOL *stop) {
            
            NSUInteger j = index2.integerValue;
            if (i == j) return;
            
            double rsq = pow((v.position.x - u.position.x), 2) + pow((v.position.y - u.position.y), 2);
            vForceX += self.repulsion * (v.position.x - u.position.x) / rsq;
            vForceY += self.repulsion * (v.position.y - u.position.y) / rsq;
        }];
        
        [self.vertexes enumerateKeysAndObjectsUsingBlock:^(NSNumber *index2, SKShapeNode *u, BOOL *stop) {
            
            NSUInteger j = index2.integerValue;
            if(![self hasConnectedA:i toB:j]) return;
            
            vForceX += self.attraction * (u.position.x - v.position.x);
            vForceY += self.attraction * (u.position.y - v.position.y);
        }];
        
        v.physicsBody.linearDamping = 0.95;
        v.physicsBody.velocity = CGVectorMake((v.physicsBody.velocity.dx + vForceX),
                                              (v.physicsBody.velocity.dy + vForceY));
        
        [v.physicsBody applyForce:CGVectorMake(vForceX, vForceY)];
        v.physicsBody.angularVelocity = 0;
        
    }];
    
    [self updateConnections];
}

- (void)updateConnections {
    
    [self.connections enumerateKeysAndObjectsUsingBlock:^(DLEdge *key, SKShapeNode *connection, BOOL *stop) {
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        
        SKNode *vertexA = self.vertexes[@(key.i)];
        SKNode *vertexB = self.vertexes[@(key.j)];
        
        CGPathMoveToPoint(pathToDraw, NULL, vertexA.position.x, vertexA.position.y);
        CGPathAddLineToPoint(pathToDraw, NULL, vertexB.position.x, vertexB.position.y);
        connection.path = pathToDraw;
        
        CGPathRelease(pathToDraw);
    }];
}

#pragma mark - Public

- (void)addEdge:(DLEdge *)edge {
    
    [edges_ addObject:edge];
    [self createVertexesForEdge:edge];
    if (edge.i != edge.j) [self createConnectionForEdge:edge];
}

- (void)addEdges:(NSArray *)edges {
    
    for (DLEdge *edge in edges) {
        [self addEdge:edge];
    }
}

- (void)removeEdge:(DLEdge *)edge {
    
    [edges_ removeObject:edge];

    SKShapeNode *connection = self.connections[edge];
    if (connection) {
        [connection removeFromParent];
        [self.connections removeObjectForKey:edge];
    }
    
    SKShapeNode *vertex = self.vertexes[@(edge.j)];
    if (vertex) {
        [NSObject cancelPreviousPerformRequestsWithTarget:vertex];
        [vertex removeFromParent];
        [self.vertexes removeObjectForKey:@(edge.j)];
    }
}

- (void)removeEdges:(NSArray *)edges {
    
    for (DLEdge *edge in edges) {
        [self removeEdge:edge];
    }
}

#pragma mark - Private

- (void)createVertexWithIndex:(NSUInteger)index {
    
    SKShapeNode *circle = [self createVertexNode];
    [self notifyDelegateConfigureVertex:circle atIndex:index];

    NSInteger maxWidth = (NSInteger)(self.size.width ?: 1);
    NSInteger maxHeight = (NSInteger)(self.size.height ?: 1);

    CGPoint center = CGPointMake(arc4random() % maxWidth, arc4random() % maxHeight);
    circle.position = center;

    [self addChild:circle];
    self.vertexes[@(index)] = circle;
}

- (void)createConnectionForEdge:(DLEdge *)edge {
    
    SKShapeNode *connection = [SKShapeNode node];
    connection.strokeColor = [SKColor darkGrayColor];
    connection.fillColor = [SKColor darkGrayColor];
    connection.lineWidth = 3.f;
    connection.alpha = 0.0;
    
    SKAction *zoom = [SKAction fadeInWithDuration:0.25];
    [connection runAction:zoom];

    [self addChild:connection];
    self.connections[edge] = connection;
}

- (void)createVertexesForEdge:(DLEdge *)edge {
    
    [self createVertexIfNeeded:edge.i];
    [self createVertexIfNeeded:edge.j];
}

- (void)createVertexIfNeeded:(NSUInteger)index {
    
    if (self.vertexes[@(index)] == nil) {
        [self createVertexWithIndex:index];
    }
}

- (void)createSceneContents {
    
    self.backgroundColor = [SKColor blackColor];
    self.physicsWorld.gravity = CGVectorMake(0,0);
}

- (BOOL)hasConnectedA:(NSUInteger)a toB:(NSUInteger)b {
    return [edges_ containsObject:DLMakeEdge(a, b)];
}

- (SKShapeNode *)createVertexNode {
    
    CGFloat radius = 30.0;
    
    CGPathRef circlePath = CGPathCreateWithEllipseInRect(CGRectMake(-radius, -radius, radius*2, radius*2), nil);
    
    SKShapeNode *node = [[SKShapeNode alloc] init];
    node.path = circlePath;
    node.zPosition = 10;
    node.accessibilityLabel = @"node";
    node.alpha = 0.0;
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    node.physicsBody.allowsRotation = NO;
    
    SKAction *zoom = [SKAction fadeInWithDuration:0.25];
    [node runAction:zoom];
    
    CGPathRelease(circlePath);
    
    return node;
}


#if TARGET_OS_IPHONE

#pragma mark - Touch handling

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        
        CGPoint positionInScene = [touch locationInNode:self];
        CGPoint previousPosition = [touch previousLocationInNode:self];
        
        if (![self positionMoved:positionInScene toPrevious:previousPosition]) {
            return;
        }
        
        SKNode *node = [self nodeAtPoint:previousPosition];
        if (node) {
            node.position = positionInScene;
            node.physicsBody.dynamic = NO;
            [touchedNodes_ addObject:node];
        }
    }];
    
    touchDidMove_ = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endTouches:touches];
}

- (void)endTouches:(NSSet*)touches {
    
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        
        CGPoint positionInScene = [touch locationInNode:self];
        CGPoint previousPosition = [touch previousLocationInNode:self];
        SKNode *node = [self nodeAtPoint:previousPosition];
        if (node) {
            if (!touchDidMove_) {
                NSUInteger index = [[self.vertexes allKeysForObject:node].firstObject integerValue];
                [self notifyDelegateTapOnVertex:node atIndex:index];
            }
            
            node.position = positionInScene;
            node.physicsBody.dynamic = YES;
            [touchedNodes_ removeObject:node];
        }
    }];
    
    if (touchedNodes_.count == 0) {
        touchDidMove_ = NO;
    }
}

- (SKNode*)nodeAtPoint:(CGPoint)point {
    
    NSArray *nodes = [self nodesAtPoint:point];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SKNode *_node, id _) {
        return [_node.accessibilityLabel isEqualToString:@"node"];
    }];
    
    return [nodes filteredArrayUsingPredicate:predicate].firstObject;
}

- (BOOL)positionMoved:(CGPoint)position toPrevious:(CGPoint)previous {
    if (fabs(position.x - previous.x) > 1.0 || fabs(position.y - previous.y) > 1.0) {
        return YES;
    }
    return NO;
}

#endif

#pragma mark - Delegate methods

-(void)notifyDelegateConfigureVertex:(SKShapeNode*)node atIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(configureVertex:atIndex:)]) {
        [self.delegate configureVertex:node atIndex:index];
    }
}

-(void)notifyDelegateTapOnVertex:(SKNode*)node atIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapOnVertex:atIndex:)]) {
        [self.delegate tapOnVertex:node atIndex:index];
    }
}

@end
