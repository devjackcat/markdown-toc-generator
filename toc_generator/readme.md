# JCS_Tool

[toc]

目录
* [介绍](#介绍)
* [初体验](#初体验)
* [配置信息](#配置信息)
    * [配置](#配置)
    * [prefix](#prefix)
    * [responseModel](#responseModel)
* [Author](#Author)

## 介绍

JCS_Tool 用来生成Enum、Model及Request的工具。

## 初体验

配置信息source.h

```
Config{
    "prefix":"JCUser",
    "responseModel":"CommonResponse"
}

/**
 生成枚举 Sex
*/
enum Sex {
    desc 这是性别枚举
    male = 1,   //男
    female = 2, //女
}

/**
 生成模型Person
*/
message Person {
    desc 用户信息实体类
    optional string name = @"张三"; //姓名
    optional Sex sex = male; //性别
}

/**
 生成用户用户信息接口请求方法(
    请求方法:POST
    方法名:getPersonInfoById
    返回数据解析类型：Person
    接口: /getUserInfo.action
    参数：userId
 )
*/
request post getPersonInfoById Person /getUserInfo.action {
    desc 获取用户信息
    optional int userId = 0; //用户ID
}
```

上面这个配置文件通过JCS_Tool可以生成 JCUserModel.h、JCUserModel.m、JCUserRequest.h、JCUserRequest.m四个文件。

JCSUserModel.h
```

#import <UIKit/UIKit.h>


@class JCUserPerson;


/**
  这是性别枚举
 */
typedef NS_ENUM(NSInteger, JCUserSex) { 
  JCUserSexMale = 1, //男 
  JCUserSexFemale = 2, //女 
};


/**
  用户信息实体类
 */
@interface JCUserPerson : NSObject
/** 姓名 */
@property (nonatomic, strong) NSString *name;
/** 性别 */
@property (nonatomic, assign) JCUserSex sex;
@end
```

JCUserModel.h.m
```

#import "JCUserModel.h"

/**
  用户信息实体类
 */
@implementation JCUserPerson
 
- (instancetype)init {
    self = [super init];
    if (self) {
      self.name = @"张三";
      self.sex = JCUserSexMale;
    }
    return self;
}
 
@end
```

JCUserRequest.h
```

#import <UIKit/UIKit.h>
 

#import "CommonResponse.h"
#import "JCUserModel.h"

@interface JCUserRequest : NSObject



#pragma mark - getPersonInfoById


/**
  获取用户信息

  @params hub 是否转菊花 
  @params params 请求参数 
  @params success 成功回调 
  @params failure 失败回调 
 */
+ (void)requestGetPersonInfoByIdWithHub:(BOOL)hub params:(NSDictionary *)params success:(void(^)(CommonResponse *result,JCUserPerson *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;


/**
  获取用户信息

  @params hub 是否转菊花 
  @params userId 用户ID 
  @params success 成功回调 
  @params failure 失败回调 
 */
+ (void)requestGetPersonInfoByIdWithHub:(BOOL)hub userId:(NSInteger)userId  success:(void(^)(CommonResponse *result,JCUserPerson *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;

@end
```

JCUserRequest.m
```

#import <UIKit/UIKit.h>
#import <MJExtension/MJExtension.h>
#import "JCS_Request.h"
#import "JCUserRequest.h"

@implementation JCUserRequest : NSObject


#pragma mark - getPersonInfoById


/**
  获取用户信息

  @params hub 是否转菊花 
  @params params 请求参数 
  @params success 成功回调 
  @params failure 失败回调 
 */
+ (void)requestGetPersonInfoByIdWithHub:(BOOL)hub params:(NSDictionary *)params success:(void(^)(CommonResponse *result,JCUserPerson *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure { 
    if(hub){ 
        dispatch_async(dispatch_get_main_queue(), ^{  
            [JCS_Request showQueryHub]; 
        }); 
    } 
    //参数预处理 
    NSDictionary *processedParams = [JCS_Request preprocessParams:params]; 
    NSString *url = nil; 
    if([@"/getUserInfo.action" hasPrefix:@"/"] || [[JCS_Request getBaseUrl] hasSuffix:@"/"]){ 
        url = [NSString stringWithFormat:@"%@/getUserInfo.action",[JCS_Request getBaseUrl]]; 
    } else { 
        url = [NSString stringWithFormat:@"%@//getUserInfo.action",[JCS_Request getBaseUrl]]; 
    } 
    [[JCS_Request sharedInstance] GET:url parameters:processedParams progress:^(NSProgress * _Nonnull uploadProgress) { 
 
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) { 
        if(hub){ 
            dispatch_async(dispatch_get_main_queue(), ^{  
                [JCS_Request hideRequestHub]; 
            }); 
        } 
        CommonResponse *result = [CommonResponse mj_objectWithKeyValues:responseObject]; 
        if(success){ 
            //获取data数据 
            id data = [JCS_Request dataInResponse:responseObject url:url requestParams:processedParams]; 
            JCUserPerson *info = [JCUserPerson mj_objectWithKeyValues:data]; 
            success(result, info, responseObject); 
        } 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { 
        if(hub){ 
            dispatch_async(dispatch_get_main_queue(), ^{  
                [JCS_Request showRequestErrorHub:error]; 
            }); 
        } 
        //处理错误
        [JCS_Request errorRequest:error url:url requestParams:params];
        if(failure){
            failure(error);
        }
    }]; 
} 



/**
  获取用户信息

  @params hub 是否转菊花 
  @params userId 用户ID 
  @params success 成功回调 
  @params failure 失败回调 
 */
+ (void)requestGetPersonInfoByIdWithHub:(BOOL)hub userId:(NSInteger)userId  success:(void(^)(CommonResponse *result,JCUserPerson *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userId"] = @(userId);
    [self requestGetPersonInfoByIdWithHub:hub params:params success:success failure:failure];
} 

@end
```

## 配置信息

### 配置

下文的示例前缀均为JCUser

```
Config{
    "prefix":"JCUser",
    "responseModel":"CommonResponse",
    "signalRequest":true
}
```

### prefix

生成模型、枚举、文件名前缀，必须配置。具体生成规则如下

文件生成规则

* ${prefix} + Model.h
* ${prefix} + Model.m
* ${prefix} + Request.h
* ${prefix} + Request.m

模型生成规则

* ${prefix} + ${模型名称}

枚举生成规则

* ${prefix} + ${枚举名称}

### responseModel

接口相应解析类型

例如接口相应格式如下，且则responseModel=CommonResponse
```
{
    success:true,
    msg:"成功",
    code:10000,
    data:{
        ...
    }
}
```

CommonResponse 定义
```
@interface CommonResponse : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *msg;

@end
```

### signalRequest

生成接口时是否需要生成RASSignal返回值的接口，后面会有讲到

## import

JCS_Tool支持外部import

```
import.class = Person
import.lib = Lib/Lib
```

上面配置信息将被解析为下面内容，并添加在所有.h文件的顶部

```
#import <Lib/Lib.h>
#import "Person.h"
```

## 枚举

```
enum 枚举名称 {
    desc 枚举备注
    属性名1 = 属性值1, //备注1
    属性名2 = 属性值2 //备注2
    ......
}
```

Example
```
enum Sex {
    desc 这是性别枚举
    male = 1,   //男
    female = 2, //女
}
```

生成后的内容

```
/**
  这是性别枚举
 */
typedef NS_ENUM(NSInteger, JCUserSex) { 
  JCUserSexMale = 1, //男 
  JCUserSexFemale = 2, //女 
};
```

## 模型

### 语法

```
message Model名 {
    desc Model备注
    optional 类型 属性名1 = 默认值; //属性备注
    optional 类型 属性名2 = 默认值; //属性备注
    ...
}
```

Example
```
message Person {
    desc 用户信息实体类
    optional string name = @"张三"; //姓名
    optional Sex sex = male; //性别
}
```

### 类型

### 简单类型

|Alias|实际类型|
|---|---|
|string|NSString|
|int|NSInteger|
|long|NSInteger|
|float|CGFloat|
|double|double|
|bool|BOOL|
|list|NSMutableArray|
|mlist|NSMutableArray|
|dict|NSMutableDictionary|
|mdict|NSMutableDictionary|

### 枚举类型

```
message Person {
    ...
    optional Sex sex = male; //性别
    ...
}
```

若配置信息中包换枚举配置，则上面Sex将被解析为JCUserSex类型，默认值为JCSUserSexMale。若未包含枚举配置，则将被视为异常类型，均以指针形式处理，处理结果" Sex * "

### 内部Model

当前配置信息中包含如下配置
```
message AddressInfo {
    .....
}
```

Person中有属性定义为
```
optional AddressInfo address = nil; //地址信息
```

则最终会被解析为

```
/** 地址信息 */
@property (nonatomic, strong) JCUserAddressInfo *address;
```

### 外部Model

JCS_Tool支持外部Model引用。如项目中存在定义 XXXAddress, 参照上文import方式进行引入。并配置为

```
optional XXXAddress address = nil; //地址信息
```

将被解析为

```
/** 地址信息 */
@property (nonatomic, strong) XXXAddress *address;
```

引用外部Model，将不会自动添加前缀，类型部分需配置完整类名。反之将被作为指针类型原样输出。

### 其他

若配置了JCS_Tool无法解析的类型，则将被作为指针原样输出。

如存在如下配置
```
optional UnKnowType address = nil;
```

将被解析为

```
@property (nonatomic, strong) UnKnowType *address;
```

**外部Model实际就是该原理进行实现**

## 模型继承

JCS_Tool支持模型继承，配置方式为

```
message Person {
}
message Student extends Person {
}
```
解析结果为
```
@interface HKUserPerson : NSObject
@end

@interface HKUserStudent : HKUserPerson
@end
```

**父类同时支持内部Model和外部Model**

## 接口方法

JCS_Tool生成的接口方法，需要依赖JCS_Reqeust类，JCS_Request源码在项目根目录下。

### 响应内容解析

JCS_Tool需要一个辅助Model来解析服务器响应内容。

若服务端响应内容格式是这样的
```
{
    code:1000,
    msg:"成功",
    success:true,
    data:....
}
```

那么需要定一个的解析Model，名称可以自己指定

```
@interface CommonResponse : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *msg;

@end
```

将CommonResponse配置在Config对象中

```
Config{
    ......
    "responseModel":"CommonResponse",
    ......
}
```


### JCS_Request

JCS_Tool需要依赖一个JCS_Request的网络请求对象，名称目前不可自行指定。JCS_Request相关源码在项目根目录中。

JCS_Request需要实现方法说明

```

@interface JCS_Request : AFHTTPSessionManager

/// 获取BaseUrl
+ (NSString*)getBaseUrl;

/// 对参数进行预处理，如加密、添加公共参数等。无特殊操作则直接 return params;
+ (NSDictionary*)preprocessParams:(NSDictionary*)params;

/// 返回响应中的data属性
/// 例如服务端响应内容如下
/// {
///     code:10000,
///     msg:"成功",
///     success:true,
///     data:{}
/// }
/// 则在该方法中 return [requestParams valueForKey:@"data"];
+ (id)dataInResponse:(NSDictionary*)response url:(NSString*)url requestParams:(NSDictionary*)requestParams;

/// 请求错误时，该方法会被调用，自行处理错误逻辑
+ (void)errorRequest:(NSError*)error url:(NSString*)url requestParams:(NSDictionary*)requestParams;


/// 菊花显示与隐藏
+ (void)showQueryHub;
+ (void)showRequestErrorHub:(NSError*)error;
+ (void)hideRequestHub;

@end
```

### 配置语法
```
request ${请求Method} ${生成方法名} ${响应data类型} ${请求连接} {
    desc ${生成方法备注}
    optional 参数类型 参数名1; //参数备注1
    optional 参数类型 参数名2; //参数备注2
}
```

* 请求Method为两种POST、GET。
* 生成方法名自行指定，符合命名规则即可。
* 响应data类型，已支持下面几种类型
    * nil -> nil将被解析为NSDictionary类型
    * dict -> NSDictionary
    * list -> NSArray
    * list<内部Person> -> NSArray<前缀+Person>
    * list<外部部Person> -> NSArray<原样Person>
    * Person -> 内部Model(前缀+Person)
    * Person -> 外部Model(原样替换)

具体示例
```
//get方式请求用户信息，data类型为NSDictionary
request get getUserInfo1 nil /getUserInfo.action {
    desc 获取用户信息接
    optional int userId; // 用户ID
}

//post方式请求用户信息，data类型为Person
request get getUserInfo2 Person /getUserInfo.action { }

// post方式获取用户列表，data类型为NSArray
request post getUserList1 list /getUserList.action {}

// post方式获取用户列表，data类型为NSArray<Person>
request post getUserList2 list<Person> /getUserList.action {}
```

上面配置内容将生成下面的一系列方法(为了方便阅读，下面内容是删除了相关注释后的内容)

```
@interface HKUserRequest : NSObject

#pragma mark - getUserInfo1

+ (void)requestGetUserInfo1WithHub:(BOOL)hub params:(NSDictionary *)params success:(void(^)(CommonResponse *result,NSDictionary *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;
+ (void)requestGetUserInfo1WithHub:(BOOL)hub userId:(NSInteger)userId  success:(void(^)(CommonResponse *result,NSDictionary *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;

#pragma mark - getUserInfo2

+ (void)requestGetUserInfo2WithHub:(BOOL)hub params:(NSDictionary *)params success:(void(^)(CommonResponse *result,HKUserPerson *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;
+ (void)requestGetUserInfo2WithHub:(BOOL)hub  success:(void(^)(CommonResponse *result,HKUserPerson *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;

#pragma mark - getUserList1

+ (void)requestGetUserList1WithHub:(BOOL)hub params:(NSDictionary *)params success:(void(^)(CommonResponse *result,NSArray *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;
+ (void)requestGetUserList1WithHub:(BOOL)hub  success:(void(^)(CommonResponse *result,NSArray *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;

#pragma mark - getUserList2

+ (void)requestGetUserList2WithHub:(BOOL)hub params:(NSDictionary *)params success:(void(^)(CommonResponse *result,NSArray<HKUserPerson *> *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;
+ (void)requestGetUserList2WithHub:(BOOL)hub  success:(void(^)(CommonResponse *result,NSArray<HKUserPerson *> *data,NSDictionary *originResponse))success failure:(void(^)(NSError*error))failure;

@end
```

调用方式

```
//获取用户信息，传入NSDictionary,返回值NSDictionary
[HKUserRequest requestGetUserInfo1WithHub:YES params:@{@"userId":@1} success:^(CommonResponse *result, NSDictionary *data, NSDictionary *originResponse) {
    if(result.success){
        //请求成功，使用data进行业务处理
    } else {
        //请求失败
        NSString *msg = result.msg;
    }
} failure:^(NSError *error) {
    //请求失败
}];
    
//获取用户信息，直接传入userId,返回值NSDictionary
[HKUserRequest requestGetUserInfo1WithHub:YES userId:1 success:^(CommonResponse *result, NSDictionary *data, NSDictionary *originResponse) {
    
} failure:^(NSError *error) {
    
}];
    
//获取用户信息，传入NSDictionary,返回值HKUserPerson
[HKUserRequest requestGetUserInfo2WithHub:YES params:@{@"userId":@1} success:^(CommonResponse *result, HKUserPerson *data, NSDictionary *originResponse) {
    
} failure:^(NSError *error) {
    
}];
    
// 获取用户列表，参数NSDictionary, 返回NSDictionary
[HKUserRequest requestGetUserList1WithHub:YES params:nil success:^(CommonResponse *result, NSArray *data, NSDictionary *originResponse) {
    
} failure:^(NSError *error) {
    
}];
    
// 获取用户列表，参数NSDictionary, 返回NSArray<HKUserPerson *>
[HKUserRequest requestGetUserList2WithHub:YES params:nil success:^(CommonResponse *result, NSArray<HKUserPerson *> *data, NSDictionary *originResponse) {
    
} failure:^(NSError *error) {
    
}];
```

有时会需要多个接口全部响应完成后再做业务处理，JCS_Tool为这样的需求做了兼容，为每个接口都生成返回RACSignal的方法，**该功能需要ReactiveObjC支持**。需要在Config中添加如下配置

```
Config{
    ......
    "signalRequest":true,
    ......
}
```
配置内容无需改动，生成的方法会多出下面的方法

```
@interface HKUserRequest : NSObject

#pragma mark - getUserInfo1

+ (RACSignal*)requestGetUserInfo1WithHub:(BOOL)hub params:(NSDictionary *)params;
+ (RACSignal*)requestGetUserInfo1WithHub:(BOOL)hub userId:(NSInteger)userId ;

#pragma mark - getUserInfo2

+ (RACSignal*)requestGetUserInfo2WithHub:(BOOL)hub params:(NSDictionary *)params;
+ (RACSignal*)requestGetUserInfo2WithHub:(BOOL)hub ;

#pragma mark - getUserList1

+ (RACSignal*)requestGetUserList1WithHub:(BOOL)hub params:(NSDictionary *)params;
+ (RACSignal*)requestGetUserList1WithHub:(BOOL)hub ;

#pragma mark - getUserList2

+ (RACSignal*)requestGetUserList2WithHub:(BOOL)hub params:(NSDictionary *)params;
+ (RACSignal*)requestGetUserList2WithHub:(BOOL)hub ;

@end
```

调用方法，下面要求用户数据和用户列表数据全部处理完成后在进行业务处理为例
```
@weakify(self)
[[RACSignal combineLatest:@[
    [HKUserRequest requestGetUserInfo2WithHub:NO], //获取用户信息
    [HKUserRequest requestGetUserList2WithHub:NO] //获取用户列表
    
] reduce:^id(NSDictionary *userInfo,NSDictionary *userlist){
    
    /**
     若返回正常，则userInfo格式为
     @{
        @"result":result, //响应解析类型对象
        @"data":data,  //data属性
        @"originResponse":originResponse //响应原始数据
     }
     
     若响应失败，则userInfo是一个NSError对象
     */
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    //用户信息
    if([userInfo isKindOfClass:NSDictionary.class]){
        data[@"userInfo"] = [userInfo valueForKey:@"data"];
    }
    
    //用户列表
    if([userlist isKindOfClass:NSDictionary.class]){
        data[@"userlist"] = [userlist valueForKey:@"data"];
    }
    
    return data;
    
}] subscribeNext:^(NSDictionary *data) {
    @strongify(self)
    
    HKUserPerson *userInfo = [data valueForKey:@"userInfo"];
    NSArray<HKUserPerson*> *userlist = [data valueForKey:@"userlist"];
    
    //TODO: 这里拿到接口请求的数据进行业务处理
}];
```

# Author

devjackcat@163.com