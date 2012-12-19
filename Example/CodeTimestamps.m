//
//  CodeTimestamps.m
//
//  Created by Tyler Neylon on 12/29/10.
//
//
//  Reference for the timestamp functions:
//    http://developer.apple.com/library/mac/#qa/qa2004/qa1398.html
//

// This code would be cleaner if it used NSObject+Be for memory
// management, but I've decided to use standard methods instead,
// to make it easier to use CodeTimestamps.{h,m} on their own.

// I'm also aware that the Build & Analyze tool produces some warnings
// for this code, but I've examined them and I don't think they're legit problems.
// I would like to tweak things to get rid of the warnings with zero performance
// cost, but that's a low priority for me, so I may not do it anytime soon.

#import "CodeTimestamps.h"

#import <mach/mach.h>
#import <mach/mach_time.h>

#define kNumSlowestChunks 5
#define kNumMidPoints 5

static NSMutableArray *chunkData = nil;

@class ChunkTimeInterval;

@interface LogHelper : NSObject {
@private
  NSTimer *logTimer;
  NSMutableArray *pendingLines;
  NSMutableArray *slowestChunks;
}

+ (LogHelper *)sharedInstance;

- (void)startLoggingTimer;
- (void)printOutTimingData:(NSTimer *)timer;
- (void)addLogString:(NSString *)newString;

- (void)maybeAddTimeIntervalAsSlowest:(ChunkTimeInterval *)timeInterval;
- (void)logSlowestChunks;

- (void)consolidateTimeIntervals:(NSMutableArray *)timeIntervals;

@end

@interface ChunkStamp : NSObject {
 @public
  const char *fnName;
  int lineNum;
  uint64_t timestamp;
  NSThread *thread;
  BOOL isStart;
  BOOL isEnd;
}

- (NSComparisonResult)compare:(id)other;

@end

void printAllLogs() {
	[[LogHelper sharedInstance] printOutTimingData:nil];
}

uint64_t NanosecondsFromTimeInterval(uint64_t timeInterval) {
  static struct mach_timebase_info timebase_info;
  OneTimeCall(mach_timebase_info(&timebase_info));
  timeInterval *= timebase_info.numer;
  timeInterval /= timebase_info.denom;
  return timeInterval;
}

// This function needs to be _fast_ to minimize interfering with
// timing data.  So we don't actually NSLog during it, using LogHelper.
void LogTimeStampInMethod(const char *fnName, int lineNum) {
  OneTimeCall([[LogHelper sharedInstance] startLoggingTimer]);
  static uint64_t lastTimestamp = 0;
  uint64_t thisTimestamp = mach_absolute_time();
  NSString *logStr = nil;
  if (lastTimestamp == 0) {
    logStr = [NSString stringWithFormat:@"* %s:%4d", fnName, lineNum];
  } else {
    uint64_t elapsed = NanosecondsFromTimeInterval(thisTimestamp - lastTimestamp);
    logStr = [NSString stringWithFormat:@"* %s:%4d - %9llu nsec since last timestamp",
              fnName, lineNum, elapsed];
  }
  [[LogHelper sharedInstance] addLogString:logStr];
  lastTimestamp = thisTimestamp;
}

void InitChunkData() {
  if (chunkData) return;
  chunkData = [NSMutableArray new];
}

void LogTimestampChunkInMethod(const char *fnName, int lineNum, BOOL isStart, BOOL isEnd) {
  OneTimeCall(InitChunkData());
  OneTimeCall([[LogHelper sharedInstance] startLoggingTimer]);
  ChunkStamp *stamp = [[ChunkStamp new] autorelease];
  stamp->fnName = fnName;
  stamp->lineNum = lineNum;
  stamp->timestamp = mach_absolute_time();
  stamp->thread = [NSThread currentThread];
  stamp->isStart = isStart;
  stamp->isEnd = isEnd;
  @synchronized(chunkData) {
    [chunkData addObject:stamp];
  }
}

@interface ChunkTimeInterval : NSObject {
@public
  NSString *intervalName;  // strong
  uint64_t nanoSecsElapsed;
}
- (id)initFromStamp:(ChunkStamp *)stamp1 toStamp:(ChunkStamp *)stamp2;
@end

@implementation ChunkTimeInterval
- (id)initFromStamp:(ChunkStamp *)stamp1 toStamp:(ChunkStamp *)stamp2 {
  if (![super init]) return nil;
  intervalName = [[NSString stringWithFormat:@"%s:%d - %s:%d",
                   stamp1->fnName, stamp1->lineNum, stamp2->fnName, stamp2->lineNum] retain];
  nanoSecsElapsed = NanosecondsFromTimeInterval(stamp2->timestamp - stamp1->timestamp);
  return self;
}
- (void)dealloc {
  [intervalName release];
  [super dealloc];
}
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %p> %@ %llu", [self class], self, intervalName, nanoSecsElapsed];
}
@end



@implementation LogHelper

+ (LogHelper *)sharedInstance {
  static LogHelper *instance = nil;
  if (instance == nil) instance = [LogHelper new];
  return instance;
}

- (id)init {
  if (![super init]) return nil;
  pendingLines = [NSMutableArray new];
  slowestChunks = [NSMutableArray new];
  return self;
}

- (void)startLoggingTimer {
  if (logTimer) return;
  logTimer = [NSTimer scheduledTimerWithTimeInterval:kLogTimeInterval
                                              target:self
                                            selector:@selector(printOutTimingData:)
                                            userInfo:nil
                                             repeats:YES];
}
- (void)printOutTimingData:(NSTimer *)timer {
  BOOL didLogAnything = NO;
  
  // Handle pending lines.
  if ([pendingLines count]) {
    NSLog(@"==== Start non-chunk timestamp data (from \"LogTimestamp\") ====");
    for (NSString *logString in pendingLines) {
      NSLog(@"%@", logString);
    }
    [pendingLines removeAllObjects];
    didLogAnything = YES;
  }
    
  // Handle chunk data.
  if ([chunkData count]) {
    NSLog(@"==== Start chunk timestamp data (from \"LogTimestamp{Start,Mid,End}Chunk\") ====");
    @synchronized(chunkData) {
      [chunkData sortUsingSelector:@selector(compare:)];
      NSThread *thread = nil;
      NSMutableArray *timeIntervals = [NSMutableArray array];
      uint64_t totalNanoSecsThisChunk;
      uint64_t totalNanoSecsThisThread;
      int numRunsThisThread;
      BOOL thisThreadHadChunks = NO;
      BOOL midChunk = NO;
      ChunkStamp *lastStamp = nil;
      NSString *chunkName = nil;
      for (ChunkStamp *chunkStamp in chunkData) {
        if (chunkStamp->thread != thread) {
          if (thisThreadHadChunks) {
            NSLog(@"++ Chunk = %@, avg time = %.4fs", chunkName,
                  (float)totalNanoSecsThisThread / numRunsThisThread / 1e9);
          }
          
          thread = chunkStamp->thread;
          NSLog(@"--- Data for thread %p ---", thread);
          [timeIntervals removeAllObjects];
          midChunk = NO;
          thisThreadHadChunks = NO;
          totalNanoSecsThisChunk = 0;
          totalNanoSecsThisThread = 0;
          numRunsThisThread = 0;
        }
        if (chunkStamp->isStart) {
          if (midChunk) {
            NSLog(@"ERROR: LogTimestampStartChunk hit twice without a LogTimestampEndChunk between them.");
          }
          midChunk = YES;
          thisThreadHadChunks = YES;
          chunkName = [NSString stringWithFormat:@"%s:%d", chunkStamp->fnName, chunkStamp->lineNum];
        } else if (midChunk) {
          ChunkTimeInterval *timeInterval = [[[ChunkTimeInterval alloc] initFromStamp:lastStamp toStamp:chunkStamp] autorelease];
          [timeIntervals addObject:timeInterval];
          totalNanoSecsThisChunk += timeInterval->nanoSecsElapsed;
          if (chunkStamp->isEnd) {
            totalNanoSecsThisThread += totalNanoSecsThisChunk;
            numRunsThisThread++;
            chunkName = [NSString stringWithFormat:@"%@ - %s:%d", chunkName, chunkStamp->fnName, chunkStamp->lineNum];
            NSLog(@"+ Chunk = %@, time = %.4fs", chunkName, (float)totalNanoSecsThisChunk/1e9);
            
            [self consolidateTimeIntervals:timeIntervals];
            for (int i = 0; i < [timeIntervals count] && i < kNumMidPoints; ++i) {
              ChunkTimeInterval *timeInterval = [timeIntervals objectAtIndex:i];
              int percentTime = (int)round(100.0 * (float)timeInterval->nanoSecsElapsed / totalNanoSecsThisChunk);
              NSLog(@"    %2d%% in %@", percentTime, timeInterval->intervalName);
            }
            
            ChunkTimeInterval *totalInterval = [[ChunkTimeInterval new] autorelease];
            totalInterval->intervalName = [chunkName retain];
            totalInterval->nanoSecsElapsed = totalNanoSecsThisChunk;
            [self maybeAddTimeIntervalAsSlowest:totalInterval];
            
            [timeIntervals removeAllObjects];
            totalNanoSecsThisChunk = 0;
            midChunk = NO;
          }
        }
        lastStamp = chunkStamp;
      }
      if (thisThreadHadChunks) {
        NSLog(@"++ Chunk = %@, avg time = %lld nsec", chunkName,
              totalNanoSecsThisThread / numRunsThisThread);
      }
      [chunkData removeAllObjects];
    }
    didLogAnything = YES;
  }
  if (didLogAnything) {
    [self logSlowestChunks];
    NSLog(@"==== End timestamp data ====");
  }
}

- (void)addLogString:(NSString *)newString {
  [pendingLines addObject:newString];
}

- (void)maybeAddTimeIntervalAsSlowest:(ChunkTimeInterval *)timeInterval {
  if ([slowestChunks count] < kNumSlowestChunks ||
      ((ChunkTimeInterval *)[slowestChunks lastObject])->nanoSecsElapsed < timeInterval->nanoSecsElapsed) {
    [slowestChunks addObject:timeInterval];
    NSSortDescriptor *sortByTime = [[[NSSortDescriptor alloc] initWithKey:@"nanoSecsElapsed" ascending:NO] autorelease];
    [slowestChunks sortUsingDescriptors:[NSArray arrayWithObject:sortByTime]];
    if ([slowestChunks count] > kNumSlowestChunks) [slowestChunks removeLastObject];
  }
}

- (void)logSlowestChunks {
  if ([slowestChunks count] == 0) return;
  NSLog(@"==== Slowest chunks so far ====");
  for (ChunkTimeInterval *timeInterval in slowestChunks) {
    NSLog(@"# Chunk = %@, time = %.4fs", timeInterval->intervalName, (float)timeInterval->nanoSecsElapsed/1e9);
  }
}

- (void)consolidateTimeIntervals:(NSMutableArray *)timeIntervals {
  NSSortDescriptor *sortByName = [[[NSSortDescriptor alloc] initWithKey:@"intervalName" ascending:YES] autorelease];
  [timeIntervals sortUsingDescriptors:[NSArray arrayWithObject:sortByName]];
  
  NSMutableArray *consolidatedIntervals = [NSMutableArray array];
  NSString *lastName = nil;
  ChunkTimeInterval *thisInterval = nil;
  for (ChunkTimeInterval *timeInterval in timeIntervals) {
    if ([lastName isEqualToString:timeInterval->intervalName]) {
      thisInterval->nanoSecsElapsed += timeInterval->nanoSecsElapsed;
    } else {
      thisInterval = [[ChunkTimeInterval new] autorelease];
      thisInterval->intervalName = [timeInterval->intervalName retain];
      thisInterval->nanoSecsElapsed = timeInterval->nanoSecsElapsed;
      [consolidatedIntervals addObject:thisInterval];
    }
    lastName = timeInterval->intervalName;
  }
  [timeIntervals removeAllObjects];
  [timeIntervals addObjectsFromArray:consolidatedIntervals];
  
  NSSortDescriptor *sortByTime = [[[NSSortDescriptor alloc] initWithKey:@"nanoSecsElapsed" ascending:NO] autorelease];
  [timeIntervals sortUsingDescriptors:[NSArray arrayWithObject:sortByTime]];
}

@end

@implementation ChunkStamp

- (NSComparisonResult)compare:(id)other {
  ChunkStamp *otherStamp = (ChunkStamp *)other;
  if (thread != otherStamp->thread) {
    return (thread < otherStamp->thread ? NSOrderedAscending : NSOrderedDescending);
  }
  if (strcmp(fnName, otherStamp->fnName) != 0) {
    return (strcmp(fnName, otherStamp->fnName) < 0 ? NSOrderedAscending : NSOrderedDescending);
  }
  if (timestamp == otherStamp->timestamp) return NSOrderedSame;
  return (timestamp < otherStamp->timestamp ? NSOrderedAscending : NSOrderedDescending);
}

@end
