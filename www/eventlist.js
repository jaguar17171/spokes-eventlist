var EventList = function() {
  
};

EventList.prototype.findByDateRange = function(startDate, endDate, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, 'EventList', 'findByDateRange', [startDate, endDate]);
}

module.exports = new EventList();
