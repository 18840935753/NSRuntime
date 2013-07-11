//
//  NSRuntime.m
//
//  Created by Christopher Constable on 5/27/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import "NSRuntime.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSRuntime

+ (NSRuntime *)sharedRuntime
{
    static NSRuntime *runtime;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        runtime = [[NSRuntime alloc] init];
    });
    
    return runtime;
}

- (NSArray *)methodNamesForClass:(Class)aClass
{
    uint numMethods = 0;
    Method *methodList = class_copyMethodList(aClass, &numMethods);
    NSMutableArray *methods = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numMethods; i++) {
        const char *methodName = sel_getName(method_getName(methodList[i]));
        [methods addObject:[NSString stringWithUTF8String:methodName]];
    }
    
    NSArray *sortedMethods = [methods sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return sortedMethods;
}

- (NSArray *)propertyNamesForClass:(Class)aClass includeInherited:(BOOL)shouldIncludeInherited;
{
    NSMutableArray *names = [NSMutableArray array];
    uint propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertyCount);
    for (uint i = 0; i < propertyCount; i++) {
        [names addObject:[NSString stringWithUTF8String:property_getName(properties[i])]];
    }
    
    if (shouldIncludeInherited) {
        Class superClass = aClass;
        while ((superClass = class_getSuperclass(superClass))) {
            uint superPropertyCount = 0;
            objc_property_t *superProperties = class_copyPropertyList(superClass, &superPropertyCount);
            for (uint i = 0; i < superPropertyCount; i++) {
                [names addObject:[NSString stringWithUTF8String:property_getName(superProperties[i])]];
            }
        }
    }
    
    NSArray *sortedNames = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return sortedNames;
}

- (NSArray *)protocolNamesForClass:(Class)aClass includeInherited:(BOOL)shouldIncludeInherited;
{
    NSMutableArray *names = [NSMutableArray array];
    uint protocolCount = 0;
    __unsafe_unretained Protocol **protocolArray = class_copyProtocolList(aClass, &protocolCount);
    for (uint i = 0; i < protocolCount; i++) {
        [names addObject:NSStringFromProtocol(protocolArray[i])];
    }
    
    if (shouldIncludeInherited) {
        Class superClass = aClass;
        while ((superClass = class_getSuperclass(superClass))) {
            uint superProtocolCount = 0;
            __unsafe_unretained Protocol **superProtocolArray = class_copyProtocolList(superClass, &superProtocolCount);
            for (uint j = 0; j < superProtocolCount; j++) {
              [names addObject:NSStringFromProtocol(superProtocolArray[j])];
            }
        }
    }
    
    NSArray *sortedNames = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return sortedNames;
}

- (NSArray *)propertyNamesForProtocol:(Protocol *)aProtocol
{
    NSMutableArray *names = [NSMutableArray array];
    uint protocolPropertyCount = 0;
    objc_property_t *properties = protocol_copyPropertyList(aProtocol, &protocolPropertyCount);
    for (uint j = 0; j < protocolPropertyCount; j++) {
        [names addObject:[NSString stringWithUTF8String:property_getName(properties[j])]];
    }
    
    NSArray *sortedNames = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return sortedNames;
}

- (BOOL)swizzleInstanceMethod:(SEL)originalSelector
                    fromClass:(Class)objectClass
                withNewMethod:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(objectClass, originalSelector);
    Method newMethod = class_getInstanceMethod(objectClass, newSelector);
    
    // If the old method doesn't exist.
    if(class_addMethod(objectClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(objectClass, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
        
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
    
    return YES;
}

- (BOOL)swizzleClassMethod:(SEL)originalSelector
            fromClass:(Class)objectClass
        withNewMethod:(SEL)newSelector
{
    Method originalMethod = class_getClassMethod(objectClass, originalSelector);
    Method newMethod = class_getClassMethod(objectClass, newSelector);
    method_exchangeImplementations(originalMethod, newMethod);
    
    return YES;
}

// https://github.com/rubymaverick/EASwizzler
- (BOOL)swizzleInstanceMethod:(SEL)originalSelector
     fromClassClusterInstance:(id)objectInstance
                withNewMethod:(SEL)newSelector
{
    const char *classString = [[[objectInstance class] description] UTF8String];
    Class objectClass = objc_getClass(classString);

    Method originalMethod = class_getClassMethod(objectClass, originalSelector);
    Method newMethod = class_getClassMethod(objectClass, newSelector);
    method_exchangeImplementations(originalMethod, newMethod);
    
    return YES;
}

@end
