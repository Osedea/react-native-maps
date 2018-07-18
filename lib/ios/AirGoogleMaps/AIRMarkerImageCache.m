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
- (UIImageView *)getSharedUIImage:(NSString *)imageSrc withSize:(CGSize) size{
    UIImageView* cachedImage = self.cache[imageSrc];
    
    CGImageRef cgref = [cachedImage.image CGImage];
    CIImage *cim = [cachedImage.image CIImage];
    if (cim == nil && cgref == NULL) {
        UIImageView *imageView;
        if ([imageSrc hasPrefix:@"http://"] || [imageSrc hasPrefix:@"https://"]) {
            NSURL *url = [NSURL URLWithString:imageSrc];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            UIImage *image = [UIImage imageWithData:data];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageSrc]];
        }
        self.cache[imageSrc] = imageView;
        return imageView;
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
