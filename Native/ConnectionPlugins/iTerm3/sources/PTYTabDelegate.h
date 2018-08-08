//
//  PTYTabDelegate.h
//  iTerm2
//
//  Created by George Nachman on 6/9/15.
//
//

@class PTYTab;
@class NSImage;

// States
typedef NS_OPTIONS(NSUInteger, PTYTabState) {
    // Bell has rung.
    kPTYTabBellState = (1 << 0),

    // Background tab is idle; it's been a while since new output arrived.
    kPTYTabIdleState = (1 << 1),

    // Background tab just got new output.
    kPTYTabNewOutputState = (1 << 2),

    // A session has ended.
    kPTYTabDeadState = (1 << 3)
};

@protocol PTYTabDelegate<NSObject>

- (void)tab:(PTYTab *)tab didChangeProcessingStatus:(BOOL)isProcessing;
- (void)tab:(PTYTab *)tab didChangeIcon:(NSImage *)icon;
- (void)tab:(PTYTab *)tab didChangeObjectCount:(NSInteger)objectCount;
- (void)tab:(PTYTab *)tab didChangeToState:(PTYTabState)newState;

@end
