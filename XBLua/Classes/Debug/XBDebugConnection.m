//
//  XBDebugConnection.m
//  XBLua
//
//  Created by 327847390@q.com on 08/01/2023.
//  Copyright (c) 2023 327847390@q.com. All rights reserved.
//

#import "XBDebugConnection.h"
#import <CFNetwork/CFNetwork.h>
#import <TargetConditionals.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>
#import "XBUtil.h"

#ifdef DEBUG

#define XBReleaseAndNull( a ) if(a) { CFRelease(a); a = NULL; }
#define SOCKET_ERROR        (-1)
#define SOCKET_CONNECTINTG  (0)
#define SOCKET_SUCCESS      (1)

// 调试器的默认IP和端口
static NSString* SERVER_IP = @"192.168.103.27";
static int SERVER_PORT = 8888;

@interface XBDebugConnection ()
@property(nonatomic,strong) NSThread* myThread;
@property(nonatomic,assign) BOOL canWrite;
@property(nonatomic,assign) NSInteger state;
@property(atomic,strong) NSMutableArray* sendArray;
@end

@implementation XBDebugConnection {
    CFSocketRef _socket;
}

#pragma mark - 初始化
-(instancetype)init {
    self = [super init];
    if (self) {
        static int index = 0;
        self.myThread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:nil];
        self.myThread.name = [NSString stringWithFormat:@"LuaView.Debuger.%d",index];
        self.sendArray = [[NSMutableArray alloc] init];
        self.receivedArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - 是否连接
-(BOOL)isConnect {
    return self.state > 0;
}

#pragma mark - 等待连接结束
-(NSInteger)waitUntilConnectionEnd {
    for(;self.state==SOCKET_CONNECTINTG;) {
        [NSThread sleepForTimeInterval:0.01];
    }
    return self.state;
}

#pragma mark - 开始线程
-(void)start {
    [self.myThread start];
}


#pragma mark - 设置debug地址
+(void)setDebugerIP:(NSString*) ip port:(int) port{
    SERVER_IP = ip;
    SERVER_PORT = port;
}

#pragma mark - 运行
-(void)run:(id)obj {
    @autoreleasepool {
        
        [self connect:SERVER_IP port:SERVER_PORT];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

#pragma mark - 获取cmd
-(NSString*)getCmd {
    NSString* cmd = self.receivedArray.lastObject;
    if(cmd) {
        [self.receivedArray removeLastObject];
    }
    return cmd;
}

#pragma mark - 发送cmd指令
-(void)sendCmd:(NSString*)cmdName info:(NSString*)info {
    [self sendCmd:cmdName fileName:nil info:info];
}

-(void)sendCmd:(NSString*)cmdName info:(NSString*)info args:(NSDictionary*)args {
    [self sendCmd:cmdName fileName:nil info:info args:args];
}

-(void)sendCmd:(NSString*)cmdName fileName:(NSString*)fileName info:(NSString*)info {
    [self sendCmd:cmdName fileName:fileName info:info args:nil];
}

-(void)sendCmd:(NSString*)cmdName fileName:(NSString*)fileName info:(NSString*)info args:(NSDictionary*)args {
    NSMutableString* buffer = [[NSMutableString alloc] init];
    if (cmdName) {
        [buffer appendFormat:@"Cmd-Name:%@\n",cmdName];
    }
    if (fileName) {
        [buffer appendFormat:@"File-Name:%@\n",fileName];
    }
    NSArray* keys = args.allKeys;
    for(int i=0; i<keys.count; i++) {
        NSString* key = keys[i];
        NSString* value = args[key];
        if(key && value) {
            [buffer appendFormat:@"%@:%@\n",key, value];
        }
    }
    [buffer appendString:@"\n"];
    if (info) {
        [buffer appendFormat:@"%@",info];
    }
    [self sendString:buffer];
}

#pragma mark - 连接socket
-(void)connect:(NSString*) ip port:(NSUInteger)port
{
    //////////////////////创建套接字//////////////
    CFSocketContext socketConent = {0,NULL,NULL,NULL,NULL};
    socketConent.info = (__bridge void *)(self);
    _socket = CFSocketCreate(
                             kCFAllocatorDefault,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketConnectCallBack|kCFSocketReadCallBack|kCFSocketWriteCallBack,     // 类型，表示连接时调用
                             ServerConnectCallBack,    // 调用的函数
                             &socketConent );
    
    ////////////////////////////设置地址///////////////////
    struct   sockaddr_in  addr = {0};
    memset(&addr , 0,sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);// 端口
    addr.sin_addr.s_addr = inet_addr([ip  UTF8String]);
    
    CFDataRef address = CFDataCreate(
                                     kCFAllocatorDefault,
                                     (UInt8*)&addr,
                                     sizeof(addr));
    
    /////////////////////////////执行连接/////////////////////
    CFSocketConnectToAddress(_socket,address,-1);
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();   // 获取当前运行循环
    CFRunLoopSourceRef  source = CFSocketCreateRunLoopSource(kCFAllocatorDefault,_socket,0);//定义循环对象
    CFRunLoopAddSource(cfrl,source,kCFRunLoopCommonModes); //将循环对象加入当前循环中
    XBReleaseAndNull(source);
    XBReleaseAndNull(address);
}

#pragma mark - 关闭连接
-(void)close {
    self.canWrite = FALSE;
    self.state = -1;
    
    if (_socket != NULL)
    {
        CFSocketInvalidate(_socket);
        XBReleaseAndNull(_socket);
    }
    
    if( !self.myThread.isCancelled) {
        [self.myThread cancel];
    }
}

static void ServerConnectCallBack(CFSocketRef socket,
                                  CFSocketCallBackType type,
                                  CFDataRef address,
                                  const void *data,
                                  void* info) {
    
    XBDebugConnection* debuger = (__bridge XBDebugConnection *)(info);
    switch ( type ){
        case kCFSocketReadCallBack: {
            NSString* cmd = readString(socket);
            if (cmd && cmd.length>0) {
                XBLog(@"[调试日志][收到指令] %@ ", cmd);
                [debuger.receivedArray insertObject:cmd atIndex:0];
            }
            // 关闭掉socket
            if (cmd.length<=0) {
                [debuger close];
                [debuger.receivedArray insertObject:@"close" atIndex:0];
                [debuger.receivedArray insertObject:@"close" atIndex:0];
            } else {
                //[debuger.lview  callLuaToExecuteServerCmd];
            }
            break;
        }
        case kCFSocketWriteCallBack: {
            debuger.canWrite = YES;
            [debuger sendOneData];
            break;
        }
        case kCFSocketConnectCallBack:
            if (data) {
                XBLog(@"Debuger Socket Connect failed" );
                debuger.state = SOCKET_ERROR;
            } else {
                XBLog(@"Debuger Socket connect Success");
                debuger.state = SOCKET_SUCCESS;
            }
            break;
        default: {
            XBLog(@"connect type %d", (int)type );
            break;
        }
    }
}


-(void)sendOneData {
    NSData* data = self.sendArray.lastObject;
    if(self.canWrite && data) {
        [self.sendArray removeLastObject];
        if(data) {
            NSInteger sendLength = send(CFSocketGetNative(_socket), data.bytes, data.length, 0);
            if(sendLength!=data.length) {
                XBError(@"Debuger socket Send length Error : %d != %d", (int)sendLength, (int)data.length);
            }
        }
    }
}

///////////////////监听来自服务器的信息///////////////////


static NSString* readString(CFSocketRef socket)
{
    unsigned char head[4] = {0};
    NSUInteger readLength0 = 0;
    if( recv( CFSocketGetNative(socket), head, sizeof(head), 0 )==sizeof(head) ) {
        NSUInteger d0 = head[0];
        NSUInteger d1 = head[1];
        NSUInteger d2 = head[2];
        NSUInteger d3 = head[3];
        readLength0 = (d0<<24) + (d1<<16) + (d2<<8) + d3;
    }
    
    unsigned char buffer[512] = {0};
    NSUInteger readLen = readLength0;
    NSMutableData* data = [[NSMutableData alloc] init];
    for(;readLen>0;){
        NSUInteger bufferLen = readLen>=sizeof(buffer)?sizeof(buffer):readLen;
        NSUInteger recvLen = recv( CFSocketGetNative(socket), buffer, bufferLen, 0 );
        if ( recvLen>0 ) {
            [data appendBytes:buffer length:recvLen];
            readLen -= recvLen;
        } else {
            break;
        }
    }
    NSString* ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

/////////////////////////发送信息给服务器////////////////////////
- (void)sendString:(NSString *)string
{
    if(self.canWrite) {
        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger len = data.length;
        NSMutableData* buffer = [[NSMutableData alloc] init];
        unsigned char head[4] = {0};
        head[0] = (len>>24);
        head[1] = (len>>16);
        head[2] = (len>>8);
        head[3] = (len);
        [buffer appendBytes:head length:4];
        [buffer appendData:data];
        
        [self.sendArray insertObject:buffer atIndex:0];
        
        [self sendOneData];
    }
}


+ (id)jsonObject:(NSString *)s {
    NSData* data = [s dataUsingEncoding:NSUTF8StringEncoding];
    @try {
        NSError *error = nil;
        NSJSONReadingOptions options = 0;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
        if (error) {
            return nil;
        }
        return obj;
    } @catch (NSException *exception) {
        return nil;
    }
}

+(void)openUrlServer:(void(^)(NSDictionary* args) )callback {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        XBDebugConnection* debugConnection = [[XBDebugConnection alloc] init];
        if( [debugConnection waitUntilConnectionEnd]>0 ) {
            [debugConnection sendCmd:@"debugger" info:@"true"];
            for(;;) {
                NSString* cmd = [debugConnection getCmd];
                if(cmd) {
                    NSDictionary* dic = [XBDebugConnection jsonObject:cmd];
                    if( dic && [dic isKindOfClass:[NSDictionary class]]) {
                        //通知主线程刷新
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //回调或者说是通知主线程刷新，
                            if( callback ) {
                                callback(dic);
                            }
                        });
                    }
                    break;
                } else {
                    [NSThread sleepForTimeInterval:0.1];
                }
            }
            [debugConnection close];
        } else {
            [debugConnection close];
        }
    });
}


#pragma mark - 释放
-(void)dealloc {
    [self close];
}
@end

#endif
