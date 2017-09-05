//
//  CDVEventList.h
//  Author: Biff Imbierowicz
//  Date: 6/20/2013
//  Notes:
//    CDVEventList was designed around similar setup as Felix Montanez's calendarPlugin
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>


@interface CDVEventList : CDVPlugin

@property (nonatomic, retain) EKEventStore* eventStore;

- (void)initEventStoreWithCalendarCapabilities;

-(NSArray*)findEKEventsByDate: (NSDate *)startDate
                         endDate: (NSDate *)endDate;

// EventList Instance methods
- (void)findByDateRange:(CDVInvokedUrlCommand*)command;

@end
