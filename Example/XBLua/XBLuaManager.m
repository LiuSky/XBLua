//
//  XBLuaManager.m
//  Created on 2023/8/1
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2023 LMKJ. All rights reserved.
//  @author 刘小彬(liuxiaomike@gmail.com)   
//

#import "XBLuaManager.h"
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"


/// lua分配内存
/// - Parameters:
///   - ud: user data 用户数据
///   - ptr: ptr是指向内存块的指针
///   - osize: 原始内存块的大小
///   - nsize: 新的内存块的大小
static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
    (void)ud;
    (void)osize;
    if (nsize == 0) {
        free(ptr);
        return NULL;
    } else {
        return realloc(ptr, nsize);
    }
}


@interface XBLuaManager()
@property(nonatomic, assign) lua_State *l;
@end

@implementation XBLuaManager

-(instancetype)init {
    self = [super init];
    if (self) {
        [self registeLibs];
    }
    return self;
}

#pragma mark - 注册libs
-(void)registeLibs {
    self.l = lua_newstate(l_alloc, (__bridge void *)(self));
    luaL_openlibs(self.l);
}

#pragma mark - 运行脚本
-(void)runLuaScript:(NSString *)script {
    lua_State* L = self.l;
    const char *luaScript = [script UTF8String];
    if (luaL_loadbuffer(L, luaScript, strlen(luaScript), "lua_script") == LUA_OK) {
        if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
            const char *errorMsg = lua_tostring(L, -1);
            NSLog(@"Lua Error: %s", errorMsg);
        }
    } else {
        const char *errorMsg = lua_tostring(L, -1);
        NSLog(@"Lua Error: %s", errorMsg);
    }
    lua_close(L);
}
@end
