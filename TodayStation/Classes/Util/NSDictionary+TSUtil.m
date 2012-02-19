//
//  NSDictionary+TSUtil.m
//  TodayStation
//
//  Created by Eric Huss on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+TSUtil.h"

@implementation NSDictionary (TSUtil)
//	syntax of path similar to Java: record.array[N].item
//	items are separated by . and array indices in []
//	example: a.b[N][M].c.d

// Number To String will convert NSNumber to an NSString.
// This is because SBJson "conveniently" converts things it thinks
// are numbers to strings, which isn't so convenient.
- (id)tsObjectForKeyPath:(NSString *)inKeyPath numberToString:(BOOL)nts
{
	NSArray	*components = [inKeyPath componentsSeparatedByString:@"."]	;
	int		i, j, n = [components count], m	;
	id		curContainer = self	;
	
    for (i=0; i<n ; i++)	{
        NSString	*curPathItem = [components objectAtIndex:i]	;
        NSArray		*indices = [curPathItem componentsSeparatedByString:@"["]	;
        
        m = [indices count]	;
        if (m == 1)	{	// no [ -> object is a dict or a leave
            curContainer = [curContainer objectForKey:curPathItem]	;
        }
        else	{
            //	indices is an array of string "arrayKeyName" "i1]" "i2]" "i3]"
            //	arrayKeyName equal to curPathItem
            
            if (![curContainer isKindOfClass:[NSDictionary class]])
                return nil	;
            
            curPathItem = [curPathItem substringToIndex:[curPathItem rangeOfString:@"["].location]	;
            curContainer = [curContainer objectForKey:curPathItem]	;	
            
            for(j=1;j<m;j++)	{
                int	index = [[indices objectAtIndex:j] intValue]	;
                
                if (![curContainer isKindOfClass:[NSArray class]])
                    return nil	;
                
                if (index >= [curContainer count])
                    return nil	;
                
                curContainer = [curContainer objectAtIndex:index];	
            }
        }
        
    }
    
    if (nts && [curContainer isKindOfClass:[NSNumber class]]) {
        curContainer = [curContainer stringValue];
    }
    return curContainer	;
}

@end
