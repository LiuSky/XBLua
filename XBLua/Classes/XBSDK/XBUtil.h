//
//  XBUtil.h
//  XBLua
//
//  Created by 327847390@q.com on 08/01/2023.
//  Copyright (c) 2023 327847390@q.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// MARK - 工具类
@interface XBUtil : NSObject

/// 打印输出日志
/// - Parameter format: 参数
void XBLog(NSString* format, ... );

/// 打印错误日志
/// - Parameter format: 参数
void XBError(NSString* format, ... );

@end


