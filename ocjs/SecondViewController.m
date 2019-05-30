//
//  SecondViewController.m
//  ocjs
//
//  Created by ZD on 2019/5/30.
//  Copyright © 2019 ZD. All rights reserved.
//

#import "SecondViewController.h"
#import <WebKit/WebKit.h>

#define SCRREN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCRREN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface SecondViewController ()<WKUIDelegate,WKNavigationDelegate, WKScriptMessageHandler, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = false;
    self.view.backgroundColor = [UIColor whiteColor];
    [self configWebview];
}

- (void)configWebview {

    WKUserContentController *userC = [[WKUserContentController alloc] init];
    [userC addScriptMessageHandler:self name:@"showMsg"];
    [userC addScriptMessageHandler:self name:@"selectPicture"];
    [userC addScriptMessageHandler:self name:@"postClick"];
    
    WKPreferences *preference = [WKPreferences new];
    preference.minimumFontSize = 10;
//    preference.javaScriptCanOpenWindowsAutomatically = true;
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.userContentController = userC;
    config.preferences = preference;
    
    _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, _progressView.frame.size.height);
    _progressView.tintColor = [UIColor orangeColor];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, _progressView.frame.size.height, SCRREN_WIDTH, self.view.frame.size.height - _progressView.frame.size.height) configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.UIDelegate = self;
    
    
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:_progressView];
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WKWebViewMessageHandler" ofType:@"html"];
    NSString *fileURL = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:fileURL baseURL:baseURL];
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else if([keyPath isEqualToString:@"estimatedProgress"]) {
        _progressView.progress = _webView.estimatedProgress;
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"title" context:NULL];
}

#pragma mark - WKScriptMessageHandler js 调用 OC 接口
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([message.name isEqualToString:@"showMsg"]) {
        [self showMsg:message.body];
    } else if ([message.name isEqualToString:@"selectPicture"]) {
        [self selectPicture];
    }else if ([message.name isEqualToString:@"postClick"]) {
        [self postClick:message.body];
    }
    
}



#pragma mark - WKNavigationDelegate 页面跳转和载入

#pragma mark - 页面跳转
//收到跳转动作时, 决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURLRequest *request = navigationAction.request;
    NSString *hostname = request.URL.host.lowercaseString;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated
        && ![hostname containsString:@"baidu.com"]) {
        // 对于跨域，需要手动跳转
//        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
    NSLog(@"收到跳转动作时, 决定是否跳转");
}
//收到服务器响应时, 决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"收到服务器响应时, 决定是否跳转");
}

//收到服务器跳转动作时, 决定是否跳转
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"收到服务器跳转动作时, 决定是否跳转");
}

#pragma mark - WKNavigationDelegate 页面载入

// 开始请求内容
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"开始请求内容");
}

// 开始请求内容时失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"开始请求内容时失败");
}

// 服务器开始返回内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"服务器开始返回内容");
}

// 服务器开始返回内容完毕
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"服务器开始返回内容完毕");
    _progressView.hidden = true;
}

// 服务器开始返回内容过程错误
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@" 服务器开始返回内容过程错误");
    _progressView.hidden = true;
}

// 页面权限变化
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    NSLog(@"页面权限变化时处理");
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

// 服务器开始返回内容过程终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    NSLog(@"服务器开始返回内容过程终止");
}

#pragma mark - WKUIDelegate 页面是否显示警告框\确认框\输入框

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:[NSString stringWithFormat:@"js 调用 alert : %@",message] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"js 调用 confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"js 调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

#pragma mark - Method

- (void)showMsg:(NSDictionary *)dic
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *title = [dic objectForKey:@"title"];
    NSString *content = [dic objectForKey:@"content"];
    NSString *url = [dic objectForKey:@"url"];
    
    //OC反馈给JS分享结果
    NSString *JSResult = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    //OC调用JS
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (void)postClick:(NSString *)postString{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"js消息" message:postString preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *JSResult = [NSString stringWithFormat:@"cameraResult('%@')",@"传递消息给 oc 成功"];
        [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)selectPicture
{
    //在这里写调用打开相册的代码
    [self selectImageFromPhotosAlbum];
}

#pragma mark 打开相册
- (void)selectImageFromPhotosAlbum
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [imagePickerController setAllowsEditing:YES];
    [imagePickerController setDelegate:self];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *JSResult = [NSString stringWithFormat:@"cameraResult('%@')",@"选择相册照片成功"];
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
