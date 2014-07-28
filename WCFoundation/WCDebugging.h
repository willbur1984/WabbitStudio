//
//  WCDebugging.h
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//

#ifndef __WC_FOUNDATION_DEBUGGING__
#define __WC_FOUNDATION_DEBUGGING__

#ifdef DEBUG

#define WCLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#define WCLog(...)

#endif

#define WCLogObject(objectToLog) WCLog(@"%@",objectToLog)

#define WCLogNSRect(rectToLog) WCLogObject(NSStringFromRect(rectToLog))
#define WCLogNSSize(sizeToLog) WCLogObject(NSStringFromSize(sizeToLog))
#define WCLogNSPoint(pointToLog) WCLogObject(NSStringFromPoint(pointToLog))

#define WCLogCGRect(rectToLog) WCLogObject(NSStringFromCGRect(rectToLog))
#define WCLogCGSize(sizeToLog) WCLogObject(NSStringFromCGSize(sizeToLog))
#define WCLogCGPoint(pointToLog) WCLogObject(NSStringFromCGPoint(pointToLog))
#define WCLogCGFloat(floatToLog) WCLog(@"%f",floatToLog)

#endif
