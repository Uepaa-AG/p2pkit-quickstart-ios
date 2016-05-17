#import "DLGraphScene.h"
#import "DLEdge.h"

#define REPULSION_DEFAULT_VALUE   100.f
#define ATTRACTION_DEFAULT_VALUE  0.01f

@interface DLGraphScene () {
    BOOL contentCreated_;
    
    NSMutableSet *touchedAndMovedNodes_;
    
    NSMutableArray *edges_;
    NSMutableDictionary *vertexes_;
    NSMutableDictionary *connections_;
    
    NSMutableDictionary *repulsionsPerNode_;
    NSMutableDictionary *attractionsPerNode_;
}

@end


@implementation DLGraphScene

@synthesize delegate;

#pragma mark - SKScene

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        connections_ = [NSMutableDictionary dictionary];
        vertexes_ = [NSMutableDictionary dictionary];
        
        repulsionsPerNode_ = [NSMutableDictionary dictionary];
        attractionsPerNode_ = [NSMutableDictionary dictionary];
        
        edges_ = [NSMutableArray new];
        touchedAndMovedNodes_ = [NSMutableSet new];
        
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
    
    [vertexes_ enumerateKeysAndObjectsUsingBlock:^(NSNumber *index1, SKShapeNode *v, BOOL *stop) {
        
        if ([touchedAndMovedNodes_ containsObject:v]) return;
        
        NSUInteger i = index1.integerValue;
        
        __block CGFloat vForceX = 0;
        __block CGFloat vForceY = 0;
        
        [vertexes_ enumerateKeysAndObjectsUsingBlock:^(NSNumber *index2, SKShapeNode *u, BOOL *stop) {
            
            NSUInteger j = index2.integerValue;
            if (i == j) return;
            
            CGFloat repulsion = REPULSION_DEFAULT_VALUE;
            if (i == 0) {
                repulsion = [[repulsionsPerNode_ objectForKey:index2] floatValue];
            }
            else if (j == 0) {
                repulsion = [[repulsionsPerNode_ objectForKey:index1] floatValue];
            }
            
            double rsq = pow((v.position.x - u.position.x), 2) + pow((v.position.y - u.position.y), 2);
            vForceX += repulsion * (v.position.x - u.position.x) / rsq;
            vForceY += repulsion * (v.position.y - u.position.y) / rsq;
        }];
        
        [vertexes_ enumerateKeysAndObjectsUsingBlock:^(NSNumber *index2, SKShapeNode *u, BOOL *stop) {
            
            NSUInteger j = index2.integerValue;
            if (i == j) return;
            if(![self hasConnectedA:i toB:j]) return;
            
            CGFloat attraction = ATTRACTION_DEFAULT_VALUE;
            if (i == 0) {
                attraction = [[attractionsPerNode_ objectForKey:index2] floatValue];
            }
            else if (j == 0) {
                attraction = [[attractionsPerNode_ objectForKey:index1] floatValue];
            }
            
            vForceX += attraction * (u.position.x - v.position.x);
            vForceY += attraction * (u.position.y - v.position.y);
        }];
        
        v.physicsBody.friction = 0.8;
        v.physicsBody.restitution = 0.3;
        v.physicsBody.linearDamping = 0.95;
        v.physicsBody.velocity = CGVectorMake((v.physicsBody.velocity.dx + vForceX),
                                              (v.physicsBody.velocity.dy + vForceY));
        
        [v.physicsBody applyForce:CGVectorMake(vForceX, vForceY)];
        v.physicsBody.angularVelocity = 0;
        
    }];
    
    [self updateConnections];
}

- (void)updateConnections {
    
    [connections_ enumerateKeysAndObjectsUsingBlock:^(DLEdge *edge, SKShapeNode *connection, BOOL *stop) {
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        
        SKNode *vertexA = vertexes_[@(edge.i)];
        SKNode *vertexB = vertexes_[@(edge.j)];
        
        CGPathMoveToPoint(pathToDraw, NULL, vertexA.position.x, vertexA.position.y);
        CGPathAddLineToPoint(pathToDraw, NULL, vertexB.position.x, vertexB.position.y);
        
        if (edge.unknownConnection) {
            
            CGFloat pattern[] = {2.0, 2.0};
            
            CGPathRef dashed = CGPathCreateCopyByDashingPath(pathToDraw, NULL, 0, pattern, 2);
            connection.path = dashed;
            
            CGPathRelease(dashed);
            
        } else {
            connection.path = pathToDraw;
        }
        
        CGPathRelease(pathToDraw);
    }];
}

#pragma mark - Public

- (void)addEdge:(DLEdge *)edge {
    
    [edges_ addObject:edge];
    [self createVertexesForEdge:edge];
    if (edge.i != edge.j) [self createConnectionForEdge:edge];
}

- (void)updateEdge:(DLEdge *)edge {
    
    NSUInteger index = [edges_ indexOfObject:edge];
    [edges_ replaceObjectAtIndex:index withObject:edge];
    
    [connections_ enumerateKeysAndObjectsUsingBlock:^(DLEdge *key, SKShapeNode *connection, BOOL *stop) {
        if ([key isEqual:edge]) {
            [connections_ removeObjectForKey:key];
            [connections_ setObject:connection forKey:edge];
            *stop = YES;
        }
    }];
    
    [repulsionsPerNode_ setObject:@(edge.repulsion) forKey:@(edge.i)];
    [attractionsPerNode_ setObject:@(edge.attraction) forKey:@(edge.i)];
    
    [repulsionsPerNode_ setObject:@(edge.repulsion) forKey:@(edge.j)];
    [attractionsPerNode_ setObject:@(edge.attraction) forKey:@(edge.j)];
    
    SKShapeNode *connection = connections_[edge];
    connection.strokeColor = (edge.immediateConnection ? [SKColor whiteColor] : [SKColor darkGrayColor]);
}

- (void)removeEdge:(DLEdge *)edge {
    
    [edges_ removeObject:edge];

    SKShapeNode *connection = connections_[edge];
    if (connection) {
        [connection removeFromParent];
        [connections_ removeObjectForKey:edge];
    }
    
    SKShapeNode *vertex = vertexes_[@(edge.j)];
    if (vertex) {
        [NSObject cancelPreviousPerformRequestsWithTarget:vertex];
        [vertex removeFromParent];
        [vertexes_ removeObjectForKey:@(edge.j)];
        [repulsionsPerNode_ removeObjectForKey:@(edge.j)];
        [attractionsPerNode_ removeObjectForKey:@(edge.j)];
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
    vertexes_[@(index)] = circle;
}

- (void)createConnectionForEdge:(DLEdge *)edge {
    
    SKShapeNode *connection = [SKShapeNode node];
    connection.strokeColor = (edge.immediateConnection ? [SKColor whiteColor] : [SKColor darkGrayColor]);
    connection.fillColor = [SKColor darkGrayColor];
    connection.lineWidth = 3.f;
    connection.alpha = 0.0;
    
    SKAction *zoom = [SKAction fadeInWithDuration:0.25];
    [connection runAction:zoom];

    [self addChild:connection];
    connections_[edge] = connection;
}

- (void)createVertexesForEdge:(DLEdge *)edge {
    
    if (vertexes_[@(edge.i)] == nil) {
        [self createVertexWithIndex:edge.i];
        [repulsionsPerNode_ setObject:@(edge.repulsion) forKey:@(edge.i)];
        [attractionsPerNode_ setObject:@(edge.attraction) forKey:@(edge.i)];
    }
    
    if (vertexes_[@(edge.j)] == nil) {
        [self createVertexWithIndex:edge.j];
        [repulsionsPerNode_ setObject:@(edge.repulsion) forKey:@(edge.j)];
        [attractionsPerNode_ setObject:@(edge.attraction) forKey:@(edge.j)];
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
    node.name = @"node";
    node.alpha = 0.0;
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    node.physicsBody.allowsRotation = NO;
    
    SKAction *zoom = [SKAction fadeInWithDuration:0.25];
    [node runAction:zoom];
    
    CGPathRelease(circlePath);
    
    return node;
}


#if TARGET_OS_IOS

#pragma mark - Touch handling

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        
        CGPoint positionInScene = [touch locationInNode:self];
        CGPoint previousPosition = [touch previousLocationInNode:self];
        
        SKNode *node = [self nodeAtPoint:previousPosition];
        if (node) {
            [node setPosition:positionInScene];
            [node.physicsBody setDynamic:NO];
            
            if ([self positionMoved:positionInScene toPrevious:previousPosition]) {
                [touchedAndMovedNodes_ addObject:node];
            }
            
        }
    }];
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
            [node.physicsBody setDynamic:YES];
            
            if ([touchedAndMovedNodes_ containsObject:node]) {
                [node setPosition:positionInScene];
                [touchedAndMovedNodes_ removeObject:node];
            }
            else {
                NSUInteger index = [[vertexes_ allKeysForObject:node].firstObject integerValue];
                [self notifyDelegateTapOnVertex:node atIndex:index];
            }
        }
    }];
}

- (BOOL)positionMoved:(CGPoint)position toPrevious:(CGPoint)previous {
    if (fabs(position.x - previous.x) > 1.0 || fabs(position.y - previous.y) > 1.0) {
        return YES;
    }
    return NO;
}

#else

-(void)mouseDragged:(NSEvent *)theEvent {
    
    CGPoint positionInScene = [theEvent locationInNode:self];
    
    if (touchedAndMovedNodes_.count > 0) {
        SKNode *node = [touchedAndMovedNodes_ anyObject];
        [node setPosition:[self getPositionInScene:positionInScene forNode:node]];
    }
    else {
        SKNode *node = [self nodeAtPoint:positionInScene];
        if (node) {
            [node.physicsBody setDynamic:NO];
            [touchedAndMovedNodes_ addObject:node];
        }
    }
}

-(void)mouseUp:(NSEvent *)theEvent {
    if (touchedAndMovedNodes_.count > 0) {
        SKNode *node = [touchedAndMovedNodes_ anyObject];
        [node.physicsBody setDynamic:YES];
        [touchedAndMovedNodes_ removeAllObjects];
    }
    else {
        CGPoint positionInScene = [theEvent locationInNode:self];
        SKNode *node = [self nodeAtPoint:positionInScene];
        if (node) {
            NSUInteger index = [[vertexes_ allKeysForObject:node].firstObject integerValue];
            [self notifyDelegateTapOnVertex:node atIndex:index];
        }
    }
}

-(CGPoint)getPositionInScene:(CGPoint)position forNode:(SKNode*)node {
    
    if (position.x < 0.0 || position.x > self.size.width) {
        position.x = node.position.x;
    }
    
    if (position.y < 0.0 || position.y > self.size.height) {
        position.y = node.position.y;
    }
    
    return position;
}

#endif

- (SKNode*)nodeAtPoint:(CGPoint)point {
    
    NSArray *nodes = [self nodesAtPoint:point];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SKNode *_node, id _) {
        return [_node.name isEqualToString:@"node"];
    }];
    
    return [nodes filteredArrayUsingPredicate:predicate].firstObject;
}

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
