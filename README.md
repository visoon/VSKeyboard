## VSKeyboard
Resolve the keyboard shelter problem with one line code !
<br>
<br>
<br>
## Installation

> pod 'VSInputView'


### preview gif
![image](https://github.com/visoon/VSKeyboard/blob/master/keyboard.gif)
<br>
<br>


###Usage
####Must call this method in `viewDidAppear` or `viewDidAppear`, pass a UIScrollView(better is a UIScrollView) that you want it scroll.
```c
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [VSKeyboard keyboardAffectOnView:self.mainScrollView];
}
```

####Fetch the height of keyboard from a block timely.
```c
/**
 *  will call the block when height of keyboard changed. Better be called in `ViewWillAppear` or `viewDidAppear`
 */
+ (void)keyboardHeightChanged:(HeightChangeBlock)block;
```
