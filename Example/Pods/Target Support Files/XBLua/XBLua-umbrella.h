#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XBDebugConnection.h"
#import "lapi.h"
#import "lauxlib.h"
#import "lcode.h"
#import "lctype.h"
#import "ldebug.h"
#import "ldo.h"
#import "lfunc.h"
#import "lgc.h"
#import "ljumptab.h"
#import "llex.h"
#import "llimits.h"
#import "lmem.h"
#import "lobject.h"
#import "lopcodes.h"
#import "lopnames.h"
#import "lparser.h"
#import "lprefix.h"
#import "lstate.h"
#import "lstring.h"
#import "ltable.h"
#import "ltm.h"
#import "lua.h"
#import "luaconf.h"
#import "lualib.h"
#import "lundump.h"
#import "lvm.h"
#import "lzio.h"
#import "XBUtil.h"

FOUNDATION_EXPORT double XBLuaVersionNumber;
FOUNDATION_EXPORT const unsigned char XBLuaVersionString[];

