#import "PTYWindow+Scripting.h"
#import "DebugLogging.h"
#import "iTermApplication.h"
#import "iTermController.h"
#import "PTYSession.h"
#import "PTYTab.h"

@implementation PTYWindow (Scripting)

- (NSScriptObjectSpecifier *)objectSpecifier {
    NSUInteger anIndex = 0;
    id classDescription = nil;

    NSScriptObjectSpecifier *containerRef;

    NSArray *windows = [iTermApplication.sharedApplication orderedTerminalWindows];
    anIndex = [windows indexOfObjectIdenticalTo:self];
    if (anIndex != NSNotFound) {
        containerRef = [NSApp objectSpecifier];
        classDescription = [NSClassDescription classDescriptionForClass:[NSApp class]];
        return [[[NSUniqueIDSpecifier alloc] initWithContainerClassDescription:classDescription
                                                            containerSpecifier:containerRef
                                                                           key:@"orderedTerminalWindows"
                                                                      uniqueID:@([self windowNumber])] autorelease];
    } else {
        return nil;
    }
}

#pragma mark - Handlers for commands

- (id)handleSelectCommand:(NSScriptCommand *)command {
    [[iTermController sharedInstance] setCurrentTerminal:self.delegate];
    return nil;
}

- (id)handleCloseScriptCommand:(NSScriptCommand *)command {
    [self performClose:nil];
    return nil;
}

- (id)handleCreateTabWithDefaultProfileCommand:(NSScriptCommand *)scriptCommand {
    NSDictionary *args = [scriptCommand evaluatedArguments];
    NSString *command = args[@"command"];
    Profile *profile = [[ProfileModel sharedInstance] defaultBookmark];
    PTYSession *session =
        [[iTermController sharedInstance] launchBookmark:profile
                                              inTerminal:self.delegate
                                                 withURL:nil
                                                isHotkey:NO
                                                 makeKey:YES
                                             canActivate:NO
                                                 command:command
                                                   block:nil];
    return [self.delegate tabForSession:session];
}

- (id)handleCreateTabCommand:(NSScriptCommand *)scriptCommand {
    NSDictionary *args = [scriptCommand evaluatedArguments];
    NSString *command = args[@"command"];
    NSString *profileName = args[@"profile"];
    Profile *profile = [[ProfileModel sharedInstance] bookmarkWithName:profileName];
    if (!profile) {
        [scriptCommand setScriptErrorNumber:1];
        [scriptCommand setScriptErrorString:[NSString stringWithFormat:@"No profile exists named '%@'",
                                             profileName]];
        return nil;
    }
    PTYSession *session =
        [[iTermController sharedInstance] launchBookmark:profile
                                              inTerminal:self.delegate
                                                 withURL:nil
                                                isHotkey:NO
                                                 makeKey:YES
                                             canActivate:NO
                                                 command:command
                                                   block:nil];
    return [self.delegate tabForSession:session];
}

#pragma mark - Accessors

- (NSArray *)tabs {
    return [self.delegate tabs];
}

- (void)setTabs:(NSArray *)tabs {
}

#pragma mark NSScriptKeyValueCoding for to-many relationships
// (See NSScriptKeyValueCoding.h)

- (NSUInteger)count {
    return 1;
}

- (NSUInteger)countOfTabs {
    return [[self.delegate tabs] count];
}

- (id)valueInTabsAtIndex:(unsigned)anIndex {
    return [self.delegate tabs][anIndex];
}

- (void)replaceInTabs:(PTYTab *)replacementTab atIndex:(unsigned)anIndex {
    [self.delegate insertInTabs:replacementTab atIndex:anIndex];
    [self.delegate closeTab:[self.delegate tabs][anIndex + 1]];
}

- (void)insertInTabs:(PTYTab *)tab atIndex:(unsigned)anIndex {
    [self.delegate insertTab:tab atIndex:anIndex];
}

- (void)removeFromTabsAtIndex:(unsigned)anIndex {
    NSArray *tabs = [self.delegate tabs];
    [self.delegate closeTab:tabs[anIndex]];
}


- (PTYTab *)currentTab {
    return [self.delegate currentTab];
}

- (PTYSession *)currentSession {
    return [self.delegate currentSession];
}

@end
