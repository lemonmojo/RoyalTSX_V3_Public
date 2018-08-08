#import <Cocoa/Cocoa.h>

@class LMiTermController;

@interface LMiTermApplication : NSObject

+ (instancetype)sharedApplication;

@property (readonly) LMiTermController *delegate;

@end
