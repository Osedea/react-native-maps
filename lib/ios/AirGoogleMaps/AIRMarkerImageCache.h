//
//  AIRMarkerImageCache.h
//  FLAnimatedImage
//
//  Created by Evan Glicakis on 2018-07-17.
//

#import <Foundation/Foundation.h>

@interface AIRMarkerImageCache : NSObject
@property (strong, nonatomic) NSMutableDictionary *cache;
+ (instancetype) sharedInstance;
- (UIImage *) getSharedUIImage:(NSString *)imageSrc withSize:(CGSize)size;
@end
