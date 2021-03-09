global class ESWFieldServiceBookAppointment {
    @InvocableMethod
    global static List<ESWFieldServiceBookAppointmentResult> bookAppointment(List<ESWFieldServiceBookAppointmentParameters> parameterList) {
        List<ESWFieldServiceBookAppointmentResult> results = new List<ESWFieldServiceBookAppointmentResult>();
        
        for(ESWFieldServiceBookAppointmentParameters parameters : parameterList) {
            ESWFieldServiceBookAppointmentResult result = new ESWFieldServiceBookAppointmentResult();
            ServiceAppointment appointment = parameters.serviceAppointment;
            String originalAppointmentId = appointment.Id;
            System.Savepoint savepoint = Database.setSavepoint();
            try {
                // Find the slot that matches the interval.
                OperatingHours operatingHours = [SELECT Name, Id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE Id =: parameters.operatingHoursId LIMIT 1];
                TimeZone timezone = UserInfo.getTimeZone();
                
                DateTime originalStartTime = appointment.EarliestStartTime;
                DateTime originalDueDate = appointment.DueDate;
                DateTime originalArrivalWindowStartTime = appointment.ArrivalWindowStartTime;
                DateTime originalArrivalWindowEndTime = appointment.ArrivalWindowEndTime;
                
                parameters.timeslotFinish = parameters.timeslotFinish.addSeconds(timezone.getOffset(parameters.timeslotFinish) / -1000);
                parameters.timeslotBegin = parameters.timeslotBegin.addSeconds(timezone.getOffset(parameters.timeslotBegin) / -1000);
                
                // Update service appointment so that the slot validation searches in the correct range.
                appointment.ArrivalWindowEndTime = parameters.timeslotFinish.addHours(0);
                appointment.ArrivalWindowStartTime = parameters.timeslotBegin.addHours(0);
                
                appointment.EarliestStartTime = parameters.timeslotBegin.addDays(-1);
                //appointment.EarliestStartTime = parameters.timeslotBegin.addHours(-1);
                appointment.DueDate = parameters.timeslotFinish.addDays(1);
                //appointment.DueDate = parameters.timeslotFinish.addHours(1);                
                
                upsert appointment;
                FSL.ScheduleResult scheduleResult = FSL.ScheduleService.Schedule(parameters.policyId, appointment.Id);
                
                if(scheduleResult == null) {
                    result.success = false;
                    result.message = 'That timeslot is no longer available.';
                    appointment.EarliestStartTime = originalStartTime;
                    appointment.DueDate = originalDueDate;
                    appointment.ArrivalWindowStartTime = originalArrivalWindowStartTime;
                    appointment.ArrivalWindowEndTime = originalArrivalWindowEndTime;
                    Database.rollback(savepoint);
                    appointment.Id = originalAppointmentId;
                } else {
                    result.success = true;
                }
            } catch(Exception e) {
              result.success = false;
              result.message = e.getMessage();
              Database.rollback(savepoint);
              appointment.Id = originalAppointmentId;
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    global class ESWFieldServiceBookAppointmentResult {
        @InvocableVariable
        global boolean success;
        
        @InvocableVariable
        global string message;
    }
    
    global class ESWFieldServiceBookAppointmentParameters {
        @InvocableVariable(required=true)
        global ServiceAppointment serviceAppointment;
        
        @InvocableVariable(required=true)
        global Id policyId;
        
        @InvocableVariable(required=true)
        global Id operatingHoursId;
                
        @InvocableVariable(required=true)
        global DateTime timeslotBegin;
        
        @InvocableVariable(required=true)
        global DateTime timeslotFinish;
    }
}