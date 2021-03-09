@isTest
global class ESWFieldServiceTests {
    static testMethod void testGetSlots() {
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        insert policy;
        
        OperatingHours operatingHours = new OperatingHours(
            Name = 'Test Hours'
        );
        insert operatingHours;

        WorkType workType = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 2
        );
        insert workType;
        
        WorkOrder workOrder = new WorkOrder(
            WorkTypeId = workType.Id
        );
        insert workOrder;
        
        ServiceAppointment serviceAppointment = new ServiceAppointment(
            ParentRecordId = workOrder.Id
        );
        insert serviceAppointment;
        
        ESWFieldServiceScheduling.ESWSchedulingParameters params = new ESWFieldServiceScheduling.ESWSchedulingParameters();
        params.serviceAppointment = serviceAppointment;
        params.policyId = policy.Id;
        params.operatingHoursId = operatingHours.Id;
        
        List<ESWFieldServiceScheduling.ESWSchedulingParameters> items = new List<ESWFieldServiceScheduling.ESWSchedulingParameters>();
        items.add(params);
        
        ESWFieldServiceScheduling.getSlots(items);
    }
    
    static testMethod void testControllerGetTimeslots() {
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        insert policy;
        
        OperatingHours operatingHours = new OperatingHours(
            Name = 'Test Hours'
        );
        insert operatingHours;

        WorkType workType = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 2
        );
        insert workType;
        
        WorkOrder workOrder = new WorkOrder(
            WorkTypeId = workType.Id
        );
        insert workOrder;
        
        ServiceAppointment serviceAppointment = new ServiceAppointment(
            ParentRecordId = workOrder.Id
        );
        insert serviceAppointment;

        new FieldServiceSchedulingController.ESWFieldServiceTimeslotRequestResult('test');
        
        FieldServiceSchedulingController.getTimeslots(
            serviceAppointment,
            policy.Id,
            operatingHours.Id,
            1,
            1,
            2017
        );
    }
    
    static testmethod void testSchedulingControllerRollback() {
          FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        insert policy;
        
        OperatingHours operatingHours = new OperatingHours(
            Name = 'Test Hours'
        );
        insert operatingHours;

        WorkType workType = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 2
        );
        insert workType;
        
        WorkOrder workOrder = new WorkOrder(
            WorkTypeId = workType.Id
        );
        insert workOrder;
        
        ServiceAppointment serviceAppointment = new ServiceAppointment(
            ParentRecordId = workOrder.Id
        );
        insert serviceAppointment;

        new FieldServiceSchedulingController.ESWFieldServiceTimeslotRequestResult('test');
        
        FieldServiceSchedulingController.getTimeslots(
            serviceAppointment,
            policy.Id,
            '0OH000000000000',
            -1,
            -1,
            -1
        );
    }
    
    static testMethod void testBookAppointment() {
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        insert policy;
        
        OperatingHours operatingHours = new OperatingHours(
            Name = 'Test Hours'
        );
        insert operatingHours;

        WorkType workType = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 2
        );
        insert workType;
        
        WorkOrder workOrder = new WorkOrder(
            WorkTypeId = workType.Id
        );
        insert workOrder;
        
        ServiceAppointment serviceAppointment = new ServiceAppointment(
            ParentRecordId = workOrder.Id
        );
        insert serviceAppointment;
        
        ESWFieldServiceBookAppointment.ESWFieldServiceBookAppointmentParameters params = new ESWFieldServiceBookAppointment.ESWFieldServiceBookAppointmentParameters();
        params.serviceAppointment = serviceAppointment;
        params.policyId = policy.Id;
        params.operatingHoursId = operatingHours.Id;
        
        Date now = Date.today();
        params.timeslotBegin = now.addDays(-7);
        params.timeslotFinish = now.addDays(7);
        
        List<ESWFieldServiceBookAppointment.ESWFieldServiceBookAppointmentParameters > items = new List<ESWFieldServiceBookAppointment.ESWFieldServiceBookAppointmentParameters>();
        items.add(params);
        
        ESWFieldServiceBookAppointment.bookAppointment(items);
     }
}