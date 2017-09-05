package com.biffnstein.cordova.eventlist;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract.Attendees;
import android.text.format.DateUtils;

public class EventList extends CordovaPlugin {
	
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		try {
			if (action.equals("findByDateRange")) {
				ContentResolver contentResolver = this.webView.getContext().getContentResolver();
				
				DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				StringBuilder message = new StringBuilder();
				message.append("[");
				
				Uri.Builder builder = Uri.parse("content://com.android.calendar/instances/when").buildUpon();
			    long now = new Date().getTime();

			    ContentUris.appendId(builder, now);
			    ContentUris.appendId(builder, now + (DateUtils.DAY_IN_MILLIS * 7));

			    Cursor eventCursor = contentResolver.query(builder.build(),
			    	new String[]  { "_id", "title", "eventLocation", "begin", "end", "allDay"}, null,//"Events.calendar_id=" + id,
			        null, "startDay ASC, startMinute ASC");
			        
		        boolean isFirst = true;
		        while (eventCursor.moveToNext()) {
		        	int _id = eventCursor.getInt(0);// + 1;
		        	String title = eventCursor.getString(1);
		        	String location = eventCursor.getString(2);
		        	Date startDate = new Date(eventCursor.getLong(3));//.getString(3);
		        	Date endDate = new Date(eventCursor.getLong(4));//.getString(4);
		        	String allDay = !eventCursor.getString(5).equals("0") ? "true" : "false";
		        	
		        	Cursor participantsCursor = contentResolver.query(Uri.parse("content://com.android.calendar/attendees"),
		        		new String[] { "event_id", "attendeeName", "attendeeEmail" },Attendees.EVENT_ID + "=" + _id,
		        		null, null);
		        	
		        	StringBuilder participants = new StringBuilder();
		        	participants.append("[");
		        	boolean firstParticipant = true;
		        	while(participantsCursor.moveToNext()) {
		        		String participantName = participantsCursor.getString(1);
		        		String participantEmail = participantsCursor.getString(2);
		        		
		        		if (!firstParticipant) {
		        			participants.append(",");
		        		}
		        		participants.append("{\"name\":\"" + participantName + "\",\"email\":\"" + participantEmail + "\"}");
		        		firstParticipant = false;
		        	}
		        	participants.append("]");
		        	
		        	if (!isFirst) {
		        		message.append(",");
		        	}
		        	message.append("{\"id\":" + _id + ",\"title\":\"" + title + "\",\"location\":\"" + location + "\",\"startDate\":\"" + df.format(startDate) + "\",\"endDate\":\"" + df.format(endDate) + "\",\"participants\":" + participants + ",\"allDay\":\"" + allDay + "\"}");
		        	isFirst = false;
		        }
			    message.append("]");
				
				callbackContext.success(new JSONArray(message.toString()));
				
				return true;
			}
		} catch(Exception e) {
			System.err.println("Exception: " + e.getMessage());
		}

		return false;
	}
}
