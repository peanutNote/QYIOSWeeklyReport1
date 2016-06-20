//
//  ViewController.m
//  QYIOSWeeklyReport1
//
//  Created by qianye on 16/6/17.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define UIScreenWidth   [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, UIScreenWidth, UIScreenHeight - 20) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"I'm textLabe";
    cell.detailTextLabel.text = @"I'm detailTextLabel";
    if (indexPath.row == 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 100, 0, 100);
        
    } else if (indexPath.row == 2) {
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, UIScreenWidth - 15);
    } else if (indexPath.row == 3) {
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        cell.separatorInset = UIEdgeInsetsZero;
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"I'm spectator";
        cell.detailTextLabel.text = @"";
    } else if (indexPath.row == 5) {
        cell.textLabel.text = @"Click Me For 'Touch ID'";
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error;
        BOOL isTouchIdAvilabel = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        if (isTouchIdAvilabel) {
            NSLog(@"恭喜，Touch ID可以使用！");
            
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"需要验证您的指纹来确认您的身份信息" reply:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    NSLog(@"恭喜，您通过了Touch ID指纹验证！");
                    
                } else {
                    NSLog(@"抱歉，您未能通过Touch ID指纹验证！\n%@", error);
                }
            }];
            
        } else {
            NSLog(@"抱歉，Touch ID不可以使用！\n%@", error);
        }
    }
}


/**
 *  各种不可用情况输出的error信息：
 1. 真机上运行如果不可用结果为：
 抱歉，Touch ID不可以使用！
 Optional(Error Domain=com.apple.LocalAuthentication Code=-6 "Biometry is not available on this device." UserInfo=0x15ec5a00 {NSLocalizedDescription=Biometry is not available on this device.})
 
 2. 在模拟器上的运行结果为：
 抱歉，Touch ID不可以使用！
 Optional(Error Domain=com.apple.LocalAuthentication Code=-1000 "Simulator is not supported." UserInfo=0x7ffe604b0790 {NSLocalizedDescription=Simulator is not supported.})
 
 3. 连续三次指纹识别错误的运行结果：
 抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-1 "Aplication retry limit exceeded." UserInfo=0x1740797c0 {NSLocalizedDescription=Aplication retry limit exceeded.}
 
 4. Touch ID功能被锁定，下一次需要输入系统密码时的运行结果：
 抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-1 "Biometry is locked out." UserInfo=0x17407dc00 {NSLocalizedDescription=Biometry is locked out.}
 
 5. 用户在Touch ID对话框中点击了取消按钮：
 抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-2 "Canceled by user." UserInfo=0x17006c780 {NSLocalizedDescription=Canceled by user.}
 
 6. 在Touch ID对话框显示过程中，背系统取消，例如按下电源键：
 抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-4 "UI canceled by system." UserInfo=0x170065900 {NSLocalizedDescription=UI canceled by system.}
 
 7. 用户在Touch ID对话框中点击输入密码按钮：
 抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-3 "Fallback authentication mechanism selected." UserInfo=0x17407e040 {NSLocalizedDescription=Fallback authentication mechanism selected.}
 */

@end
