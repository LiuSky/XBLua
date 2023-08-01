//
//  XBDebugConnection.h
//  XBLua
//
//  Created by 327847390@q.com on 08/01/2023.
//  Copyright (c) 2023 327847390@q.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

@interface XBDebugConnection : NSObject

@property (nonatomic,assign) BOOL printToServer; //打印到服务端
@property (atomic,strong) NSMutableArray* receivedArray; //收到的数据数组

/// 开始
-(void)start;

/// 是否连接
-(BOOL)isConnect;

/// 关闭连接
-(void)close;

/// 获取cmd
-(NSString*)getCmd;

/// 等待连接结束
-(NSInteger)waitUntilConnectionEnd;


/// 发送cmd指令
/// - Parameters:
///   - cmdName: cmdName
///   - info: info
-(void)sendCmd:(NSString*)cmdName info:(NSString*)info;


/// 发送cmd指令
/// - Parameters:
///   - cmdName: cmdName
///   - info: info
///   - args: args
-(void)sendCmd:(NSString*)cmdName info:(NSString*)info args:(NSDictionary*)args;


/// 发送cmd指令
/// - Parameters:
///   - cmdName: cmdName
///   - fileName: fileName
///   - info: info
-(void)sendCmd:(NSString*)cmdName fileName:(NSString*)fileName info:(NSString*)info;

/// 发送cmd指令
/// - Parameters:
///   - cmdName: cmdName
///   - fileName: fileName
///   - info: info
///   - args: args
-(void)sendCmd:(NSString*)cmdName fileName:(NSString*)fileName info:(NSString*)info args:(NSDictionary*)args;

/// 设置调试器的IP和端口, 用于远程调试
/// - Parameters:
///   - ip: ip
///   - port: 端口
+(void)setDebugerIP:(NSString*) ip port:(int) port;

/// 打开服务地址
/// - Parameter callback: callback
+(void)openUrlServer:( void(^)(NSDictionary* args) ) callback;

@end

//---------------------------------------------------------
#endif
