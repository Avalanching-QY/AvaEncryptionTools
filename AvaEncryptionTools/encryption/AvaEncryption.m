//
//  AvaEncryption.m
//  AvaEncryptionTools
//
//  Created by Avalanching on 2019/6/26.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "AvaEncryption.h"
#import "EncryptionTools.h"

static AvaEncryption *singleton = nil;

@interface AvaEncryption ()

@property (nonatomic, copy) NSString *input;

@property (nonatomic, copy) NSString *output;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *vi;

@property (nonatomic, copy) NSArray<NSString *> *set;

@property (nonatomic, assign) BOOL flag;

@property (nonatomic, copy) void(^complete)(AvaEncryption *object);

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSString *sign;

@end

@implementation AvaEncryption

+ (instancetype)singletons {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[AvaEncryption alloc] init];
    });
    
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - public


- (BOOL)encryptionWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath key:(NSString *)key vi:(NSString *)vi set:(NSArray<NSString *> *)set complete:(void(^)(AvaEncryption *object))complete; {
    
    if ((inputPath && set && vi && key) &&
        (inputPath.length > 0 && vi.length > 0 && key.length > 0)
        ) {
        self.input = inputPath;
        self.output = outputPath;
        self.key = key;
        self.set = set;
        self.vi = vi;
        
        self.flag = YES;
        self.complete = complete;
        [self startOutputDir];
//        dispatch_queue_t queue = dispatch_queue_create("encryption", NULL);
//        __weak typeof(self) weakSelf = self;
//        dispatch_async(queue, ^{
//            __weak typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf startOutputDir];
//        });

        
        return YES;
    }
    
    return NO;
}

- (BOOL)dencryptionWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath key:(NSString *)key vi:(NSString *)vi set:(NSArray<NSString *> *)set complete:(void(^)(AvaEncryption *object))complete {
    if ((inputPath && set && vi && key) &&
       (inputPath.length > 0 && vi.length > 0 && key.length > 0)
       ) {
        self.input = inputPath;
        self.output = outputPath;
        self.key = key;
        self.set = set;
        self.vi = vi;
        self.flag = NO;
        self.complete = complete;
        [self startOutputDir];
//        dispatch_queue_t queue = dispatch_queue_create("dencryption", NULL);
//        __weak typeof(self) weakSelf = self;
//        dispatch_async(queue, ^{
//            __weak typeof(weakSelf) strongSelf = weakSelf;
//            [strongSelf startOutputDir];
//        });
//
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)getConfigure {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AvaEncryption_KEY"];
}

#pragma mark - private method

- (void)setSign {
    NSDate *date = [NSDate date];
    self.sign = [self.dateFormatter stringFromDate:date];
}

- (void)startOutputDir {
    
    [self setSign];
    
    [self saveConfigure];
    
//    self.output = [NSHomeDirectory() stringByAppendingPathComponent:@"/Cache/"];
    // 创建output
    if (!self.output || self.output.length == 0) {
        // 创建输出路径
        NSString *inputName = [self.input componentsSeparatedByString:@"/"].lastObject;
        
        self.output = [self.input stringByReplacingOccurrencesOfString:inputName withString:[NSString stringWithFormat:@"avalanching_outinput_%@", self.sign]];
    } else {
        if ([self.output hasSuffix:@"/"]) {
            self.output = [self.output stringByAppendingString:[NSString stringWithFormat:@"avalanching_outinput_%@", self.sign]];
        } else {
            self.output = [self.output stringByAppendingString:[NSString stringWithFormat:@"/avalanching_outinput_%@", self.sign]];
        }
    }
    
    BOOL flag = [self.fileManager fileExistsAtPath:self.output];
    if (flag) {
        // 删除
        NSError *error;
        [self.fileManager removeItemAtPath:self.output error:&error];
        if (error) {
            [self log:@"发现同名输出文件夹，删除失败了" error:[NSError errorWithDomain:@"发现同名输出文件夹，删除失败了" code:11 userInfo:nil]];
        }
    }
    
    NSError *error;
    [self.fileManager copyItemAtPath:self.input toPath:self.output error:&error];
    if (error) {
        [self log:@"移动文件夹错误" error:error];
        if (_complete) {
            self.complete(self);
        }
        return;
    }
    
    NSArray *pathSet = [self getFileSubPathWithPath:self.output];
    [self handle:pathSet];
}

- (void)handle:(NSArray<NSString *> *)pathSet {
    if (pathSet.count == 0 || !pathSet) {
        [self log:@"读取一个空的路径集合" error:[NSError errorWithDomain:@"读取一个空的路径集合" code:12 userInfo:nil]];
        if (_complete) {
            self.complete(self);
        }
        return;
    }
    
    for (NSString *path in pathSet) {
        if (self.set.count > 0) {
            for (NSString *suffix in self.set) {
                if ([path hasSuffix:suffix]) {
                    [self dencryptionToolsWithContentPath:path];
                }
                break;
            }
        } else {
            [self dencryptionToolsWithContentPath:path];
        }
    }
    
    if (_complete) {
        self.complete(self);
    }
    
}

- (BOOL)dencryptionToolsWithContentPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (!error && content) {
            EncryptionTools *encryptionTools = [EncryptionTools sharedEncryptionTools];
            NSData *data = [self.vi dataUsingEncoding:NSUTF8StringEncoding];
            NSString *tempContent = nil;
            if (self.flag) {
                tempContent = [encryptionTools encryptString:content keyString:self.key iv:data];
            } else {
                tempContent = [encryptionTools decryptString:content keyString:self.key iv:data];
            }
            
            if (tempContent) {
                error = nil;
                [tempContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
                if (!error) {
                    return YES;
                } else {
                    [self log:path error:error];
                }
            } else {
                if (self.flag) {
                    [self log:path error:[NSError errorWithDomain:@"加密失败了" code:13 userInfo:nil]];
                } else {
                    [self log:path error:[NSError errorWithDomain:@"解密失败了" code:14 userInfo:nil]];
                }
            }
        }
    }
    return NO;
}

- (void)saveConfigure {
    NSMutableDictionary *dict = @{}.mutableCopy;
    if (self.key) {
        [dict setObject:self.key forKey:@"key"];
    }
    
    if (self.input) {
        [dict setObject:self.input forKey:@"input"];
    }
    
    if (self.output) {
        [dict setObject:self.output forKey:@"output"];
    }

    if (self.vi) {
        [dict setObject:self.vi forKey:@"vi"];
    }
    
    if (self.set && self.set.count > 0) {
        NSString *content = [self.set componentsJoinedByString:@" "];
        [dict setObject:content forKey:@"set"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"AvaEncryption_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)log:(NSString *)content error:(NSError *)error {
    
    NSString *logPath = [NSString stringWithFormat:@"%@/%@_log.txt", self.output, self.sign];
    
   
    NSString *words = [NSString stringWithFormat:@"[content]:%@, [error]:%@\n", content, error.description];
    
    if (![self.fileManager fileExistsAtPath:logPath]) {
        // 创建文件
        [self.fileManager createFileAtPath:logPath contents:nil attributes:nil];
    }
    NSError *errorW;
    
    NSString *contentW = [[NSString alloc] initWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:&errorW];
    
    if (!errorW) {
        if (content.length != 0) {
            words = [NSString stringWithFormat:@"%@\n%@", contentW, words];
        } else {
            NSLog(@"[%d][%s]:%@", __LINE__, __func__ ,errorW);
        }
    }
    
    errorW = nil;
    
    [words writeToFile:logPath atomically:NO encoding:NSUTF8StringEncoding error:&errorW];
    if (errorW) {
        NSLog(@"[%d][%s]:%@", __LINE__, __func__ ,errorW);
    }
    
}

- (NSArray<NSString *> *)getFileSubPathWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    
    NSMutableArray *pathSet = @[].mutableCopy;
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    
    for (NSString *tmp in enumerator.allObjects) {
        BOOL flag = NO;
        NSString *completePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@", tmp]];
        BOOL isExists = [fileManager fileExistsAtPath:completePath isDirectory:&flag];
        
        if (!flag && isExists) {
            [pathSet addObject:completePath];
        }
    }
    
    return pathSet;
}


#pragma mark - lazy load

- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}


- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}


@end
