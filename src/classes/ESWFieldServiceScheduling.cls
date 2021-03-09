global class ESWFieldServiceScheduling {
    @InvocableMethod
    global static List<string> getSlots(List<ESWSchedulingParameters> parameterList) {
		System.debug('beginning of getSlots');
        List<string> results = new List<string>();
        
        for(ESWSchedulingParameters parameters : parameterList) {
            OperatingHours operatingHours = [SELECT Name, Id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE Id =: parameters.operatingHoursId LIMIT 1];
            System.debug('begining of Apex: ' + parameters.serviceAppointment);
            System.Savepoint savepoint = Database.setSavepoint();
            String originalServiceAppointmentId = parameters.serviceAppointment.Id;
            DateTime originalArrivalWindowStartTime = parameters.serviceAppointment.ArrivalWindowStartTime;
            DateTime originalArrivalWindowEndTime = parameters.serviceAppointment.ArrivalWindowEndTime;
            parameters.serviceAppointment.ArrivalWindowEndTime = null;
            parameters.serviceAppointment.ArrivalWindowStartTime = null;
            upsert parameters.serviceAppointment;
            
            List<FSL.AppointmentBookingSlot> slotList = FSL.AppointmentBookingService.GetSlots(
                parameters.serviceAppointment.Id,
                parameters.policyId,
                operatingHours,
                UserInfo.getTimeZone(),
                false
            );
            Database.rollback(savepoint);
            parameters.serviceAppointment.Id = originalServiceAppointmentId;
            parameters.serviceAppointment.ArrivalWindowStartTime = originalArrivalWindowStartTime;
            parameters.serviceAppointment.ArrivalWindowEndTime = originalArrivalWindowEndTime;
            
            List<string> slotObjects = new List<string>();
            for(FSL.AppointmentBookingSlot slot : slotList) {
                slotObjects.add('{ "grade":' + slot.Grade + ', "interval": { "start": "' + slot.Interval.Start + '", "finish": "' + slot.Interval.Finish + '" } }');
            }
            results.add('[' + String.join(slotObjects, ',') + ']');
        }
        return results;
    }
    
    global class ESWSchedulingParameters {
        @InvocableVariable(required=true)
        global ServiceAppointment serviceAppointment;
        
        @InvocableVariable(required=true)
        global Id policyId;
        
        @InvocableVariable(required=true)
        global Id operatingHoursId;
    }
}