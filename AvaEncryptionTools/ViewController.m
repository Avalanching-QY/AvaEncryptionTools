//
//  ViewController.m
//  AvaEncryptionTools
//
//  Created by Avalanching on 2019/6/26.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "ViewController.h"
#import "AvaEncryption.h"

@interface ViewController ()

@property (strong) IBOutlet NSTextField *inputTextField;

@property (strong) IBOutlet NSTextField *outputTextField;

@property (strong) IBOutlet NSTextField *keyTextField;

@property (strong) IBOutlet NSTextField *viTextField;

@property (strong) IBOutlet NSTextField *setTextField;

@property (strong) IBOutlet NSButton *encryption;

@property (strong) IBOutlet NSButton *dencyption;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = [[AvaEncryption singletons] getConfigure];
    if (dict) {
        if (dict[@"key"]) {
            self.keyTextField.stringValue =  dict[@"key"];
        }
        
        if (dict[@"input"]) {
            self.inputTextField.stringValue =  dict[@"input"];
        }
        
        if (dict[@"output"]) {
            self.outputTextField.stringValue =  dict[@"output"];
        }
        
        if (dict[@"vi"]) {
            self.viTextField.stringValue =  dict[@"vi"];
        }
        
        if (dict[@"set"]) {
            self.setTextField.stringValue =  dict[@"set"];
        }
    }
}

// 加密
- (IBAction)encryptionAction:(NSButton *)sender {
    NSArray *set = @[];
    if (self.setTextField.stringValue.length > 0) {
        set = [self.setTextField.stringValue componentsSeparatedByString:@" "];
    }
    [self.dencyption setEnabled:NO];
    [self.encryption setEnabled:NO];
    __weak typeof(self) weakSelf = self;
    if (![[AvaEncryption singletons] encryptionWithInputPath:self.inputTextField.stringValue outputPath:self.outputTextField.stringValue key:self.keyTextField.stringValue vi:self.viTextField.stringValue set:set complete:^(AvaEncryption * _Nonnull object) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.dencyption setEnabled:YES];
        [strongSelf.encryption setEnabled:YES];

    }]) {
        [self.dencyption setEnabled:YES];
        [self.encryption setEnabled:YES];
    }
    
}

// 解密
- (IBAction)dencrytionAction:(NSButton *)sender {
    
    NSArray *set = @[];
    if (self.setTextField.stringValue.length > 0) {
        set = [self.setTextField.stringValue componentsSeparatedByString:@" "];
    }
    [self.dencyption setEnabled:NO];
    [self.encryption setEnabled:NO];
    __weak typeof(self) weakSelf = self;
    if (![[AvaEncryption singletons] dencryptionWithInputPath:self.inputTextField.stringValue outputPath:self.outputTextField.stringValue key:self.keyTextField.stringValue vi:self.viTextField.stringValue set:set complete:^(AvaEncryption * _Nonnull object) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.dencyption setEnabled:YES];
        [strongSelf.encryption setEnabled:YES];
    }]) {
        [self.dencyption setEnabled:YES];
        [self.encryption setEnabled:YES];
    }
}

@end
