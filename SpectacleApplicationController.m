#import "SpectacleApplicationController.h"
#import "SpectacleUtilities.h"
#import "SpectacleConstants.h"

@interface SpectacleApplicationController (SpectacleApplicationControllerPrivate)

- (void)createStatusItem;

- (void)destroyStatusItem;

#pragma mark -

- (void)enableStatusItem: (NSNotification *)notification;

- (void)disableStatusItem: (NSNotification *)notification;

#pragma mark -

- (void)menuDidSendAction: (NSNotification *)notification;

@end

#pragma mark -

@implementation SpectacleApplicationController

- (void)applicationDidFinishLaunching: (NSNotification *)notification {
    [SpectacleUtilities registerDefaultsForBundle: [SpectacleUtilities applicationBundle]];
    
    if (!AXAPIEnabled()) {
        [SpectacleUtilities displayAccessibilityAPIAlert];
        
        [[NSApplication sharedApplication] terminate: self];
        
        return;
    }
    
    [self registerHotKeys];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey: SpectacleStatusItemEnabledPreference]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver: self
                               selector: @selector(enableStatusItem:)
                                   name: SpectacleStatusItemEnabledNotification
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(disableStatusItem:)
                                   name: SpectacleStatusItemDisabledNotification
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(menuDidSendAction:)
                                   name: NSMenuDidSendActionNotification
                                 object: nil];
        
        [self createStatusItem];
    }
}

#pragma mark -

- (IBAction)togglePreferencesWindow: (id)sender {
    [[ZeroKitPreferencesWindowController sharedController] togglePreferencesWindow: sender];
}

@end

#pragma mark -

@implementation SpectacleApplicationController (SpectacleApplicationControllerPrivate)

- (void)createStatusItem {
    NSString *applicationVersion = [SpectacleUtilities standaloneApplicationVersion];
    
    myStatusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength] retain];
    
    [myStatusItem setTitle: @"sP"];
    [myStatusItem setHighlightMode: YES];
    
    if (applicationVersion) {
        [myStatusItem setToolTip: [NSString stringWithFormat: @"Spectacle %@", applicationVersion]];
    } else {
        [myStatusItem setToolTip: @"Spectacle"];
    }
    
    [myStatusItem setMenu: myStatusItemMenu];
}

- (void)destroyStatusItem {
    [[NSStatusBar systemStatusBar] removeStatusItem: myStatusItem];
    
    [myStatusItem release];
}

#pragma mark -

- (void)enableStatusItem: (NSNotification *)notification {
    [self createStatusItem];
}

- (void)disableStatusItem: (NSNotification *)notification {
    [self destroyStatusItem];
}

#pragma mark -

- (void)menuDidSendAction: (NSNotification *)notification {
    [[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
}

@end
