//
//  XBLuaManager.h
//  Created on 2023/8/1
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2023 LMKJ. All rights reserved.
//  @author 刘小彬(liuxiaomike@gmail.com)   
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XBLuaManager : NSObject

/// 运行脚本
/// - Parameter script: script
- (void)runLuaScript:(NSString *)script;
@end

NS_ASSUME_NONNULL_END
