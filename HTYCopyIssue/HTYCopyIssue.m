//
//  HTYCopyIssue.m
//  HTYCopyIssue
//
//  Created by  on 2/2/15.
//  Copyright (c) 2015 Hanton. All rights reserved.
//

#import "HTYCopyIssue.h"

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
