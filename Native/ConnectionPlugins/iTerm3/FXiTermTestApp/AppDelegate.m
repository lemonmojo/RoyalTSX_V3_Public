#import "AppDelegate.h"

#import "SolidColorView.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *windowFirst;
@property (assign) IBOutlet SolidColorView *placeholderViewFirstLeft;
@property (assign) IBOutlet SolidColorView *placeholderViewFirstRight;

@property (assign) IBOutlet NSWindow *windowSecond;
@property (assign) IBOutlet SolidColorView *placeholderViewSecondLeft;
@property (assign) IBOutlet SolidColorView *placeholderViewSecondRight;

@property (assign) IBOutlet NSWindow *windowThird;
@property (assign) IBOutlet SolidColorView *placeholderViewThirdLeft;
@property (assign) IBOutlet SolidColorView *placeholderViewThirdRight;

@property (assign) IBOutlet NSWindow *windowScreenshot;
@property (assign) IBOutlet NSImageView *imageViewScreenshot;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LMiTermController.sharedController.delegate = self;
    
    NSColor *colorLeftPlaceholder = NSColor.greenColor;
    NSColor *colorLeftTerminal = [colorLeftPlaceholder shadowWithLevel:0.9];
    
    NSColor *colorRightPlaceholder = NSColor.blueColor;
    NSColor *colorRightTerminal = [colorRightPlaceholder shadowWithLevel:0.9];
    
    self.placeholderViewFirstLeft.color = colorLeftPlaceholder;
    self.placeholderViewFirstRight.color = colorRightPlaceholder;
    
    self.placeholderViewSecondLeft.color = colorLeftPlaceholder;
    self.placeholderViewSecondRight.color = colorRightPlaceholder;
    
    self.placeholderViewThirdLeft.color = colorLeftPlaceholder;
    self.placeholderViewThirdRight.color = colorRightPlaceholder;
    
    [self createSessionInParentView:self.placeholderViewFirstLeft withBackgroundColor:colorLeftTerminal];
    [self createSessionInParentView:self.placeholderViewFirstRight withBackgroundColor:colorRightTerminal];
    
    [self createSessionInParentView:self.placeholderViewSecondLeft withBackgroundColor:colorLeftTerminal];
    [self createSessionInParentView:self.placeholderViewSecondRight withBackgroundColor:colorRightTerminal];
}

- (LMiTermSessionController*)createSessionInParentView:(NSView*)parentView withBackgroundColor:(NSColor*)backgroundColor
{
    NSMutableDictionary* profileTemp = [[LMiTermSessionController.defaultProfile mutableCopy] autorelease];
    
    [profileTemp setObject:[ITAddressBookMgr encodeColor:backgroundColor] forKey:KEY_BACKGROUND_COLOR];
    
    [profileTemp setObject:@0.5f forKey:KEY_TRANSPARENCY];
    self.windowFirst.opaque = NO;
    
    Profile* profile = [[profileTemp copy] autorelease];
    
    LMiTermSessionController* session = [[LMiTermController sharedController] createSessionWithProfile:profile command:[ITAddressBookMgr standardLoginCommand] initialSize:parentView.bounds.size];
    
    session.view.frame = NSMakeRect(0, 0, parentView.bounds.size.width, parentView.bounds.size.height);
    session.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
    
    [parentView addSubview:session.view];
    
    return session;
}

- (void)controller:(LMiTermController *)controller shouldRemoveSessionView:(LMiTermSessionController *)session
{
    NSView* sessionView = [[session.view retain] autorelease];
    [sessionView removeFromSuperview];
    
    NSLog(@"Session View was removed");
}

- (void)controller:(LMiTermController *)controller sessionDidClose:(LMiTermSessionController *)session
{
    NSLog(@"Session did Close");
}

- (IBAction)menuItemShowFindPanel_action:(id)sender
{
    [LMiTermController.sharedController.activeSession showFindPanel];
}

- (IBAction)menuItemFindCursor_action:(id)sender
{
    [LMiTermController.sharedController.activeSession findCursor];
}

- (IBAction)menuItemHighlightCursorLine_action:(id)sender
{
    NSMenuItem *menuItem = sender;
    
    LMiTermSessionController* session = LMiTermController.sharedController.activeSession;
    
    session.highlightCursorLine = !session.highlightCursorLine;
    
    menuItem.state = session.highlightCursorLine ? NSOnState : NSOffState;
}

- (IBAction)menuItemShowTimestamps_action:(id)sender
{
    NSMenuItem *menuItem = sender;
    
    LMiTermSessionController* session = LMiTermController.sharedController.activeSession;
    
    session.showTimestamps = !session.showTimestamps;
    
    menuItem.state = session.showTimestamps ? NSOnState : NSOffState;
}

- (IBAction)menuItemBroadcastInput_action:(id)sender
{
    NSMenuItem *menuItem = sender;
    
    LMiTermController.sharedController.broadcasting = !LMiTermController.sharedController.broadcasting;
    
    menuItem.state = LMiTermController.sharedController.broadcasting ? NSOnState : NSOffState;
}

- (IBAction)menuItemPaste_action:(id)sender
{
    [LMiTermController.sharedController.activeSession paste];
}

- (IBAction)menuItemPasteSlowly_action:(id)sender
{
    [LMiTermController.sharedController.activeSession pasteSlowly];
}

- (IBAction)menuItemPasteEscapingSpecialCharacters_action:(id)sender
{
    [LMiTermController.sharedController.activeSession pasteEscapingSpecialCharacters];
}

- (IBAction)menuItemPasteAdvanced_action:(id)sender
{
    [LMiTermController.sharedController.activeSession pasteAdvanced];
}

- (IBAction)menuItemClearBuffer_action:(id)sender
{
    [LMiTermController.sharedController.activeSession clearBuffer];
}

- (IBAction)menuItemClearScrollbackBuffer_action:(id)sender
{
    [LMiTermController.sharedController.activeSession clearScrollbackBuffer];
}

- (IBAction)menuItemOpenAutocomplete_action:(id)sender
{
    [LMiTermController.sharedController.activeSession openAutocomplete];
}

- (IBAction)menuItemSetMark_action:(id)sender
{
    [LMiTermController.sharedController.activeSession setMark];
}

- (IBAction)menuItemJumpToMark_action:(id)sender
{
    [LMiTermController.sharedController.activeSession jumpToMark];
}

- (IBAction)menuItemJumpToNextMark_action:(id)sender
{
    [LMiTermController.sharedController.activeSession jumpToNextMark];
}

- (IBAction)menuItemJumpToPreviousMark_action:(id)sender
{
    [LMiTermController.sharedController.activeSession jumpToPreviousMark];
}

- (IBAction)menuItemJumpToSelection_action:(id)sender
{
    [LMiTermController.sharedController.activeSession jumpToSelection];
}

- (IBAction)menuItemToggleLogging_action:(id)sender
{
    LMiTermController.sharedController.activeSession.logging = !LMiTermController.sharedController.activeSession.logging;
}

- (IBAction)menuItemSelectAll_action:(id)sender
{
    [LMiTermController.sharedController.activeSession selectAll];
}

- (IBAction)menuItemSelectOutputOfLastCommand_action:(id)sender
{
    [LMiTermController.sharedController.activeSession selectOutputOfLastCommand];
}

- (IBAction)menuItemSelectCurrentCommand_action:(id)sender
{
    [LMiTermController.sharedController.activeSession selectCurrentCommand];
}

- (IBAction)menuItemMakeTextBigger_action:(id)sender
{
    [LMiTermController.sharedController.activeSession increaseFontSize];
}

- (IBAction)menuItemMakeTextNormalSize_action:(id)sender
{
    [LMiTermController.sharedController.activeSession restoreFontSize];
}

- (IBAction)menuItemMakeTextSmaller_action:(id)sender
{
    [LMiTermController.sharedController.activeSession decreaseFontSize];
}

- (IBAction)menuItemShowAnnotations_action:(id)sender
{
    [LMiTermController.sharedController.activeSession toggleShowAnnotations];
    
    NSMenuItem* menuItem = sender;
    
    menuItem.state = LMiTermController.sharedController.activeSession.showAnnotations ? NSOnState : NSOffState;
}

- (IBAction)menuItemAddAnnotationAtCursor_action:(id)sender
{
    [LMiTermController.sharedController.activeSession addAnnotationAtCursor];
}

- (IBAction)menuItemInstallShellIntegration_action:(id)sender
{
    [LMiTermController.sharedController.activeSession tryToRunShellIntegrationInstallerWithPromptCheck:NO];
}





- (IBAction)menuItemMoveTerminalsInFirstWindowToThirdWindow_action:(id)sender
{
    NSView* sessionViewFirstLeft = self.placeholderViewFirstLeft.subviews[0];
    NSView* sessionViewFirstRight = self.placeholderViewFirstRight.subviews[0];
    
    [sessionViewFirstLeft retain];
    [sessionViewFirstLeft removeFromSuperview];
    
    [self.placeholderViewThirdLeft addSubview:sessionViewFirstLeft];
    sessionViewFirstLeft.frame = self.placeholderViewThirdLeft.bounds;
    
    [sessionViewFirstLeft release];
    
    [sessionViewFirstRight retain];
    [sessionViewFirstRight removeFromSuperview];
    
    [self.placeholderViewThirdRight addSubview:sessionViewFirstRight];
    sessionViewFirstRight.frame = self.placeholderViewThirdRight.bounds;
    
    [sessionViewFirstRight release];
    
    [self.windowFirst close];
    
    [self.windowThird makeKeyAndOrderFront:self];
}

- (IBAction)menuItemTakeScreenshot_action:(id)sender
{
    NSImage* screenshot = LMiTermController.sharedController.activeSession.screenshot;
    
    if (screenshot) {
        [self.windowScreenshot makeKeyAndOrderFront:self];
        self.imageViewScreenshot.image = screenshot;
    }
}

@end
