#import <UIKit/UIKit.h>

@class DLEdge;


DLEdge* DLMakeEdge(NSUInteger i, NSUInteger j);


@interface DLEdge : NSObject <NSCopying>

@property (nonatomic, assign, readonly) NSUInteger i;
@property (nonatomic, assign, readonly) NSUInteger j;

+ (instancetype)edgeWithI:(NSUInteger)i J:(NSUInteger)j;

@end