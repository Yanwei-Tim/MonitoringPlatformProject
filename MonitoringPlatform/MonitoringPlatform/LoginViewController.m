//
//  LoginViewController.m
//  TestSDK
//
//  Created by wangjiayu on 2017/4/11.
//  Copyright © 2017年 wangjiayu. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "User.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceTop;

///** cameraID */
//@property (nonatomic,strong) NSString *cameraID;
///** deviceID */
//@property (nonatomic,strong) NSString *deviceID;
///** uid */
//@property (nonatomic,strong) NSNumber *uid;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self showHomeContoller];
    [self.view endEditing:YES];
    self.accountField.text = nil;
    self.passwordField.text = nil;
}

///如果第一次登陆后没有退出的话,则下次打开app直接进入首页
- (void) showHomeContoller {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if (username.length > 0 && password.length > 0) {
        [self performSegueWithIdentifier:@"pushHomeController" sender:nil];
    }
}

///监听键盘将要弹出
- (void)keyBoardWillShow:(NSNotification *)notify {
    CGFloat duration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect rect = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat offsetY = CGRectGetMaxY(self.backView.frame) - rect.origin.y;
    if (offsetY > 0) {
        self.distanceTop.constant -= (offsetY + 10);
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

///监听键盘将要隐藏
- (void)keyBoardWillHide:(NSNotification *)notify {
    CGFloat duration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.distanceTop.constant = 245;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}


///登陆按钮响应事件
- (IBAction)loginButton:(UIButton *)sender {
    [self login];
}

///登录
- (void) login {
    if (self.accountField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"账号不能为空";
        [hud hideAnimated:YES afterDelay:3.0];
        return;
    }else if (self.passwordField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"密码不能为空";
        [hud hideAnimated:YES afterDelay:3.0];
        return;
    }
    [self.view endEditing:YES];
    NSMutableDictionary *parame = [NSMutableDictionary dictionary];
    parame[@"userName"] = self.accountField.text;
    parame[@"password"] = self.passwordField.text;
    [[HttpClient sharedClient] postPath:@"/giscoop/LoginInformationController/loginInformation" params:parame resultBlock:^(id responseObject, NSError *error) {
        if (!error) {
            if ([responseObject[@"msg"] isEqualToString:@"登录成功"]) {
                if (responseObject[@"data"][@"mUserCameral"] != nil) {
                    [self saveUserInformation:responseObject[@"data"]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"pushHomeController" sender:nil];
                });
            }
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"用户名或密码有误，请重试···"];
            });
        }
    }];
}

///保存信息
- (void) saveUserInformation:(NSDictionary *)dict {
    NSString *cameraID = dict[@"mUserCameral"][@"cameraID"];
    NSString *deviceID = dict[@"mUserCameral"][@"deviceID"];
    NSNumber *uid = dict[@"uid"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (cameraID.length > 0) {
        [defaults setObject:cameraID forKey:@"cameraID"];
    }
    if (deviceID.length > 0) {
        [defaults setObject:deviceID forKey:@"deviceID"];
    }
    if ([uid stringValue].length > 0) {
        [defaults setObject:uid forKey:@"uid"];
    }
    if (self.accountField.text.length > 0) {
        [defaults setObject:self.accountField.text forKey:@"userName"];
    }
    if (self.passwordField.text.length > 0) {
        [defaults setObject:self.passwordField.text forKey:@"password"];
    }
    
    [defaults synchronize];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

///移除通知
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    HomeViewController *destination = segue.destinationViewController;
////    destination.cameraID = self.cameraID;
////    destination.deviceID = self.deviceID;
////    destination.uid = self.uid;
//    if ([destination respondsToSelector:@selector(setCameraID:)]) {
//        [destination setValue:self.cameraID forKey:@"cameraID"];
//    }
//    if ([destination respondsToSelector:@selector(setDeviceID:)]) {
//        [destination setValue:self.deviceID forKey:@"deviceID"];
//    }
//    if ([destination respondsToSelector:@selector(setUid:)]) {
//        [destination setValue:self.uid forKey:@"uid"];
//    }
//}


@end
