//
//  HTYCopyIssue.h
//  HTYCopyIssue
//
//  Created by  on 2/2/15.
//  Copyright (c) 2015 Hanton. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <objc/objc-runtime.h>

@interface HTYCopyIssue : NSObject <NSMenuDelegate, NSWindowDelegate>

@property (strong, nonatomic) NSMenu *contextMenu;
@property (strong, nonatomic) NSMenu *issueNavigatorContextMenu;

+ (instancetype)sharedPlugin;

@end