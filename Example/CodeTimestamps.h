//
//  CodeTimestamps.h
//
//  Created by Tyler Neylon on 12/29/10.
//
//  Functions to assist in debugging.
//
//  Sample usage, for timing within a single function/method:
//
//   - (void)myMethod {
//     LogTimestampStartChunk;
//     /* do stuff */
//     LogTimestampMidChunk;
//     /* do stuff */
//     LogTimestampMidChunk;
//     /* do stuff */
//     LogTimestampEndChunk;
//   }
//
//  For simpler time measurements between any two code points,
//  just use LogTimestamp; for example:
//
//   - (void)myMethod {
//     LogTimestamp;
//     /* do stuff */
//     LogTimestamp;
//   }
//
//  All these macros measure time intervals down to the nanosecond,
//  and the chunk methods provide aggregated feedback.  It can be very
//  useful to use the chunk methods in several methods at once, to help
//  understand which is eating the most time, and why.
//

#import <Foundation/Foundation.h>

// Comment out this line to disable timestamp logging.
#define USE_TIMESTAMPS 1

// How often timing data is output to the logs.
#define kLogTimeInterval 10.0

// Macro to give us an efficient one-time function call.
// The token trickiness is from here:
// http://bit.ly/fQ6Glh
#define TokenPasteInternal(x,y) x ## y
#define TokenPaste(x,y) TokenPasteInternal(x,y)
#define UniqueTokenMacro TokenPaste(unique,__LINE__)
#define OneTimeCall(x) \
{ static BOOL UniqueTokenMacro = NO; \
if (!UniqueTokenMacro) {x; UniqueTokenMacro = YES; }}

// Speed performance-tuning functions & macros.
void LogTimeStampInMethod(const char *fnName, int lineNum);
void LogTimestampChunkInMethod(const char *fnName, int lineNum, BOOL isStart, BOOL isEnd);
void printAllLogs();
#ifdef USE_TIMESTAMPS

#define LogTimestamp LogTimeStampInMethod(__FUNCTION__, __LINE__)
#define LogTimestampStartChunk LogTimestampChunkInMethod(__FUNCTION__, __LINE__, YES, NO)
#define LogTimestampMidChunk LogTimestampChunkInMethod(__FUNCTION__, __LINE__, NO, NO)
#define LogTimestampEndChunk LogTimestampChunkInMethod(__FUNCTION__, __LINE__, NO, YES)

#else

#define LogTimestamp
#define LogTimestampStartChunk
#define LogTimestampMidChunk
#define LogTimestampEndChunk

#endif

#ifndef PrintName
#define PrintName NSLog(@"%s", __FUNCTION__)
#endif

