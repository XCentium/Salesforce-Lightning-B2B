/*
 * Apex controller to retrieve Field Service timeslots for a specific week for use in the
 * Snap-Ins Field Service feature scheduling calendar view.
 */
global class FieldServiceSchedulingController {
    global FieldServiceSchedulingController() {}

    /**
     * Retrieve a list of timeslots for a given day and the week following it. Ideally, you should pass in a Sunday.
     * @param {Integer} day - The day that begins the week.
     * @param {Integer} month - The month in which the week begins, zero indexed.
     * @param {Integer} year - The year in which the week begins.
     * @returns {ESWFieldServiceTimeslotRequestResult} The available timeslots if successful, otherwise an error.
     */
    @AuraEnabled
    global static ESWFieldServiceTimeslotRequestResult getTimeslots(ServiceAppointment serviceAppointment, Id policyId, Id operatingHoursId, Integer day, Integer month, Integer year) {
        System.Savepoint savepoint = Database.setSavepoint();
        String originalServiceAppointmentId = serviceAppointment.Id;
        DateTime originalEarliestStartTime = serviceAppointment.EarliestStartTime;
        DateTime originalDueDate = serviceAppointment.DueDate;
        DateTime originalArrivalWindowStartTime = serviceAppointment.ArrivalWindowStartTime;
        DateTime originalArrivalWindowEndTime = serviceAppointment.ArrivalWindowEndTime;
        
        try {
            // By default these values are decimals, even though I specified integers. DateTime does not like decimals.
            day = Integer.valueOf(day);
            month = Integer.valueOf(month) + 1;
            year = Integer.valueOf(year);

            List<ESWTimeslot> timeslots = new List<ESWTimeslot>();

            OperatingHours operatingHours = [SELECT Name, Id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM
                OperatingHours WHERE Id =: operatingHoursId LIMIT 1];

            TimeZone tz = UserInfo.getTimeZone();
            
            // Update service appointment so that it filters within the request week.
            serviceAppointment.ArrivalWindowEndTime = null;
            serviceAppointment.ArrivalWindowStartTime = null;
            serviceAppointment.EarliestStartTime = DateTime.newInstance(year, month, day);
            serviceAppointment.EarliestStartTime = serviceAppointment.EarliestStartTime.addSeconds(tz.getOffset(serviceAppointment.EarliestStartTime) / 1000);
            serviceAppointment.DueDate = DateTime.newInstance(year, month, day).AddDays(7);
            serviceAppointment.DueDate = serviceAppointment.DueDate.addSeconds(tz.getOffset(serviceAppointment.DueDate) / 1000);

            upsert serviceAppointment;

            List<FSL.AppointmentBookingSlot> slotList = FSL.AppointmentBookingService.GetSlots(
                serviceAppointment.Id,
                policyId,
                operatingHours,
                tz,
                false
            );

            for(FSL.AppointmentBookingSlot slot : slotList) {
                timeslots.add(new ESWTimeslot(slot.Interval.Start, slot.Interval.Finish, slot.Grade));
            }

            // Set service appointment fields back to what they were before.
            serviceAppointment.Id = originalServiceAppointmentId;
            serviceAppointment.ArrivalWindowStartTime = originalArrivalWindowStartTime;
            serviceAppointment.ArrivalWindowEndTime = originalArrivalWindowEndTime;
            serviceAppointment.EarliestStartTime = originalEarliestStartTime;
            serviceAppointment.DueDate = originalDueDate;
            
            Database.rollback(savepoint);

            return new ESWFieldServiceTimeslotRequestResult(timeslots);
        } catch (Exception e) {
            Database.rollback(savepoint);
            serviceAppointment.Id = originalServiceAppointmentId;
            serviceAppointment.ArrivalWindowStartTime = originalArrivalWindowStartTime;
            serviceAppointment.ArrivalWindowEndTime = originalArrivalWindowEndTime;
            serviceAppointment.EarliestStartTime = originalEarliestStartTime;
            serviceAppointment.DueDate = originalDueDate;
            return new ESWFieldServiceTimeslotRequestResult(e.getMessage());
        }
    }

    /**
     * Container class for the retrieved timeslots, or an error message if something went wrong.
     * This class and the ones beneath it need to be separate for the JSON output to serialize correctly.
     */
    global class ESWFieldServiceTimeslotRequestResult {
        @AuraEnabled
        global boolean success;

        @AuraEnabled
        global List<ESWTimeslot> slots;

        @AuraEnabled
        global string error;

        public ESWFieldServiceTimeslotRequestResult(List<ESWTimeslot> slots) {
            this.success = true;
            this.slots = slots;
        }

        public ESWFieldServiceTimeslotRequestResult(String error) {
            this.success = false;
            this.error = error;
        }
    }

    /*
     * Container class for a timeslot.
     */
    global class ESWTimeslot {
        @AuraEnabled
        global ESWTimeslotInterval interval;

        @AuraEnabled
        global Decimal grade;

        global ESWTimeslot(DateTime start, DateTime finish, Decimal grade) {
            this.interval = new ESWTimeslotInterval(start, finish);
            this.grade = grade;
        }
    }

    /*
     * Container class for an timeslot interval.
     */
    global class ESWTimeslotInterval {
        @AuraEnabled
        global DateTime start;

        @AuraEnabled
        global DateTime finish;

        global ESWTimeslotInterval(DateTime start, DateTime finish) {
            this.start = start;
            this.finish = finish;
        }
    }
}