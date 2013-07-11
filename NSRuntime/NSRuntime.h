//
//  NSRuntime.h
//
//  Created by Christopher Constable on 5/27/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRuntime : NSObject

+ (NSRuntime *)sharedRuntime;

- (NSArray *)methodNamesForClass:(Class)aClass;
- (NSArray *)propertyNamesForClass:(Class)aClass;
- (NSArray *)protocolNamesForClass:(Class)aClass includeInherited:(BOOL)shouldIncludeInherited;
- (NSArray *)propertyNamesForProtocol:(Protocol *)aProtocol;

- (BOOL)swizzleInstanceMethod:(SEL)originalSelector
                    fromClass:(Class)objectClass
                withNewMethod:(SEL)newSelector;

- (BOOL)swizzleClassMethod:(SEL)originalSelector
                 fromClass:(Class)objectClass
             withNewMethod:(SEL)newSelector;

- (BOOL)swizzleInstanceMethod:(SEL)originalSelector
     fromClassClusterInstance:(id)objectInstance
                withNewMethod:(SEL)newSelector;

@end
