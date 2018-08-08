#import "SessionView+LMiTerm.h"

NSString* const LMSessionViewDidMoveToWindowNotification = @"LMSessionViewDidMoveToWindowNotification";

@implementation SessionView (LMiTerm)

- (void)viewDidMoveToWindow
{
    [NSNotificationCenter.defaultCenter postNotificationName:LMSessionViewDidMoveToWindowNotification object:self];
}

@end
