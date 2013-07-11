NSRuntime
=========

An Objective-C runtime toolkit. Method swizzling, dynamically creating and working with classes, etc. Ain't nobody got time to be readin runtime docs.

Do things like this:

```obj-c
NSArray *protocolNames = [[NSRuntime sharedRuntime] protocolNamesForClass:[UITableViewController class] 
                                                         includeInherited:YES];
NSArray *propertyNames = [[NSRuntime sharedRuntime] propertyNamesForClass:[UITableViewController class] 
                                                         includeInherited:YES];
                                                         
NSLog(@"\n%@ Protocols: %@", NSStringFromClass(classToInspect), protocolNames);
NSLog(@"\n%@ Properties: %@", NSStringFromClass(classToInspect), propertyNames);
```