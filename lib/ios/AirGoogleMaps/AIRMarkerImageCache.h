//
//  AIRMarkerImageCache.h
//  FLAnimatedImage
//

#import <Foundation/Foundation.h>

@interface AIRMarkerImageCache : NSObject
@property (strong, nonatomic) NSMutableDictionary *cache;
+ (instancetype) sharedInstance;
- (UIImage *) getSharedUIImage:(NSString *)imageSrc withScale:(float)scale;
@end
