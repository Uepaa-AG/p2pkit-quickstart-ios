#import "DLEdge.h"


DLEdge* DLMakeEdge(NSUInteger i, NSUInteger j)
{
    return [DLEdge edgeWithI:i J:j];
}

@implementation DLEdge

+ (instancetype)edgeWithI:(NSUInteger)i J:(NSUInteger)j
{
    return [[self alloc] initWithI:i J:j];
}

- (instancetype)initWithI:(NSUInteger)i J:(NSUInteger)j
{
    if (self = [super init]) {
        _i = i;
        _j = j;
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToEdge:other];
}

- (BOOL)isEqualToEdge:(DLEdge *)edge
{
    if (self == edge)
        return YES;
    if (edge == nil)
        return NO;
    if (self.i == edge.i && self.j == edge.j)
        return YES;
    if (self.i == edge.j && self.j == edge.i)
        return YES;

    return NO;
}

- (NSUInteger)hash
{
    NSUInteger hash = self.i;
    hash = hash * 31u + self.j;
    return hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    DLEdge *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy->_i = _i;
        copy->_j = _j;
    }

    return copy;
}

@end