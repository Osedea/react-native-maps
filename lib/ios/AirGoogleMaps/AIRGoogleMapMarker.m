//
//  AIRGoogleMapMarker.m
//  AirMaps
//
//  Created by Gil Birman on 9/2/16.
//

#import "AIRGoogleMapMarker.h"
#import <GoogleMaps/GoogleMaps.h>
#import <React/RCTImageLoader.h>
#import <React/RCTUtils.h>
#import "AIRGMSMarker.h"
#import "AIRGoogleMapCallout.h"
#import "AIRDummyView.h"
#import "AIRMarkerImageCache.h"

CGRect unionRect(CGRect a, CGRect b) {
    return CGRectMake(
                      MIN(a.origin.x, b.origin.x),
                      MIN(a.origin.y, b.origin.y),
                      MAX(a.size.width, b.size.width),
                      MAX(a.size.height, b.size.height));
}

@interface AIRGoogleMapMarker ()
- (id)eventFromMarker:(AIRGMSMarker*)marker;
@end

@implementation AIRGoogleMapMarker {
    RCTImageLoaderCancellationBlock _reloadImageCancellationBlock;
    __weak UIImageView *_iconImageView;
    UIView *_iconView;
    AIRMarkerImageCache *_imageCache;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _realMarker = [[AIRGMSMarker alloc] init];
        _realMarker.fakeMarker = self;
        _realMarker.tracksViewChanges = true;
        _realMarker.tracksInfoWindowChanges = false;
        _imageCache = [AIRMarkerImageCache sharedInstance];
    }
    return self;
}

- (void)layoutSubviews {
    float width = 0;
    float height = 0;
    
    for (UIView *v in [_iconView subviews]) {
        
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        
        width = MAX(fw, width);
        height = MAX(fh, height);
    }
    
    [_iconView setFrame:CGRectMake(0, 0, width, height)];
}

- (id)eventFromMarker:(AIRGMSMarker*)marker {
    
    CLLocationCoordinate2D coordinate = marker.position;
    CGPoint position = [self.realMarker.map.projection pointForCoordinate:coordinate];
    
    return @{
             @"id": marker.identifier ?: @"unknown",
             @"position": @{
                     @"x": @(position.x),
                     @"y": @(position.y),
                     },
             @"coordinate": @{
                     @"latitude": @(coordinate.latitude),
                     @"longitude": @(coordinate.longitude),
                     }
             };
}

- (void)iconViewInsertSubview:(UIView*)subview atIndex:(NSInteger)atIndex {
    if (!_realMarker.iconView) {
        _iconView = [[UIView alloc] init];
        _realMarker.iconView = _iconView;
    }

    [_iconView insertSubview:subview atIndex:atIndex];
}

- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex {
    if ([subview isKindOfClass:[AIRGoogleMapCallout class]]) {
        self.calloutView = (AIRGoogleMapCallout *)subview;
    } else { // a child view of the marker
        NSLog(@"we made it boiz");
        [self iconViewInsertSubview:(UIView*)subview atIndex:atIndex+1];
    }
    AIRDummyView *dummySubview = [[AIRDummyView alloc] initWithView:(UIView *)subview];
    [super insertReactSubview:(UIView*)dummySubview atIndex:atIndex];
}

- (void)removeReactSubview:(id<RCTComponent>)dummySubview {
    UIView* subview = ((AIRDummyView*)dummySubview).view;
    
    if ([subview isKindOfClass:[AIRGoogleMapCallout class]]) {
        self.calloutView = nil;
    } else {
        [(UIView*)subview removeFromSuperview];
    }
    [super removeReactSubview:(UIView*)dummySubview];
}

- (void)showCalloutView {
    [_realMarker.map setSelectedMarker:_realMarker];
}

- (void)hideCalloutView {
    [_realMarker.map setSelectedMarker:Nil];
}

- (UIView *)markerInfoContents {
    if (self.calloutView && !self.calloutView.tooltip) {
        return self.calloutView;
    }
    return nil;
}

- (UIView *)markerInfoWindow {
    if (self.calloutView && self.calloutView.tooltip) {
        return self.calloutView;
    }
    return nil;
}

- (void)didTapInfoWindowOfMarker:(AIRGMSMarker *)marker {
    if (self.calloutView && self.calloutView.onPress) {
        id event = @{@"action": @"marker-overlay-press",
                     @"id": self.identifier ?: @"unknown",
                     };
        self.calloutView.onPress(event);
    }
}

- (void)didBeginDraggingMarker:(AIRGMSMarker *)marker {
    if (!self.onDragStart) return;
    self.onDragStart([self eventFromMarker:marker]);
}

- (void)didEndDraggingMarker:(AIRGMSMarker *)marker {
    if (!self.onDragEnd) return;
    self.onDragEnd([self eventFromMarker:marker]);
}

- (void)didDragMarker:(AIRGMSMarker *)marker {
    if (!self.onDrag) return;
    self.onDrag([self eventFromMarker:marker]);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    _realMarker.position = coordinate;
}

- (CLLocationCoordinate2D)coordinate {
    return _realMarker.position;
}

- (void)setRotation:(CLLocationDegrees)rotation {
    _realMarker.rotation = rotation;
}

- (CLLocationDegrees)rotation {
    return _realMarker.rotation;
}

- (void)setIdentifier:(NSString *)identifier {
    _realMarker.identifier = identifier;
}

- (NSString *)identifier {
    return _realMarker.identifier;
}

- (void)setOnPress:(RCTBubblingEventBlock)onPress {
    _realMarker.onPress = onPress;
}

- (RCTBubblingEventBlock)onPress {
    return _realMarker.onPress;
}

- (void)setOpacity:(double)opacity
{
    _realMarker.opacity = opacity;
}

- (void)setMarkerSize:(NSDictionary *)markerSize
{
    float width = [markerSize[@"width"] floatValue];
    float height = [markerSize[@"height"] floatValue];
    if ([_realMarker iconView] != nil) {
        UIImageView *imageView = [[AIRMarkerImageCache sharedInstance] getSharedUIImage:[self imageSrc] withSize:CGSizeMake(width, height)];
        [self setIcon:imageView];
    }
    _realMarker.markerSize = markerSize;
}

- (void)setIcon:(UIImageView *)imageView
{
    CGImageRef cgref = [imageView.image CGImage];
    CIImage *cim = [imageView.image CIImage];
    
    if (cim == nil && cgref == NULL) {
        _realMarker.iconView = nil;
        _realMarker.icon = nil;
    } else {
        _realMarker.iconView = imageView;
    }
}

- (void)setImageSrc:(NSString *)imageSrc
{
    float width = [_realMarker.markerSize[@"width"] floatValue] != 0 ? [_realMarker.markerSize[@"width"] floatValue] : 25;
    float height = [_realMarker.markerSize[@"height"] floatValue] != 0 ? [_realMarker.markerSize[@"height"] floatValue]: 68;
    
    UIImageView *imageView = [[AIRMarkerImageCache sharedInstance] getSharedUIImage:imageSrc withSize:CGSizeMake(width, height)];
    _imageSrc = imageSrc;
    [self setIcon:imageView];
}

- (void)setTitle:(NSString *)title {
    _realMarker.title = [title copy];
}

- (NSString *)title {
    return _realMarker.title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _realMarker.snippet = subtitle;
}

- (NSString *)subtitle {
    return _realMarker.snippet;
}

- (void)setPinColor:(UIColor *)pinColor {
    _pinColor = pinColor;
    _realMarker.icon = [GMSMarker markerImageWithColor:pinColor];
}

- (void)setAnchor:(CGPoint)anchor {
    _anchor = anchor;
    _realMarker.groundAnchor = anchor;
}


- (void)setZIndex:(NSInteger)zIndex
{
    _zIndex = zIndex;
    _realMarker.zIndex = (int)zIndex;
}

- (void)setDraggable:(BOOL)draggable {
    _realMarker.draggable = draggable;
}

- (BOOL)draggable {
    return _realMarker.draggable;
}

- (void)setTracksViewChanges:(BOOL)tracksViewChanges {
    _realMarker.tracksViewChanges = tracksViewChanges;
}

- (BOOL)tracksViewChanges {
    return _realMarker.tracksViewChanges;
}

- (void)setTracksInfoWindowChanges:(BOOL)tracksInfoWindowChanges {
    _realMarker.tracksInfoWindowChanges = tracksInfoWindowChanges;
}

- (BOOL)tracksInfoWindowChanges {
    return _realMarker.tracksInfoWindowChanges;
}

@end
