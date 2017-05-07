//
//  DatabaseMacro.h
//  YZTools<https://github.com/yangyongzheng/YZTools>
//
//  Created by yangyongzheng on 2017/4/22.
//  Copyright © 2017年 yyz. All rights reserved.
//

#ifndef DatabaseMacro_h
#define DatabaseMacro_h

#define RESOURCE_EXTENSION_PLIST @"plist"

#define StringNonEmptyCheck(object) (([object isKindOfClass:[NSString class]] && object.length) ? YES : NO)
#define ArrayNonEmptyCheck(object) (([object isKindOfClass:[NSArray class]] && object.count) ? YES : NO)
#define MutableArrayNonEmptyCheck(object) (([object isKindOfClass:[NSMutableArray class]] && object.count) ? YES : NO)
#define DictionaryNonEmptyCheck(object) (([object isKindOfClass:[NSDictionary class]] && object.count) ? YES : NO)
#define MutableDictionaryNonEmptyCheck(object) (([object isKindOfClass:[NSMutableDictionary class]] && object.count) ? YES : NO)

// condition为true通过，flase时打印errorDesc
#define DBAssertTrue(condition, errorDesc)      \
        do {                                \
            if (!condition && StringNonEmptyCheck(errorDesc)) {     \
                NSLog(@"%@：%@", [NSThread currentThread], errorDesc);    \
            }                               \
        } while (0);                        \
// condition为false时通过，true时打印correctDesc
#define DBAssertFalse(condition, correctDesc)   \
        do {                                \
            if (condition && StringNonEmptyCheck(correctDesc)) {    \
                NSLog(@"%@：%@", [NSThread currentThread], correctDesc);  \
            }                               \
        } while (0);                        \

#define DBLog(object) NSLog(@"%@：%@", [NSThread currentThread], object)

#endif /* DatabaseMacro_h */
