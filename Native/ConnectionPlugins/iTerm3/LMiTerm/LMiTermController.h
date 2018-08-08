#import <Cocoa/Cocoa.h>

#import "LMiTermSessionController.h"

@class PTYSession;
@class LMiTermController;

@protocol LMiTermControllerDelegate

- (void)controller:(LMiTermController*)controller shouldRemoveSessionView:(LMiTermSessionController*)session;

@optional
- (void)controller:(LMiTermController*)controller sessionDidClose:(LMiTermSessionController*)session;

@end

@interface LMiTermController : NSObject<LMiTermSessionDelegate>

+ (instancetype)sharedController;

@property (readonly, copy) NSArray<LMiTermSessionController*>* sessions;
@property (readonly) LMiTermSessionController* activeSession;
@property (assign) id<LMiTermControllerDelegate> delegate;
@property (assign) BOOL broadcasting;

- (LMiTermSessionController*)createSessionWithProfile:(Profile*)profile command:(NSString*)command initialSize:(NSSize)initialSize;

@end
