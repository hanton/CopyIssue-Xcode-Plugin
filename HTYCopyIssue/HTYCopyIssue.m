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
    // Add the new "Copy Issue Subtitle" menu
    NSMenuItem* menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
      NSMenuItem* actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy Issue" action:@selector(doMenuAction) keyEquivalent:@"V"];
      [actionMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSCommandKeyMask];
      [actionMenuItem setTarget:self];
      [[menuItem submenu] insertItem:actionMenuItem atIndex:5];
      
      Class textViewClass = NSClassFromString(@"DVTSourceTextView");
      NSError *error = nil;
      [textViewClass aspect_hookSelector:@selector(setDelegate:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
        NSLog(@"Class: %@/nInstance: %@\nArguments: %@", [aspectInfo.instance class], aspectInfo.instance, aspectInfo.arguments);
      } error:&error];
      
      Class editorClass = NSClassFromString(@"IDESourceCodeEditor");
      SEL delegateSelector = NSSelectorFromString(@"setupTextViewContextMenuWithMenu:");
      [editorClass aspect_hookSelector:delegateSelector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        
        NSMenu *contextMenu = [aspectInfo.arguments firstObject];
        NSMenuItem *showIssueItem = [contextMenu itemWithTitle:@"Show Issue"];
        if (!showIssueItem) {
          return;
        }
        
        if (![showIssueItem isEnabled]) {
          NSLog(@"%@ is not enabled. Won't add custom item", showIssueItem);
          return;
        }
        
        NSLog(@"%@ is not enabled. Won't add custom item", showIssueItem);
        
        
        NSMenuItem* foobarItem = [[NSMenuItem alloc] initWithTitle:@"Foo Bar" action:@selector(doMenuAction) keyEquivalent:@"V"];
        [foobarItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSCommandKeyMask];
        [foobarItem setTarget:self];
        [contextMenu insertItem:foobarItem atIndex:5];
      } error:&error];
      
      if (error) {
        NSLog(@"*** ERROR: %@", error);
      }
      
      SEL guttterContextMenuDelegate = NSSelectorFromString(@"setupGutterContextMenuWithMenu:");
      [editorClass aspect_hookSelector:guttterContextMenuDelegate withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        NSMenuItem* foobarItem = [[NSMenuItem alloc] initWithTitle:@"Foo Bar" action:@selector(doMenuAction) keyEquivalent:@"V"];
        [foobarItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSCommandKeyMask];
        [foobarItem setTarget:self];
        NSMenu *contextMenu = [aspectInfo.arguments firstObject];
        [contextMenu insertItem:foobarItem atIndex:5];
      } error:&error];

      if (error) {
        NSLog(@"*** ERROR: %@", error);
      }
    }
  }
  return self;
}

// Sample Action, for menu item:
- (void)doMenuAction
{
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
  }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
