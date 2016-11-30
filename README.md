## VSKeyboard
一句代码解决键盘遮挡输入框问题！
<br>
<br>
<br>


### 预览图
![image](https://github.com/visoon/VSKeyboard/blob/master/keyboard.gif)
<br>
<br>


###使用说明
####一句话搞定键盘遮挡问题，务必在`viewDidAppear`或者`viewWillAppear`中调用，传入你想滚动的视图
```c
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [VSKeyboard keyboardAffectOnView:self.mainScrollView];
}
```

####实时获取键盘高度，通过block返回键盘高度
```c
/**
 *  will call the block when height of keyboard changed. Better be called in `ViewWillAppear` or `viewDidAppear`
 */
+ (void)keyboardHeightChanged:(HeightChangeBlock)block;
```
