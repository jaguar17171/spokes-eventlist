EventList
======

> The `EventList` object provides functions to retrieve calendar events from iOS and Android.

Installation
============

Install this plugin using PhoneGap/Cordova CLI (iOS and Android)

    cordova plugin add https://github.com/jaguar17171/spokes-eventlist.git


Methods
-------

- EventList.findByDateRange

EventList.findByDateRange
=================

    EventList.findByDateRange(startDate, endDate, successCallback, errorCallback);

Description
-----------

Returns a list of calendar events with participants for a specified date range.


Supported Platforms
-------------------

- iOS
- Android

Quick Example
-------------

    EventList.findByDateRange('2014-04-07', '2014-04-14', function() {}, function() {});



    