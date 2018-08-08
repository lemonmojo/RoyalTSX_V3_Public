//
//  iTermIndicatorsHelper.m
//  iTerm2
//
//  Created by George Nachman on 11/23/14.
//
//

#import "iTermIndicatorsHelper.h"
#import "DebugLogging.h"

static NSDictionary *gIndicatorImages;

NSString *const kiTermIndicatorBell = @"kiTermIndicatorBell";
NSString *const kiTermIndicatorWrapToTop = @"kiTermIndicatorWrapToTop";
NSString *const kiTermIndicatorWrapToBottom = @"kiTermIndicatorWrapToBottom";
NSString *const kItermIndicatorBroadcastInput = @"kItermIndicatorBroadcastInput";
NSString *const kiTermIndicatorMaximized = @"kiTermIndicatorMaximized";
NSString *const kiTermIndicatorCoprocess = @"kiTermIndicatorCoprocess";
NSString *const kiTermIndicatorAlert = @"kiTermIndicatorAlert";
NSString *const kiTermIndicatorAllOutputSuppressed = @"kiTermIndicatorAllOutputSuppressed";
NSString *const kiTermIndicatorZoomedIn = @"kiTermIndicatorZoomedIn";

static const NSTimeInterval kFullScreenFlashDuration = 0.3;
static const NSTimeInterval kFlashDuration = 0.3;
CGFloat kiTermIndicatorStandardHeight = 20;

@interface iTermIndicator : NSObject
@property(nonatomic, retain) NSImage *image;
@property(nonatomic, readonly) CGFloat alpha;

- (void)startFlash;
@end

@implementation iTermIndicator {
    NSTimeInterval _flashStartTime;
}

- (void)dealloc {
    [_image release];
    [super dealloc];
}

- (void)startFlash {
    _flashStartTime = [NSDate timeIntervalSinceReferenceDate];
}

- (CGFloat)alpha {
    NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - _flashStartTime;
    return MAX(0, 1.0 - elapsed / kFlashDuration);
}

@end

@implementation iTermIndicatorsHelper {
    // Maps an identifier to a NSNumber in [0, 1]
    NSMutableDictionary *_visibleIndicators;
    NSTimeInterval _fullScreenFlashStartTime;
    // Rate limits calls to setNeedsDisplay: to not be faster than drawRect can be called.
    BOOL _haveSetNeedsDisplay;
    
    // Alpha value for fullscreen flash.
    CGFloat _fullScreenAlpha;
}

+ (NSDictionary *)indicatorImages {
    // LMiTerm Edit: Load images from framework bundle
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gIndicatorImages = @{ kiTermIndicatorBell: [[NSBundle bundleForClass:self.class] imageForResource:@"bell"],
                              kiTermIndicatorWrapToTop: [[NSBundle bundleForClass:self.class] imageForResource:@"wrap_to_top"],
                              kiTermIndicatorWrapToBottom: [[NSBundle bundleForClass:self.class] imageForResource:@"wrap_to_bottom"],
                              kItermIndicatorBroadcastInput: [[NSBundle bundleForClass:self.class] imageForResource:@"BroadcastInput"],
                              kiTermIndicatorMaximized: [[NSBundle bundleForClass:self.class] imageForResource:@"Maximized"],
                              kiTermIndicatorCoprocess: [[NSBundle bundleForClass:self.class] imageForResource:@"Coprocess"],
                              kiTermIndicatorAlert: [[NSBundle bundleForClass:self.class] imageForResource:@"Alert"],
                              kiTermIndicatorAllOutputSuppressed: [[NSBundle bundleForClass:self.class] imageForResource:@"SuppressAllOutput"],
                              kiTermIndicatorZoomedIn: [[NSBundle bundleForClass:self.class] imageForResource:@"Zoomed"] };
        [gIndicatorImages retain];
    });
    
    return gIndicatorImages;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _visibleIndicators = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_visibleIndicators release];
    [super dealloc];
}

- (void)setIndicator:(NSString *)identifier visible:(BOOL)visible {
    if (visible && !_visibleIndicators[identifier]) {
        iTermIndicator *indicator = [[[iTermIndicator alloc] init] autorelease];
        indicator.image = [[self class] indicatorImages][identifier];
        _visibleIndicators[identifier] = indicator;;
        [_delegate setNeedsDisplay:YES];
    } else if (!visible && _visibleIndicators[identifier]) {
        [_visibleIndicators removeObjectForKey:identifier];
        [_delegate setNeedsDisplay:YES];
    }
}

+ (NSArray *)flashingIndicatorIdentifiers {
    return @[ kiTermIndicatorBell,
              kiTermIndicatorWrapToTop,
              kiTermIndicatorWrapToBottom ];
}

+ (NSArray *)sequentiaIndicatorlIdentifiers {
    return @[ kiTermIndicatorMaximized,
              kItermIndicatorBroadcastInput,
              kiTermIndicatorCoprocess,
              kiTermIndicatorAlert,
              kiTermIndicatorAllOutputSuppressed,
              kiTermIndicatorZoomedIn ];
}

- (void)drawInFrame:(NSRect)frame {
    DLog(@"drawInFrame %@", NSStringFromRect(frame));

    // Draw top-right indicators.
    NSArray *sequentialIdentifiers = [iTermIndicatorsHelper sequentiaIndicatorlIdentifiers];
    static const CGFloat kIndicatorTopMargin = 4;
    NSPoint point = NSMakePoint(frame.origin.x + frame.size.width,
                                frame.origin.y + kIndicatorTopMargin);
    for (NSString *identifier in sequentialIdentifiers) {
        iTermIndicator *indicator = _visibleIndicators[identifier];
        if (indicator) {
            static const CGFloat kInterIndicatorHorizontalMargin = 4;
            point.x -= indicator.image.size.width;
            point.x -= kInterIndicatorHorizontalMargin;
            NSImage *image = indicator.image;
            [image drawInRect:NSMakeRect(point.x, point.y, image.size.width, image.size.height)
                     fromRect:NSMakeRect(0, 0, image.size.width, image.size.height)
                    operation:NSCompositeSourceOver
                     fraction:0.5
               respectFlipped:YES
                        hints:nil];
        }
    }

    // Draw centered flashing indicators.
    NSArray *centeredIdentifiers = [iTermIndicatorsHelper flashingIndicatorIdentifiers];
    NSMutableArray *keysToRemove = [NSMutableArray array];
    for (NSString *identifier in centeredIdentifiers) {
        iTermIndicator *indicator = _visibleIndicators[identifier];
        CGFloat alpha = indicator.alpha;
        if (alpha > 0) {
            NSImage *image = indicator.image;
            NSSize size = [image size];
            NSRect destinationRect = NSMakeRect(frame.origin.x + frame.size.width / 2 - size.width / 2,
                                                frame.origin.y + frame.size.height / 2 - size.height / 2,
                                                size.width,
                                                size.height);
            [image drawInRect:destinationRect
                     fromRect:NSMakeRect(0, 0, size.width, size.height)
                    operation:NSCompositeSourceOver
                     fraction:alpha
               respectFlipped:YES
                        hints:nil];
        }
    }

    [_visibleIndicators removeObjectsForKeys:keysToRemove];

    // Draw full screen flash.
    NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - _fullScreenFlashStartTime;
    DLog(@"elapsed=%@, fullScreenAlpha=%@", @(elapsed), @(_fullScreenAlpha));
    if (_fullScreenAlpha > 0) {
        DLog(@"Drawing full screen flash overlay");
        [[[_delegate indicatorFullScreenFlashColor] colorWithAlphaComponent:_fullScreenAlpha] set];
        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
    } else if (_fullScreenFlashStartTime > 0 && _fullScreenAlpha == 0) {
        DLog(@"Not drawing full screen flash overlay");
    }
    DLog(@"Set haveSetNeedsDisplay=NO");
    _haveSetNeedsDisplay = NO;
}

- (void)checkForFlashUpdate {
    DLog(@"Check for flash update. full screen flash start time is %@, haveSetNeedsDisplay=%@",
         @(_fullScreenFlashStartTime), @(_haveSetNeedsDisplay));
    NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - _fullScreenFlashStartTime;
    if (_fullScreenFlashStartTime > 0 || [self haveFlashingIndicator]) {
        const CGFloat kMaxFullScreenFlashAlpha = 0.5;
        _fullScreenAlpha = MAX(0, 1.0 - elapsed / kFullScreenFlashDuration) * kMaxFullScreenFlashAlpha;
        DLog(@"Set fullScreenAlpha=%@", @(_fullScreenAlpha));
        if (!_haveSetNeedsDisplay) {
            DLog(@"Tell delegate %@ setNeedsDisplay", _delegate);
            [_delegate setNeedsDisplay:YES];
        }
        DLog(@"Set haveSetNeedsDisplay=YES");
        _haveSetNeedsDisplay = YES;
        
        // Ensure that the screen gets redrawn with alpha = 0.
        if (_fullScreenAlpha == 0) {
            DLog(@"Reset fullScreenFlashStartTime");
            _fullScreenFlashStartTime = 0;
        }
    }

    // Remove any indicators that became invisible since the last check.
    NSArray *visibleIdentifiers = [[_visibleIndicators.allKeys copy] autorelease];
    for (NSString *identifier in visibleIdentifiers) {
        if ([_visibleIndicators[identifier] alpha] == 0) {
            [_visibleIndicators removeObjectForKey:identifier];
        }
    }

    // Request another update if needed.
    if (_fullScreenFlashStartTime > 0 || [self haveFlashingIndicator]) {
        DLog(@"Schedule another call to checkForFlashUpdate");
        [self performSelector:@selector(checkForFlashUpdate) withObject:nil afterDelay:1 / 60.0];
    }
}

- (void)beginFlashingIndicator:(NSString *)identifier {
    assert([[iTermIndicatorsHelper flashingIndicatorIdentifiers] containsObject:identifier]);
    if (_visibleIndicators[identifier]) {
        return;
    }
    [self setIndicator:identifier visible:YES];
    [_visibleIndicators[identifier] startFlash];
    [self checkForFlashUpdate];
}

- (BOOL)haveFlashingIndicator {
    for (NSString *identifier in [iTermIndicatorsHelper flashingIndicatorIdentifiers]) {
        if (_visibleIndicators[identifier]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)numberOfVisibleIndicators {
    return _visibleIndicators.count;
}

- (void)beginFlashingFullScreen {
    _fullScreenFlashStartTime = [NSDate timeIntervalSinceReferenceDate];
    [_delegate setNeedsDisplay:YES];
    [self checkForFlashUpdate];
}

@end
