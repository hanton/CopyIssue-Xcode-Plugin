//
//  HTYCopyIssue.m
//  HTYCopyIssue
//
//  Created by  on 2/2/15.
//  Copyright (c) 2015 Hanton. All rights reserved.
//

#import "HTYCopyIssue.h"
#import "Aspects.h"

static HTYCopyIssue *sharedPlugin;

@implementation HTYCopyIssue
{
    NSMenuItem *_googleItem;
    NSMenuItem *_stackoverflowItem;
    NSMenuItem *_searchMenuItem;
    BOOL _stripInsideQuotationMarks;
    NSMenuItem *_toggleStripQuotationItem;
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
        _stripInsideQuotationMarks = YES;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self createMenuItem];
        }];
    }
    return self;
}

- (void)createMenuItem
{
    NSMenuItem* menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        NSMenuItem* actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy Issue" action:@selector(doMenuAction) keyEquivalent:@"V"];
        [actionMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSCommandKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] insertItem:actionMenuItem atIndex:5];
        
        NSMenu* searchSubmenu = [[NSMenu alloc] init];
        [searchSubmenu setDelegate:self];
        
        _googleItem = [[NSMenuItem alloc] initWithTitle:@"Ask Google" action:@selector(searchGoogleAction:) keyEquivalent:@"g"];
        [_googleItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
        [_googleItem setTarget:self];
        [searchSubmenu addItem:_googleItem];
        
        _stackoverflowItem = [[NSMenuItem alloc] initWithTitle:@"Ask Stackoverflow" action:@selector(searchStackoverflowAction:) keyEquivalent:@"s"];
        [_stackoverflowItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSAlternateKeyMask];
        [_stackoverflowItem setTarget:self];
        [searchSubmenu addItem:_stackoverflowItem];
        
        [searchSubmenu addItem:[NSMenuItem separatorItem]];
        
        _toggleStripQuotationItem = [[NSMenuItem alloc] initWithTitle:@"Strip content inside quotation mark" action:@selector(toggleStripQuotationMarks:) keyEquivalent:@""];
        [_toggleStripQuotationItem setTarget:self];
        [_toggleStripQuotationItem setState:NSOnState];
        [searchSubmenu addItem:_toggleStripQuotationItem];
        
        [[menuItem submenu] insertItem:[NSMenuItem separatorItem] atIndex:6];
        
        _searchMenuItem = [[NSMenuItem alloc] initWithTitle:@"ASK THE INTERNET" action:nil keyEquivalent:@""];
        [_searchMenuItem setSubmenu:searchSubmenu];
        
        [[menuItem submenu] insertItem:_searchMenuItem atIndex:7];
        [[menuItem submenu] insertItem:[NSMenuItem separatorItem] atIndex:8];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem == _toggleStripQuotationItem) return YES;
    if (menuItem == _googleItem || menuItem == _stackoverflowItem) return [self shouldEnableSearchMenuItems];
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
    
    if (!_stripInsideQuotationMarks) return issueString;

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

- (void)searchGoogleAction:(id)sender
{
    [self openIssueInBrowser:[self searchString] urlPrefix:@"https://www.google.de?#q="];
}

- (void)searchStackoverflowAction:(id)sender
{
    [self openIssueInBrowser:[self searchString] urlPrefix:@"http://stackoverflow.com/search?q="];
}

- (NSString *)formattedIssueString {
    // Clear the Pasteboard
    NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    
    // Copy Issue
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    NSMenu* menu = editMenuItem.submenu;
    [menu performActionForItemAtIndex:4];
    
    // Formate Issue
    NSArray* classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSDictionary* options = [NSDictionary dictionary];
    NSArray* copiedItems = [pasteboard readObjectsForClasses:classes options:options];
    if (copiedItems != nil) {
        // Regular Expression
        NSString* copiedString = copiedItems.firstObject;
        NSString* pattern = @"^\\S* ";
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSString* formatedString = [regex stringByReplacingMatchesInString:copiedString options:0 range:NSMakeRange(0, copiedString.length) withTemplate:@""];
        
        // Copy formatedString to the Pasteboard
        NSArray* objectsToCopy = @[formatedString];
        [pasteboard clearContents];
        [pasteboard writeObjects:objectsToCopy];
        
        return formatedString;
    }
    
    return nil;
}

- (void)doMenuAction
{
    [self formattedIssueString];
}

- (void)toggleStripQuotationMarks:(NSMenuItem *)sender
{
    _stripInsideQuotationMarks = !_stripInsideQuotationMarks;
    [sender setState:(_stripInsideQuotationMarks) ? NSOnState : NSOffState];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
