//
//  CDVEventList.m
//  Author: Biff Imbierowicz
//  Date: 6/20/2013
//  Notes:
//    CDVEventList was designed around similar setup as Felix Montanez's calendarPlugin
//

#import "CDVEventList.h"
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation CDVEventList
@synthesize eventStore;

#pragma mark Initialisation functions

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    /*self = (CDVEventList*)[super initWithWebView:theWebView];*/
    if (self) {
        [self initEventStoreWithCalendarCapabilities];
    }
    return self;
}

- (void)initEventStoreWithCalendarCapabilities {
    __block BOOL accessGranted = NO;
    eventStore= [[EKEventStore alloc] init];
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        self.eventStore = eventStore;
    }
}

#pragma mark Helper Functions

-(NSArray*)findEKEventsByDate: (NSDate *)startDate
                         endDate: (NSDate *)endDate {
    NSArray *datedEvents = [self.eventStore eventsMatchingPredicate:[eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]];
    
    return datedEvents;
}

#pragma mark Cordova functions

-(void)findByDateRange:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString *startDate  = [command.arguments objectAtIndex:0];
    NSString *endDate    = [command.arguments objectAtIndex:1];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *idDF = [[NSDateFormatter alloc] init];
    [idDF setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *myStartDate = [df dateFromString:startDate];
    NSDate *myEndDate = [df dateFromString:endDate];
    
    NSArray *matchingEvents = [self findEKEventsByDate:myStartDate endDate:myEndDate];
    
    NSMutableArray *finalResults = [[NSMutableArray alloc] initWithCapacity:matchingEvents.count];
    // Stringify the results - Cordova can't deal with Obj-C objects
    for (EKEvent * event in matchingEvents) {
        NSMutableArray *participants = [[NSMutableArray alloc] initWithCapacity:event.attendees.count];
        
        for (EKParticipant * participant in event.attendees) {
            NSLog(@"Participant Name: %@", participant.name);
            NSLog(@"Participant URL: %@", [participant.URL absoluteString]);
            NSMutableDictionary *attendee = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                             participant.name == NULL ? @"" : participant.name, @"name",
                                             participant.URL == NULL ? @"" : [participant.URL absoluteString], @"url",
                                             participant.description == NULL ? @"" : participant.description, @"description", nil];
            
            [participants addObject:attendee];
        }
        
        NSMutableDictionary *entry = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [NSString stringWithFormat:@"%@:%@", event.eventIdentifier == NULL ? @"" : event.eventIdentifier, event.startDate == NULL ? @"" : [idDF stringFromDate:event.startDate]], @"id",
                                      event.title == NULL ? @"" : event.title, @"title",
                                      event.location == NULL ? @"" : event.location, @"location",
                                      event.startDate == NULL ? @"" : [df stringFromDate:event.startDate], @"startDate",
                                      event.endDate == NULL ? @"" : [df stringFromDate:event.endDate], @"endDate",
                                      participants, @"participants",
                                      event.allDay ? @"true" : @"false", @"allDay", nil];
        
        [finalResults addObject:entry];
    }
    
    if (finalResults.count > 0) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus: CDVCommandStatus_OK
                                   messageAsArray:finalResults
                                   ];
        /*[self writeJavascript:[result toSuccessCallbackString:command.callbackId]];*/
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        /*[self writeJavascript:[result toErrorCallbackString:command.callbackId]];*/
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

@end
