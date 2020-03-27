# JCS_Kit

[toc]

目录

* [JCS_Kit](#JCS_Kit)
    * [介绍](#介绍)
    * [初体验](#初体验)
    * [集成方法](#集成方法)
    * [JCS_BaseLib](#JCS_BaseLib)
    * [JCS_Category](#JCS_Category)
    * [JCS_Injection](#JCS_Injection)
        * [示例](#示例)
        * [如何开启](#如何开启)
        * [配置文件名称](#配置文件名称)
        * [运行时注入](#运行时注入)
        * [配置规则](#配置规则)
            * [基本类型注入](#基本类型注入)
            * [NSDictionary](#NSDictionary)
            * [NSArray](#NSArray)
            * [模型注入](#模型注入)
            * [模型数组注入](#模型数组注入)
        * [常量注入](#常量注入)
        * [完整示例](#完整示例)
    * [JCS_Router](#JCS_Router)
        * [调用规则](#调用规则)
        * [类方法](#类方法)
        * [缺省方法](#缺省方法)
        * [完成回调](#完成回调)
        * [返回值](#返回值)
        * [跳转UIViewController](#跳转UIViewController)
        * [特殊路由](#特殊路由)
    * [JCS_EventBus](#JCS_EventBus)
        * [示例](#示例)
        * [事件响应注册](#事件响应注册)
        * [事件触发](#事件触发)
        * [路由表](#路由表)
    * [JCS_Create](#JCS_Create)
        * [UITableView(代码创建)](#UITableView代码创建)
        * [UICollectionView(代码创建)](#UICollectionView代码创建)
        * [UITableView(配置文件)](#UITableView配置文件)
        * [UICollectionView(配置文件)](#UICollectionView配置文件)
* [Author](#Author)

## 介绍

JCS_Kit为快速便捷开发而生。JCS_Kit包含下面几个模块
* JCS_BaseLib(主要是常用的宏定义)
* JCS_Category(常用分类)
* JCS_Router(路由)
* JCS_Injection(从配置文件进行数据注入)
* JCS_EventBus(事件总线)
* JCS_Create(链式语法创建UI对象)

## 初体验

示例1: 创建Label对象

原先代码：

```objc
UILabel *titleLabel = [[UILabel alloc] init];
titleLabel.font = [UIFont systemFontOfSize:14];
titleLabel.textColor = UIColor.redColor;
titleLabel.text = @"Hello World";
titleLabel.textAlignment = NSTextAlignmentCenter;
[self.view addSubview:titleLabel];
[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(16);
    make.right.mas_equalTo(-16);
    make.top.mas_equalTo(10);
}];
self.titleLabel = titleLabel;
```

使用JCS_Create后的代码

```
[UILabel jcs_create].jcs_layout(self.view, ^(MASConstraintMaker *make) {
    make.left.mas_equalTo(16);
    make.right.mas_equalTo(-16);
    make.top.mas_equalTo(10);
}).jcs_toLabel()
.jcs_fontSize(14)
.jcs_textColor(UIColor.redColor)
.jcs_text(@"Hello World")
.jcs_textAlignment_Center()
.jcs_associated(&_titleLabel);
```

示例2: 创建UIButton对象

原先代码

```
- (void)setup {
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"Login" forState:(UIControlStateNormal)];
    [loginBtn setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
    [loginBtn setImage:[UIImage imageNamed:@"login-icon"] forState:(UIControlStateNormal)];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    loginBtn.layer.cornerRadius = 22;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn addTarget:self action:@selector(loginButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(44);
        make.center.equalTo(self.view);
    }];
    self.loginBtn = loginBtn;
}

- (void)loginButtonClick:(UIButton*)sender{
    //TODO: 登录逻辑
}
```

是使用JCS_Create后的代码

```
@weakify(self)
[UIButton jcs_create].jcs_layout(self.view, ^(MASConstraintMaker *make) {
    make.width.mas_equalTo(100);
    make.height.mas_equalTo(44);
    make.center.equalTo(self.view);
}).jcs_toButton()
.jcs_normalTitle(@"Login")
.jcs_normalTitleColor(UIColor.blackColor)
.jcs_normalImage([UIImage imageNamed:@"login-icon"])
.jcs_fontSize(14)
.jcs_clickBlock(^(UIButton *sender){
    @strongify(self)
    //TODO: 登录逻辑
})
.jcs_cornerRadius(22)
.jcs_associated(&_loginBtn);
```

示例3: 创建UITableView对象

原先代码

```
@interface ExampleVC ()<UITableViewDataSource,UITableViewDelegate>

/** UITableView **/
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ExampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:DemoCell.class forCellReuseIdentifier:@"DemoCell"];
    [self.tableView registerClass:DemoSectionHeaderView.class forHeaderFooterViewReuseIdentifier:@"DemoSectionHeaderView"];
    [self.tableView registerClass:DemoSectionFooterView.class forHeaderFooterViewReuseIdentifier:@"DemoSectionFooterView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // return cell
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //点击事件
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //Section Header
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //Section Footer
}

@end
```

使用JCS_Create后的代码

```
@interface ExampleVC ()

/** UITableView **/
@property (nonatomic, strong) UITableView *tableView;
/** UITableView 数据源 **/
@property (nonatomic, strong) NSMutableArray<JCS_TableSectionModel*> *sections;

@end

@implementation ExampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self)
    [UITableView jcs_create].jcs_layout(self.view, ^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }).jcs_toTableView()
    .jcs_customerSections(self.sections)
    .jcs_customerDidSelectRowBlock(^(NSIndexPath*indexPath,JCS_TableRowModel*selecedModel){
        @strongify(self)
        //TODO: Cell 点击事件
    })
    .jcs_associated(&_sections);
}

///配置数据源
- (void)configSectionss {
    self.sections = [NSMutableArray array];
    for (NSInteger sectionIndex = 0; sectionIndex < 5; sectionIndex++) {
        
        JCS_TableSectionModel *sectionModel = [JCS_TableSectionModel jcs_create];
        sectionModel.headerClass = @"DemoSectionHeaderView";
        sectionModel.footerClass = @"DemoSectionFooterView";
        sectionModel.headerHeight = 50;
        sectionModel.footerHeight = 50;
        sectionModel.headerData = @{@"title":@"This is Header Data"};
        sectionModel.footerData = @{@"title":@"This is Footer Data"};
        [self.sections addObject:sectionModel];
        
        for (NSInteger rowIndex = 0; rowIndex < 10; rowIndex++) {
            JCS_TableRowModel *rowModel = [JCS_TableRowModel jcs_create];
            rowModel.cellClass = @"DemoCell";
            rowModel.cellHeight = 44;
            rowModel.data = @{@"title":@"This is Cell Data"};
            [sectionModel.rows addObject:rowModel];
        }
    }
}

@end
```

## 集成方法

```
//添加源
source 'https://gitee.com/devjackcat/JCS_PodSpecs.git'

//导入
pod 'JCS_Kit'

#import <JCS_Kit/JCS_Kit.h>
```

## JCS_BaseLib

包含一些常会宏, 自行参考```JCS_Macros.h```定义
* 颜色创建
* 屏幕属性
* 设备判断
* 导航栏、Tab等高度
* .....

## JCS_Category

常用的分类，代码不多，自行阅读实现文件吧

## JCS_Injection

JCS_Injection能够根据文件配置对对象属性进行动态注入。

该功能需要依赖MJExtension，在基础上进行hook实现，对MJExtension现有功能无侵入也无影响。

以下对Person进行初始化赋值为例。

### 示例
### 示例
### 示例

通常我们会这样写

```

@interface Person()

/** 姓名 **/
@property (nonatomic, copy) NSString *name;
/** 年龄 **/
@property (nonatomic, assign) NSInteger age;
/** 爱好 **/
@property (nonatomic, strong) NSArray<NSString*> *likes;
/** 其他信息 **/
@property (nonatomic, strong) NSDictionary *profile;

@end

@implementation Person

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"张三";
        self.age = 28;
        self.likes = @[@"篮球",@"跑步",@"打架"];
        self.profile = @{
            @"blog":@"https://blogs.uvdog.com",
            @"company":@"从不上班"
        };
    }
    return self;
}

- (void)say {
    NSLog(@"");
}

@end
```

使用JCS_Injection注入后代码是这样的

数据文件 Person.geojson
```
{
    "data": {
        "name":"张三",
        "age":30,
        "likes":["骑车","游泳","跳伞"],
        "profile":{
            "blog":"https://blog.uvdog.com",
            "company":"自由职业"
        }
    }
}
```

Person.m
```
@interface Person()

/** 姓名 **/
@property (nonatomic, copy) NSString *name;
/** 年龄 **/
@property (nonatomic, assign) NSInteger age;
/** 爱好 **/
@property (nonatomic, strong) NSArray<NSString*> *likes;
/** 其他信息 **/
@property (nonatomic, strong) NSDictionary *profile;

@end

@implementation Person

/// 开启注入功能
- (BOOL)jcs_propertyInjectEnable {
    return YES;
}

- (void)say {
    //TODO: 这里可以断点查看注入情况
}
@end
```

乍一看这个功能好像没什么用，使用场景不很多。是的，日常开发这样的需求确实不多，但为了后面动态配置UITableView和UICollectionView，JCS_Injection还是有存在必要的。

### 如何开启

```
/// 开启注入功能
- (BOOL)jcs_propertyInjectEnable {
    return YES;
}
```

### 配置文件名称

默认配置文件名为${classname}.geojson，也可以根据需要自己指定文件名。添加下面方法并返回指定文件名即可。

```
- (NSString *)jcs_propertyConfigFileName {
    return @"customer-config-file.json";
}
```

### 运行时注入

JCS_Injection提供了下面三个运行时进行注入的方法。

```
/// 使用字典进行注入(字典格式必须符合配置文件格式)
- (void)jcs_injectPropertiesWithDictionary:(NSDictionary*)dictionary;
/// 使用JSON字符串进行注入(JSON格式必须符合配置文件格式)
- (void)jcs_injectPropertiesWithJSONString:(NSString*)jsonString;
/// 使用配置文件进行注入
- (void)jcs_injectPropertiesWithConfigFile:(NSString*)configFileName;
```

### 配置规则

1. **需要注入属性必须放在"data"属性下**
2. **data下的属性名必须和对象中定义属性名一致，否则无法注入**
3. 已支持基本类型、NSDictionary、NSArray、自定义模型、自定义模型数组

#### 基本类型注入

```
{
    "data":{
      "count":50,
      "name":"张三"
    }
}
```

#### NSDictionary 注入

```
{
    "data":{
          "profile":{
              "username":"张三",
              "age":18
          }
    }
}
```

#### NSArray 注入

```
{
    "data":{
          "items":[{
              "id":123,
              "name":"cat"
          },{
              "id":321,
              "name":"dog"
          }]
    }
}
```

#### 模型注入

模型注入有两种方式，属性定义和__class字段

1.属性定义

```
//在属性定义时，指定具体类型为Person
@property (nonatomic, strong) Person *person;

//配置文件无需做修改
{
    "data":{
          "person":{
              "name":"peter",
              "age":15,
              "money":10000000
          },
    }
}
```

2.__class字段

```
{
    "data":{
          "person":{
              "__class":"Person",
              "name":"peter",
              "age":15,
              "money":10000000
          },
    }
}
```

#### 模型数组注入

模型数组，只需在每个对象中添加__class指定类型即可

```
{
    "data":{
      "persons":[{
          "__class":"Person",
          "name":"aaaa",
          "age":15,
          "money":10000000
      },{
          "__class":"Person",
          "name":"bbbb",
          "age":16,
          "money":10000001
      }]
  }
}
```

### 常量注入

配置文件data属性下的任何一个属性值中配置了常量表达式，在运行时都会动态进行解析并替换为实际数值。

**表达式必须已"$"开头。**

如存在下面配置
```
{
    "data": {
        "screenWidth":"$SCREEN_WIDTH",
        "screenScale":"$SCREEN_WIDTH/$SCREEN_HEIGHT"
    }
}
```

JCS_Injection在注入之前会将上面配置根据实际屏幕尺寸进行替换为下面内容后再进行注入

```
{
    "data": {
        "screenWidth":"375",
        "screenScale":"375/667"
    }
}
```

已支持常量

|常量表达式|说明|
|---|---|
|SCREEN_WIDTH|屏幕宽度|
|SCREEN_HEIGHT|屏幕高度|
|SCREEN_SCALE|2倍、3倍|
|STATUS_BAR_HEIGHT|状态栏高度iPhoneX系=44,其他20|
|NAVIGATION_BAR_HEIGHT|导航栏高度iPhoneX系=88,其他64|
|TAB_BAR_HEIGHT|Tab高度iPhoneX系=(49+34),其他49|
|NAVIGATION_BAR_WITHOUTSTATUS_HEIGHT|导航栏不带statusbar,44|
|HOME_INDICATOR_HEIGHT|Home指示剂iPhonex=34,其他=0|
|iOS_VERSION|系统版本，如"11.4.1"|
|APP_NAME|App名称，CFBundleDisplayName|
|APP_VERSION|App版本，CFBundleShortVersionString|
|BUILD_VERSION|AppBuild号，CFBundleVersion|
|BUNDLE_ID|BundleId，CFBundleIdentifier|
|DEVICE_TYPE|设备类型，[[UIDevice currentDevice] model]|
|DEVICE_NAME|设备名称，如"JackCat's iPhone"|

### 完整示例

```
{
  "data":{
      
      "count":50,
      "name":"属性注入",
      
      "data":{
          "__class":"Person",
          "name":"张三",
          "age":18
      },
      
      "items":[{
          "id":123,
          "name":"cat"
      },{
          "id":321,
          "name":"dog"
      }],
      
      "person1":{
          "name":"aaaa",
          "age":15,
          "money":10000000,
          "__width":10,
          "likes":["唱歌","跳舞"],
          "son":{
              "name":"jack",
              "age":5
          }
      },
      
      "person2":{
          "__class":"Person",
          "name":"aaaa",
          "age":15,
          "money":10000000,
          "__width":10,
          "likes":["唱歌","跳舞"],
          "son":{
              "name":"jack",
              "age":5
          }
      },
      
      "persons":[{
          "__class":"Person",
          "name":"aaaa",
          "age":15,
          "money":10000000,
          "likes":["唱歌","跳舞"],
          "employees":[{
              "__class":"Person",
              "name":"张",
              "likes":["唱歌","跳舞"],
          },{
              "__class":"Person",
              "name":"李"
          },{
              "__class":"Person",
              "name":"王"
          }]
      },{
          "__class":"Person",
          "name":"bbbb",
          "age":16,
          "money":10000001
      },{
          "__class":"Person",
          "name":"cccc",
          "age":17,
          "money":10000002
      }]
  }
}
```

## JCS_Router

路由可降低不同组件之间的解耦，但不影响组件之间的通讯。

如存在路由

```
@interface TestRouter : NSObject
@end

@implementation TestRouter
- (void)hello:(NSDictionary*)params {
    NSLog(@"路由方法被调用， 参数 = %@",params);
}
@end
```

调用上面的路由

```
//路由地址
[JCS_RouterCenter router2Url:@"jcs://TestRouter/hello:" args:@{@"name":@"张三"} completion:nil];
//代码调动
[JCS_RouterCenter router2ClassName:@"TestRouter" selName:@"hello:" args:@{@"name":@"张三"} completion:nil];
```

### 调用规则

JCS_Router内部是通过TargetAction方式进行方法调用，调用时需要提供方法执行对象Target和方法名Action。

路由地址字符串必须以协议"jcs://"开头(**下文的特殊路由除外**)，例如

```
jcs://TestRouter/hello:?params1=1&params2=2...
```

上面路由地址将被解析为调用```[TestRouter hello:]```方法，参数是```{@"params1":@"1",@"params2":@"2"}```

### 类方法 vs 示例方法

对于类方法调用还是实例方法调用，JCS_Router都是一样的调用方法。方法查找规则如下

* 查找实例方法，找到则执行，反之
* 查找类方法，找到则执行，反之
* 报错

例如，存在下面的路由，

```
@implementation TestRouter
- (void)sayHello:(NSDictionary*)params {
    NSLog(@"实例方法 sayHello");
}
+ (void)sayHello:(NSDictionary*)params {
    NSLog(@"类方法 sayHello");
}
@end
```

调用方法

```
[JCS_RouterCenter router2ClassName:@"TestRouter" selName:@"sayHello:" args:@{@"name":@"张三"} completion:nil];
```

因为存在实例方法``` sayHello: ```,所以会打印出``` 实例方法 sayHello ```。
若将实例方法注释掉，则会打印出``` 类方法 sayHello ```。

### 缺省方法

调用路由时若为给出Selector,则默认会执行@selector(setJcs_params:)方法。在他方法需要获取参数直接调用self.jcs_params即可。

### 完成回调

调用路由时提供了一个completion参数，类型为Block，可选。

```
void(^)(NSError *error, id response)
```

若传递了该参数，在路由方法中通过下面方法获取该block对象
```
void(^completion)(NSError*error,NSDictionary*response) = [params valueForKey:JCS_ROUTER_COMPLETION];
```

执行完成回调时，调用方的completion将收到回调

```
if(completion){
    completion(nil,@{@"success":@YES})
}
```

### 返回值

JCS_Router支持同步返回

```
@implementation TestRouter
- (NSString*)getMessage{
    return @"你好 Message";
}
@end
```

调用方法

```
NSString *message = [JCS_RouterCenter router2ClassName:@"TestRouter" selName:@"getMessage" args:nil completion:nil];
```

### 跳转UIViewController

方法一

```
//定义
@implementation TestRouter
- (void)showOrderListVC:(NSDictionary*)params {
    OrderListVC *vc = [[OrderListVC alloc] init];
    vc.jcs_params = params;
    [self.jcs_currentVC jcs_pushVC:vc animated:YES];
}
@end

//调用
[JCS_RouterCenter router2ClassName:@"TestRouter" selName:@"showOrderListVC:" args:@{@"status":@1} completion:nil];
```

方法二

```
//该方法无需定义路由，直接传入ViewController名称即可。
[JCS_RouterCenter router2Url:@"jcs://OrderListVC" args:@{@"status":@1} completion:nil];

在ViewController中的jcs_params:方法中获取传入参数。
也可以在setJcs_params:方法中自行接收参数
```

**重写setJcs_params:方法时，必须调用[super setJcs_params:]方法，否则将无法通过self.jcs_params属性获取数据**

### 特殊路由

JCS_Router内部已经实现了几个特殊路由，无需再为其定义路由即可使用。

|路由|说明|
|---|---|
|sms://10086&&body=123|进行系统短信发送页面|
|telprompt://4008887381|拨打电话4008887381|

## JCS_EventBus

JCS_EventBus为跨多层对象之间通讯而生。开发中有时会遇到下面的场景。

* 一个UITableView，每一个Cell中都有个按钮，按钮点击事件需要统一管理。
* 一个ViewController中的两个不相关的View和Button，两者跨层级较大，此时需要点击按钮时View的显示做出响应。

通常我们解决这些文件可能最便捷的方法就是Notification了。

JCS_EventBus为此提供了另一种方案。在ViewController中创建一个JCS_EventBus,每个子视图弱引用这个eventBus对象即可。

### 示例

#### 示例

```
//事件ID
#define EVENT_ID @"EVENT_ID"

@interface EventBus_ExampleVC ()
@property (nonatomic, strong) JCS_EventBus *eventBus;
@end

@implementation EventBus_ExampleVC

- (void)jcs_setup {
    //事件注册
    [self.eventBus registerAction:EVENT_ID executeBlock:^(id params){
        NSLog(@"post 1 params = %@",params);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //事件触发
    [self.eventBus postEvent:EVENT_ID params:@{
        @"goodsId":@"1o1o12i1i2"
    }];
}

JCS_LAZY(JCS_EventBus, eventBus)

@end
```

### 事件响应注册

JCS_EventBus提供Block和Action两种注册方式。

```
//Block形式
[self.eventBus registerAction:EVENT_ID executeBlock:^(id params){
    NSLog(@"post 1 params = %@",params);
}];

//Action
[self.eventBus registerAction:EVENT_ID target:self selector:@selector(eventHandler:)];

//Action响应
- (void)eventHandler:(id)params {
    NSLog(@"post 3 params = %@",params);
}
```

**若同一个EventId被注册多次，则所有注册的地方都将收到回调。**

### 事件触发

```
[self.eventBus postEvent:EVENT_ID params:@{
    @"goodsId":@"1o1o12i1i2"
}];
```

### 路由表

有些场景下点击会通过路由进行转发，会这样写

```
//跳转至登录界面
[self.eventBus registerAction:@"showLoginVC" executeBlock:^(id params){
    [JCS_RouterCenter router2Url:@"jcs://LoginVC" args:params completion:nil];
}];

//跳转至订单列表页
[self.eventBus registerAction:@"showOrderListVC" executeBlock:^(id params){
    [JCS_RouterCenter router2Url:@"jcs://OrderListVC" args:params completion:nil];
}];

......

```

这样会产生太多类似的转发代码。为了方便，JCS_EventBus提供了路由表来解决这问题。

```
[self.eventBus addEventRouterMapFromDictionary:@{
    @"showLoginVC":@"jcs://LoginVC", //登录路由
    @"showOrderListVC":@"jcs://OrderListVC" //跳转订单列表
}];
```

只需addEventRouterMapFromDictionary即可省去上面一堆的转发代码。

**若同一个EventId在路由表中已存在，则该EventId其他注册的地方将不再收到触发回调**

## JCS_Create

### UITableView(代码创建)
[JCS_TableView(代码创建)](https://github.com/jcsteam/JCS_Kit/blob/master/doc/uitableview-code.md)
### UICollectionView(代码创建)
[UICollectionView(代码创建)](https://github.com/jcsteam/JCS_Kit/blob/master/doc/uicollectionview-code.md)
### UITableView(配置文件)
[UITableView(配置文件)](https://github.com/jcsteam/JCS_Kit/blob/master/doc/uitableview-config-file.md)
### UICollectionView(配置文件)
[UICollectionView(配置文件)](https://github.com/jcsteam/JCS_Kit/blob/master/doc/uicollectionview-config-file.md)

## 示例
## 示例

# Author

devjackcat@163.com
