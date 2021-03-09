public class newTimeOffRequestController {

        public String getToDate() {
                return gblToDate;
        }

        public void setToDate(String value) {
                gblToDate = value;
        }
        public void setFromDate(String value) {
                gblFromDate = value;
        }

    public String getFromDate() {
        return gblFromDate;
    }

        public Double getPendingDays() {
                return pendingDays;
        }

        public TimeOffRequest getCurrentTimeOffRequest() {
            return this.currTimeOffRequest;
        }

        public Time_Off_Info__c getBalance() {
	    return pto_web_services.get_time_off_info_for_current_user();
        }

        public Double pendingDays = 0;
        public TimeOffRequest currTimeOffRequest = new TimeOffRequest(null, 'Illegal Status');
        public String gblFromDate = 'from date';
        public String gblToDate = 'to date';

    public PageReference makeRequest() {
        Time_Off_Request__c tor = new Time_Off_Request__c();

        Date fromDate = Date.valueOf(gblFromDate);
        Date toDate = Date.valueOf(gblToDate);

        tor.Start_Date__c = fromDate;
        tor.End_Date__c = toDate;
        tor.I_accept_terms__c = true;

        insert tor;
        currTimeOffRequest = new TimeOffRequest(tor.Id, 'Not Submitted');
/*
        commit;
*/
        return null;
    }

    public void refresh() {
        
    }

    public class TimeOffRequest {
        Id id;
        String status;

        public TimeOffRequest(Id id, String status) {
            this.id = id;
            this.status= status;
        }

        public Id getId() {
            return this.id;
        }

        public String getStatus() {
            return this.status;
        }

        private Integer getDayOfTheWeek(Date day) {
                Date sunday = day.toStartOfWeek();
            Integer dayDiff = sunday.daysBetween(day);
            return dayDiff;
        }

        private Boolean isHoliday(Date day) {
                return ([Select Count() From Holiday_Calendar__c Where Date__c = :day] == 1);
        }

        private Integer getNumberOfDays(Time_Off_Request__c tor) {
                Integer days = tor.Start_Date__c.daysBetween(tor.End_Date__c) + 1;
            Integer numberOfDays = 0;
            for (Integer i=0;i<days;i++) {
                Date day = tor.Start_Date__c.addDays(i);
                Integer dow = getDayOfTheWeek(day);
                if (dow != 0 && dow != 6 && !isHoliday(day)) {
                        numberOfDays++;
                }
            }
            return numberOfDays;
        }





    }  //End Class


    public Time_Off_Request__c getTimeOffRequest(ID id) {
                return  [Select Id, Name, Start_Date__c, End_Date__c, Status__c, Requestor__c,
                        LastModifiedDate, LastModifiedById, CreatedById, CreatedDate, 
                        (Select Id, ActorId, Actor.Name, Actor.FirstName, toLabel(StepStatus), Comments,
                        CreatedDate From ProcessSteps Order By CreatedDate)       
                        From Time_Off_Request__c Where Id = :id];
    }
}