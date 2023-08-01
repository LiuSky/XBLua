//
//  XBViewController.m
//  XBLua
//
//  Created by 327847390@q.com on 08/01/2023.
//  Copyright (c) 2023 327847390@q.com. All rights reserved.
//

#import "XBViewController.h"
#import "XBLuaManager.h"
#import <XBDebugConnection.h>

@interface XBViewController ()
@property(nonatomic, strong) XBDebugConnection *debugConnection;
@property(nonatomic, strong) XBLuaManager *luaManager;

@property(nonatomic, strong) UIButton *debugButton; //debug按钮
@end


@implementation XBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"lua例子";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.debugButton];
    
    NSString *luaScript = @"print('Hello, Lua!')";
    [self.luaManager runLuaScript:luaScript];
    [self.debugConnection start];
}

#pragma mark - 打印调试
-(void)eventForDebug {
    [self.debugConnection sendCmd:@"创建一个标签" info:@""];
}


#pragma mark - lazy init
-(XBDebugConnection *)debugConnection {
    if (!_debugConnection) {
        _debugConnection = [[XBDebugConnection alloc] init];
    }
    return _debugConnection;
}
-(XBLuaManager *)luaManager {
    if (!_luaManager) {
        _luaManager = [[XBLuaManager alloc] init];
    }
    return _luaManager;
}

-(UIButton *)debugButton {
    if (!_debugButton) {
        _debugButton = [UIButton buttonWithType: UIButtonTypeCustom];
        _debugButton.backgroundColor = [UIColor redColor];
        [_debugButton setTitle:@"调试" forState: UIControlStateNormal];
        [_debugButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_debugButton addTarget:self action:@selector(eventForDebug) forControlEvents:UIControlEventTouchUpInside];
        _debugButton.frame = CGRectMake(0, 0, 100, 34);
    }
    return _debugButton;
}
@end
