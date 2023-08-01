//
//  XBUtil.m
//  XBLua
//
//  Created by 327847390@q.com on 08/01/2023.
//  Copyright (c) 2023 327847390@q.com. All rights reserved.
//

#import "XBUtil.h"

@implementation XBUtil



#pragma mark - 打印日志
void XBLog( NSString* format, ... ) {
#ifdef DEBUG
    va_list params; //定义一个指向个数可变的参数列表指针;
    va_start(params,format);//va_start 得到第一个可变参数地址,
    NSString* s = [[NSString alloc] initWithFormat:format arguments:params];
    NSLog(@"[XBLua]%@", s);
    va_end(params);
#endif
}

#pragma mark - 打印错误日志
void XBError( NSString* format, ... ) {
#ifdef DEBUG
    va_list params; //定义一个指向个数可变的参数列表指针;
    va_start(params,format);//va_start 得到第一个可变参数地址,
    NSString* s = [[NSString alloc] initWithFormat:format arguments:params];
    NSLog(@"[XBLua][error]%@", s);
    va_end(params);
#endif
}

@end
