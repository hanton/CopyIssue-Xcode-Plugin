//
//  HTYCopyIssue.m
//  HTYCopyIssue
//
//  Created by  on 2/2/15.
//  Copyright (c) 2015 Hanton. All rights reserved.
//

#import "HTYCopyIssue.h"
#import "Aspects/Aspects.h"
#import <objc/runtime.h>

static HTYCopyIssue *sharedPlugin;
static NSString *const HTYStripQuotationMarksKey = @"HTYStripQuotationMarks";

@class IDEIssueNavigatorOutlineView;

@implementation HTYCopyIssue
{
    // Edit menu items
    NSMenuItem *_copyIssueMenuItem;
    NSMenuItem *_googleItem;
    NSMenuItem *_stackoverflowItem;
    NSMenuItem *_searchMenuItem;
    NSMenuItem *_toggleStripQuotationItem;
    
    // Context menu items
    NSMenuItem *_copyIssueContextMenuItem;
    NSMenuItem *_googleContextMenuItem;
    NSMenuItem *_stackoverflowContextMenuItem;
    NSMenuItem *_contextMenuSearchMenuItem;
    BOOL _enableContextMenuItems;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ HTYStripQuotationMarksKey : @YES }];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _enableContextMenuItems = NO;
            [self createMenuItems];
            [self swizzleMenuForEventInNSTableView];
            [self swizzleSetEnabledInNSMenuItem];
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createMenuItems
{
    NSMenuItem* menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        _copyIssueMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy Issue" action:@selector(copyIssueAction:) keyEquivalent:@"V"];
        [_copyIssueMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSCommandKeyMask];
        [_copyIssueMenuItem setTarget:self];
        [[menuItem submenu] insertItem:_copyIssueMenuItem atIndex:5];
        
        NSMenu* searchSubmenu = [[NSMenu alloc] init];
        [searchSubmenu setDelegate:self];
        
        _googleItem = [[NSMenuItem alloc] initWithTitle:@"Ask Google" action:@selector(searchGoogleAction:) keyEquivalent:@"G"];
        [_googleItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
        [_googleItem setTarget:self];
        [searchSubmenu addItem:_googleItem];
        
        _stackoverflowItem = [[NSMenuItem alloc] initWithTitle:@"Ask Stackoverflow" action:@selector(searchStackoverflowAction:) keyEquivalent:@"S"];
        [_stackoverflowItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
        [_stackoverflowItem setTarget:self];
        [searchSubmenu addItem:_stackoverflowItem];
        
        [searchSubmenu addItem:[NSMenuItem separatorItem]];
        
        _toggleStripQuotationItem = [[NSMenuItem alloc] initWithTitle:@"Strip content inside quotation mark" action:@selector(toggleStripQuotationMarks:) keyEquivalent:@""];
        [_toggleStripQuotationItem setTarget:self];
        BOOL stripQuotationMark = [[NSUserDefaults standardUserDefaults] boolForKey:HTYStripQuotationMarksKey];
        [_toggleStripQuotationItem setState:(stripQuotationMark) ? NSOnState : NSOffState];
        [searchSubmenu addItem:_toggleStripQuotationItem];
        
        [[menuItem submenu] insertItem:[NSMenuItem separatorItem] atIndex:6];
        
        _searchMenuItem = [[NSMenuItem alloc] initWithTitle:@"ASK THE INTERNET" action:nil keyEquivalent:@""];
        [_searchMenuItem setSubmenu:searchSubmenu];
        
        [[menuItem submenu] insertItem:_searchMenuItem atIndex:7];
        [[menuItem submenu] insertItem:[NSMenuItem separatorItem] atIndex:8];
        
        _copyIssueContextMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy Issue" action:@selector(copyIssueAction:) keyEquivalent:@""];
        [_copyIssueContextMenuItem setTarget:self];
        
        _googleContextMenuItem = [[NSMenuItem alloc] initWithTitle:@"Ask Google" action:@selector(searchGoogleAction:) keyEquivalent:@""];
        [_googleContextMenuItem setTarget:self];
        
        _stackoverflowContextMenuItem = [[NSMenuItem alloc] initWithTitle:@"Ask Stackoverflow" action:@selector(searchStackoverflowAction:) keyEquivalent:@""];
        [_stackoverflowContextMenuItem setTarget:self];
        
        _contextMenuSearchMenuItem = [[NSMenuItem alloc] initWithTitle:@"ASK THE INTERNET" action:nil keyEquivalent:@""];
        [_searchMenuItem setSubmenu:searchSubmenu];
        
        NSMenu* contextMenuSearchSubmenu = [[NSMenu alloc] init];
        [contextMenuSearchSubmenu setDelegate:self];
        [contextMenuSearchSubmenu addItem:_googleContextMenuItem];
        [contextMenuSearchSubmenu addItem:_stackoverflowContextMenuItem];
        [_contextMenuSearchMenuItem setSubmenu:contextMenuSearchSubmenu];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem == _toggleStripQuotationItem) return YES;
    if (menuItem == _copyIssueMenuItem || menuItem == _googleItem || menuItem == _stackoverflowItem)
        return [self shouldEnableSearchMenuItems];
    if (menuItem == _copyIssueContextMenuItem || menuItem == _googleContextMenuItem || menuItem == _stackoverflowContextMenuItem)
        return _enableContextMenuItems;
    return NO;
}

- (BOOL)shouldEnableSearchMenuItems
{
    return [[self copyMenuItem] isEnabled];
}

- (NSMenuItem *)copyMenuItem
{
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    NSMenu* menu = editMenuItem.submenu;
    NSMenuItem* copyItem = [menu itemWithTitle:@"Copy"];
    return copyItem;
}

- (NSString *)searchString
{
    NSString *issueString = [self formattedIssueString];
    
    if (!issueString)
        return nil;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HTYStripQuotationMarks"]) return issueString;

    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"'[^']*'" options:0 error:&error];
    if (!regex) {
        NSLog(@"*** ERROR: Could not create regex: %@", error);
        return nil;
    }
    
    issueString = [regex stringByReplacingMatchesInString:issueString options:0 range:NSMakeRange(0, issueString.length) withTemplate:@""];
    return issueString;
}

#pragma mark - Actions

- (void)copyIssueAction:(id)sender
{
    if (sender == _copyIssueMenuItem)
        [self getStringOntoClipboardForItemsInEditMenu];
    [self formattedIssueString];
}

- (void)searchGoogleAction:(id)sender
{
    if (sender == _googleItem)
        [self getStringOntoClipboardForItemsInEditMenu];
    [self openIssueInBrowser:[self searchString] urlPrefix:@"https://www.google.com?#q="];
}

- (void)searchStackoverflowAction:(id)sender
{
    if (sender == _stackoverflowItem)
        [self getStringOntoClipboardForItemsInEditMenu];
    [self openIssueInBrowser:[self searchString] urlPrefix:@"http://stackoverflow.com/search?q="];
}

-(void)getStringOntoClipboardForItemsInEditMenu {
    // Clear the Pasteboard
    NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    
    // Copy Issue
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    NSMenu* menu = editMenuItem.submenu;
    [menu performActionForItemAtIndex:4];
}

-(void)getStringOntoClipboardForItemsInContextMenu:(NSMenuItem*)copyContextMenuItem {
    // Clear the pasteboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    
    // Copy Issue
    [copyContextMenuItem.menu performActionForItemAtIndex:0];
}

- (NSString *)formattedIssueString {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    
    // Format Issue
    NSArray* classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSDictionary* options = [NSDictionary dictionary];
    NSArray* copiedItems = [pasteboard readObjectsForClasses:classes options:options];
    if (copiedItems != nil && [copiedItems count] > 0) {
        // Regular Expression
        NSString* copiedString = copiedItems.firstObject;
        NSString* pattern = @"^\\S* ";
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        
        NSString* formatedString = [regex stringByReplacingMatchesInString:copiedString options:0 range:NSMakeRange(0, copiedString.length) withTemplate:@""]; // This is the line that crashes and it is because copiedItems is nil
        
        // Copy formatedString to the Pasteboard
        NSArray* objectsToCopy = @[formatedString];
        [pasteboard clearContents];
        [pasteboard writeObjects:objectsToCopy];
        
        return formatedString;
    }
    
    return nil;
}

- (void)toggleStripQuotationMarks:(NSMenuItem *)sender
{
    BOOL currentStripQuotationState = [sender state] == NSOnState;
    [[NSUserDefaults standardUserDefaults] setBool:!currentStripQuotationState forKey:HTYStripQuotationMarksKey];
    [sender setState:(currentStripQuotationState) ? NSOffState : NSOnState];
}

- (void)openIssueInBrowser:(NSString*)issue urlPrefix:(NSString *)urlPrefix
{
    if (issue.length >0) {
        NSURL *urlToOpen = [NSURL URLWithString:[urlPrefix stringByAppendingString:[issue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        if(urlToOpen) {
            // Handle special cases
            @try {
                [[NSWorkspace sharedWorkspace] openURLs:@[urlToOpen]
                                withAppBundleIdentifier:nil
                                                options:NSWorkspaceLaunchDefault
                         additionalEventParamDescriptor:nil
                                      launchIdentifiers:nil];
            }
            
            @catch (NSException *exception) {
                NSLog(@"Exception: %@", [exception description]);
            }
        }
    }
}

#pragma mark - Swizzling

#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"

// this will add the custom context menu items to the issue navigator's context menu
- (void)swizzleMenuForEventInNSTableView
{
    Class c = NSClassFromString(@"NSTableView");
    [c aspect_hookSelector:@selector(menuForEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, NSEvent *event) {
        NSObject *object = info.instance;
        
        if(![object isKindOfClass:NSClassFromString(@"IDENavigatorOutlineView")]) {
            [info.originalInvocation invoke];
        }
        else {
            NSInvocation *invocation = info.originalInvocation;
            NSMenu *contextMenu;
            [invocation invoke];
            [invocation getReturnValue:&contextMenu];
            CFRetain((__bridge CFTypeRef)(contextMenu)); // need to retain return value so it isn't dealloced before being returned
            id holder = [info.instance performSelector:(@selector(realDataSource))];
            if ([holder isKindOfClass:NSClassFromString(@"IDEIssueNavigator")] && [contextMenu itemWithTitle:@"Copy Issue"]==nil) {
                [contextMenu insertItem:_copyIssueContextMenuItem atIndex:1];
                [contextMenu insertItem:[NSMenuItem separatorItem] atIndex:2];
                [contextMenu insertItem:_contextMenuSearchMenuItem atIndex:3];
                [contextMenu insertItem:[NSMenuItem separatorItem] atIndex:4];
            }
            [invocation setReturnValue:&contextMenu];
        }
    } error:NULL];
}

// This will add logic to the context menu's enable setter to determine whether to enable the custom context menu items
- (void)swizzleSetEnabledInNSMenuItem {
    [NSMenuItem aspect_hookSelector:@selector(setEnabled:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, BOOL enabled) {
        NSMenuItem *item = info.instance;
        if ([item.title isEqualToString:@"Copy"] && [item.menu.title isEqualToString:@"Issue navigator contextual menu"])
        {
            _enableContextMenuItems = [item isEnabled];
            [self getStringOntoClipboardForItemsInContextMenu:item];
        }
    } error:NULL];
}


#pragma clang diagnostic pop

@end
