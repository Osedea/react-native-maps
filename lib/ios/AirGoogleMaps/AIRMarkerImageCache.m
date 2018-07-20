//
//  AIRMarkerImageCache.m
//  FLAnimatedImage
//
//  Created by Evan Glicakis on 2018-07-17.
//

#import "AIRMarkerImageCache.h"

@implementation AIRMarkerImageCache

/**
 * Use this method to interact with this singleton class.
 */
+ (instancetype)sharedInstance {
    static AIRMarkerImageCache *instance = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[AIRMarkerImageCache alloc] init];
        }
    });
    
    return instance;
}

 /**
  * get shared UIImage
  */
- (UIImage *)getSharedUIImage:(NSString *)imageSrc withSize:(CGSize) size{
    UIImage* cachedImage = self.cache[imageSrc];
    
    CGImageRef cgref = [cachedImage CGImage];
    CIImage *cim = [cachedImage CIImage];
    if (cim == nil && cgref == NULL) {
        UIImage *image;
        if ([imageSrc hasPrefix:@"http://"] || [imageSrc hasPrefix:@"https://"]) {
            NSURL *url = [NSURL URLWithString:imageSrc];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            image = [UIImage imageWithData:data scale:8];
//            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//            imageView.image = image;
//            imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            image = [UIImage imageWithContentsOfFile:imageSrc];
        }
        self.cache[imageSrc] = image;
        return image;
    } else {
        return cachedImage;
    }
}

/**
 * Do not use this. Use +(instancetype)sharedInstance to get the singleton.
 */
- (instancetype)init {
    if (self = [super init]) {
        // init your state
        self.cache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    self.cache = nil;
}

@end
