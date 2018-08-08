#import "LMiTermApplication.h"

#import "LMiTermController.h"

static LMiTermApplication* _gSharedApplication;

@implementation LMiTermApplication

+ (instancetype)sharedApplication
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gSharedApplication = [[LMiTermApplication alloc] init];
    });
    
    return _gSharedApplication;
}

- (LMiTermController*)delegate
{
    return LMiTermController.sharedController;
}

@end
