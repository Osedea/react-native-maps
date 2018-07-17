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
