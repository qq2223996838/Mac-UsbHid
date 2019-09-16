//
//  AppDelegate.m
//  MacOSHid
//
//  Created by Smile on 2019/3/18.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) RootViewController *rootVC;

@end

@implementation AppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
//    [self.window orderOut:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self.window center];
    
    _rootVC = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    _rootVC.mainWindow = self.window;
    [self.window.contentView addSubview:_rootVC.view];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
