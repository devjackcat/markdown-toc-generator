//
//  main.m
//  toc_generator
//
//  Created by 永平 on 2020/3/24.
//  Copyright © 2020 yongping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        if(!argv[1]){
            printf("sourcePath 必传\n");
            return 0;
        }
        
        NSString *sourceFile = @(argv[1]);
        if(![[NSFileManager defaultManager] fileExistsAtPath:sourceFile]) {
            printf("%s 文件不存在\n",argv[1]);
        }
        
        //解析之前，先删除非#开头的行
        NSString *source = [NSString stringWithContentsOfFile:sourceFile encoding:NSUTF8StringEncoding error:nil];
        NSMutableString *sourceBuilder = [NSMutableString stringWithString:source];
        //删除代码块 ```   ````
        NSArray *list = [sourceBuilder arrayOfCaptureComponentsMatchedByRegex:@"```(\\s|.)*?```"];
        for (NSArray *items in list) {
            NSString *commentBlock = items[0];
            NSRange commentBlockRange = [sourceBuilder rangeOfString:commentBlock];
            [sourceBuilder deleteCharactersInRange:commentBlockRange];
        }
        
        //拆分行
        NSArray *lines = [sourceBuilder componentsSeparatedByString:@"\n"];
        NSMutableArray *tocLines = [NSMutableArray array];
        for (NSString *line in lines) {
            if([line hasPrefix:@"#"]){
                [tocLines addObject:line];
            }
        }
        
        //将每个link都添加到这里，用于计算出现次数，在link后面添加”-N“
        NSMutableDictionary *contentCountDict = [NSMutableDictionary dictionary];
        
        NSMutableString *tocBuilder = [NSMutableString string];
        [tocBuilder appendString:@"目录内容\n\n"];
        for (NSString *toc in tocLines) {
            list = [toc arrayOfCaptureComponentsMatchedByRegex:@"([#]+)(?:\\s)(\\S*)"];
            NSString *jinNum = list[0][1];
            NSString *content = list[0][2];
            for (NSInteger index = 0; index < jinNum.length-1; index++) {
                [tocBuilder appendString:@"    "];
            }
            NSString *link = content;
            //去除括号
            link = [link stringByReplacingOccurrencesOfString:@"(" withString:@""];
            link = [link stringByReplacingOccurrencesOfString:@")" withString:@""];
            link = [link stringByReplacingOccurrencesOfString:@"[" withString:@""];
            link = [link stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            //已出现次数
            NSInteger count = [[contentCountDict valueForKey:link] integerValue];
            NSString *tempLink = link;
            if(count > 0){
                tempLink = [NSString stringWithFormat:@"%@-%zd",tempLink,count];
            }
            [tocBuilder appendFormat:@"* [%@](#%@)\n",content,tempLink];
            contentCountDict[link] = @(count + 1);
        }
        
        printf("%s",[tocBuilder cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return 0;
}
