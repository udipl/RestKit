//
//  RKFormURLSerialization.m
//  RestKit
//
//  Created by Blake Watters on 9/4/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RKFormURLSerialization.h"

@implementation RKFormURLSerialization

+ (id)objectFromData:(NSData *)data error:(NSError **)error
{
    NSString *string = [NSString stringWithUTF8String:[data bytes]];
    return RKDictionaryFromURLEncodedStringWithEncoding(string, NSUTF8StringEncoding);
}

+ (NSData *)dataFromObject:(id)object error:(NSError **)error
{
    NSString *string = RKURLEncodedStringFromDictionaryWithEncoding(object, NSUTF8StringEncoding);
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end

NSDictionary *RKDictionaryFromURLEncodedStringWithEncoding(NSString *URLEncodedString, NSStringEncoding encoding)
{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for (NSString *keyValuePairString in [URLEncodedString componentsSeparatedByString:@"&"]) {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        NSString *key = [[keyValuePairArray objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
        NSString *value = [[keyValuePairArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
        
        // URL spec says that multiple values are allowed per key
        id results = [queryComponents objectForKey:key];
        if (results) {
            if ([results isKindOfClass:[NSMutableArray class]]) {
                [(NSMutableArray *)results addObject:value];
            } else {
                // On second occurrence of the key, convert into an array
                NSMutableArray *values = [NSMutableArray arrayWithObjects:results, value, nil];
                [queryComponents setObject:values forKey:key];
            }
        } else {
            [queryComponents setObject:value forKey:key];
        }
        [results addObject:value];
    }
    return queryComponents;
}

extern NSString * AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);
NSString *RKURLEncodedStringFromDictionaryWithEncoding(NSDictionary *dictionary, NSStringEncoding encoding)
{
    return AFQueryStringFromParametersWithEncoding(dictionary, encoding);
}