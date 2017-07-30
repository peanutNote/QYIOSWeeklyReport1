iOS 开发周报
===
2016年06月13-17日
___

1.有关UITableViewCell分割线样式(这里我们只对默认separatorStyle进行讨论)
demo中将展现四个cell，为了进行演示现做如下处理

* 第一个cell的分割线为默认状态
* 第二个cell为一个自定义的样式`UIEdgeInsetsMake(0, 100, 0, 100)` 
* 第三个为隐藏的分割线
* 第四个为与屏幕边没有间距的分割线样式。  
* 特殊点说明
	* 自定义分割线中：cell的`textLabel`(`detailTextLabel`不会有这种情况)会根据分割线的位移而变化并保持与分割线左侧对齐 
	* 隐藏分割线中有两种方式：
		* 第一种是设置分割线的左边距屏幕边缘为屏宽减去15(iOS中默认的margin就是15)，右边距屏幕边为15也就是`UIEdgeInsetsMake(0, UIScreenWidth - 15, 0, 15)`。这种方式可以起到隐藏分割线的效果但是`textLabel`的左侧布局会变到距屏幕左侧15。
		* 第二种与第一种相反`UIEdgeInsetsMake(0, 15, 0, UIScreenWidth - 15)`，这种隐藏分割线的方法不会造成第一种的问题。在开发中如果没有使用cell自带的`textLabel`这两种方法都可以使用


> * iOS7以后UITableViewCell的分割线默认距屏幕左边框15，在iOS7上我们可以通过tableView的`separatorInset`或者是tabelViewCell的`separatorInset`属性可以改变分割线的长短，同时还可以通过设置`separatorInset`值为`UIEdgeInsetsZero`让分割线距左边框为0。iPad上也是如此，代码为： 
>  
```objc
    if (indexPath.row == 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 100, 0, 100);     
    } else if (indexPath.row == 2) {
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, UIScreenWidth - 15);
    } else if (indexPath.row == 3) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"I'm spectator";
        cell.detailTextLabel.text = @"";
    } else if (indexPath.row == 5) {
        cell.textLabel.text = @"Click Me For 'Touch ID'";
        cell.detailTextLabel.text = @"";
    }
```  
> * 在iOS8中自定义分割线(如果小于默认值15则会没有效果)与隐藏分割线样式不受影响，让分割线距屏幕左边为0没有实现  
> ![image](https://github.com/peanutNote/QYIOSWeeklyReport1/blob/master/QYIOSWeeklyReport1/demo1.jpg)  
> 原因有两个：iOS8以后加入了`@property (nonatomic) UIEdgeInsets layoutMargins NS_AVAILABLE_IOS(8_0);`属性，意思就是分割线左边15距离是由系统自动布局的，因此我们将其设置为`UIEdgeInsetsZero`，然而这依旧没有效果因为这里还有一个因素同样是iOS8以后加入的`@property (nonatomic) BOOL preservesSuperviewLayoutMargins NS_AVAILABLE_IOS(8_0);`，我们来看看官方解释：*default is NO - set to enable pass-through or cascading behavior of margins from this view’s parent to its children*，这里tableview是给cell设置为`YES`了我们得将它设置为`NO`，之后就可以得到我们想要的效果了，iPad中效果一样。代码为：
> 
```objc
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
``` 
> * 在iOS9中我们继续以在iOS8中实现的基础上运行我们的代码，发现在iPhone上为预期效果，iPad上则有所不同具体为：分割线默认距离屏幕两侧48，如果自定距离中的数值小于48则会没有效果；因为默认距离与iPhone上不同所以隐藏分割线也没有实现  
> ![image](https://github.com/peanutNote/QYIOSWeeklyReport1/blob/master/QYIOSWeeklyReport1/demo2.jpg)  
> 原因：iOS9中tableView增加了一个新属性`@property (nonatomic) BOOL cellLayoutMarginsFollowReadableWidth NS_AVAILABLE_IOS(9_0);`，官方解释是*if cell margins are derived from the width of the readableContentGuide.* iPad上默认使用该属性的设置将分割线距屏幕两侧默认距离变成了48，因此如果我们想在iPad上自定义分割线样式需要将该属性设置为NO，分割线距屏幕两侧默认距离变成了15，这样一来隐藏分割线方法也与iPhone上设置一致。
  
* 总结：综上所述我们要想在不同SDK版本以及机型上改变分割线的样式就需要干掉哪些不受我们控制的因素，然后达到我们才能“为所欲为”。   
> 参考代码：  
> 在创建tableView的时候：
> 
```objc
if([_tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
```
> 在tableView的代理方法中：
> 
```objc
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
```
> 接下来只要在对应的cell中尽情的去设置cell的`separatorInset`就可以了。

###2.iPhone指纹识别技术Touch ID
* 在需要使用指纹识别的类中导入`#import <LocalAuthentication/LocalAuthentication.h>`

> 具体用法很简单：
>   
```objc  
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
```

各种不可用情况输出的error信息：
  
* 真机上运行如果不可用结果为：
```objc
抱歉，Touch ID不可以使用！
 Optional(Error Domain=com.apple.LocalAuthentication Code=-6 "Biometry is not available on this device." UserInfo=0x15ec5a00 {NSLocalizedDescription=Biometry is not available on this device.})
```
* 在模拟器上的运行结果为：
```objc
抱歉，Touch ID不可以使用！
 Optional(Error Domain=com.apple.LocalAuthentication Code=-1000 "Simulator is not supported." UserInfo=0x7ffe604b0790 {NSLocalizedDescription=Simulator is not supported.})
```
* 连续三次指纹识别错误的运行结果：
```objc
抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-1 "Aplication retry limit exceeded." UserInfo=0x1740797c0 {NSLocalizedDescription=Aplication retry limit exceeded.}
```
* Touch ID功能被锁定，下一次需要输入系统密码时的运行结果：
```objc
抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-1 "Biometry is locked out." UserInfo=0x17407dc00 {NSLocalizedDescription=Biometry is locked out.}
```
* 用户在Touch ID对话框中点击了取消按钮：
```objc
抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-2 "Canceled by user." UserInfo=0x17006c780 {NSLocalizedDescription=Canceled by user.}
```
* 在Touch ID对话框显示过程中，背系统取消，例如按下电源键：
```objc
抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-4 "UI canceled by system." UserInfo=0x170065900 {NSLocalizedDescription=UI canceled by system.}
```
* 用户在Touch ID对话框中点击输入密码按钮：
```objc
抱歉，您未能通过Touch ID指纹验证！
 Error Domain=com.apple.LocalAuthentication Code=-3 "Fallback authentication mechanism selected." UserInfo=0x17407e040 {NSLocalizedDescription=Fallback authentication mechanism selected.}
```
