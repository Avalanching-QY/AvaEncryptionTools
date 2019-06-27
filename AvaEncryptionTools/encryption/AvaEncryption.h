//
//  AvaEncryption.h
//  AvaEncryptionTools
//
//  Created by Avalanching on 2019/6/26.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AvaEncryption : NSObject

/**
 @method singletons
 @abstrac 单例
 @discussion 获取一个单例对象
 @result instancetype
 */
+ (instancetype)singletons;

/**
 @method encryptionWithInputPath:outputPath:key:vi:set:
 @abstrac 加密
 @discussion 加密文件
 @param inputPath 输入路径
 @param outputPath 输出路径
 @param key key
 @param vi 偏移量
 @param set 需要加密的文件后缀
 @param complete 回调
 @result BOOL 是否开始
 */
- (BOOL)encryptionWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath key:(NSString *)key vi:(NSString *)vi set:(NSArray<NSString *> *)set complete:(void(^)(AvaEncryption *object))complete;

/**
 @method dencryptionWithInputPath:outputPath:key:vi:set:
 @abstrac 解密
 @discussion 解密文件
 @param inputPath 输入路径
 @param outputPath 输出路径
 @param key key
 @param vi 偏移量
 @param set 需要加密的文件后缀
 @param complete 回调
 @result BOOL 是否开始
 */
- (BOOL)dencryptionWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath key:(NSString *)key vi:(NSString *)vi set:(NSArray<NSString *> *)set complete:(void(^)(AvaEncryption *object))complete;

/**
 @method getConfigure
 @abstrac 获取上次填写的配置
 @discussion 保存了上次输入项
 @result NSDictionary
 */
- (NSDictionary *)getConfigure;

@end

NS_ASSUME_NONNULL_END
