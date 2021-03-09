global class FetchSAData implements FSL.CustomGanttServiceAppointmentAction {
    
    global String action(List<Id> serviceAppointmentsIds, Datetime ganttStartDate, Datetime ganttEndDate, Map<String, Object> additionalParameters) {
        
        Map <ID,ServiceAppointment> saMAP = new MAP<ID, ServiceAppointment>();
        Map <ID,ServiceResource> srMAP = new MAP<ID, ServiceResource>();
        Map <ID,AssignedResource> arMAP = new MAP<ID, AssignedResource>();
        Map <ID,WorkOrder> woMap = new Map<ID, WorkOrder>();
        Set<ID> srIDs = new Set<ID>();
        Set<ID> woIDs = new Set<ID>();
                     
        //Query Service Appointment and Put the Service Appointment data into a List of type ServiceAppointment
        List<ServiceAppointment> saList = [select Id, ParentRecordId, DueDate, FSLDemoTools_Service_Resource__c, Tech_Color__c, Duration, Status, FSL__Schedule_Mode__c from ServiceAppointment WHERE Id in:serviceAppointmentsIds];
        
        //Put the SA Data from the List(saList) into a Map(saMAP) of type ServiceAppointment
        //Assign the Parent Record ID to SET variable woIDs        
        for (ServiceAppointment SAs : saList){
            saMAP.put(SAs.Id, SAs);
            woIDs.add(SAs.ParentRecordId);
        }
        
        //Query Assigned Resource record and Put the Assigned Resource data into a List of type AssignedResource
        List<AssignedResource> arList = [select Id, EstimatedTravelTime, ServiceAppointmentId, ServiceResourceId from AssignedResource where ServiceAppointmentId IN:serviceAppointmentsIds];
                
        //Put the AR Data from the List(arList) into a Map(arMAP) of type AssignedResource        
        //Assign the Service Resource ID to SET variable srIDs
        for (AssignedResource AR : arList){
            arMap.put(AR.Id, AR);  
            srIDs.add(AR.ServiceResourceID);
        }
       
        //Get the values from the Service Resource record and Put the Service Resource data into a List of type ServiceResource
        List<ServiceResource> srList = [select Id, Gantt_Color__c, Number_of_Jobs_Optimized__c, Number_of_Jobs_Scheduled__c, Updated_Travel_Time__c, Original_Travel_Time__c from ServiceResource where Id IN:srIDs]; 
        
        //Put the SR Data from the List(srList) into a Map(srMAP) of type ServiceResource
        for (ServiceResource SRs : srList){
            srMAP.put(SRs.Id, SRs);
        }

        //Get the values from the Work Order record and Put the Work Order data info a List of type WorkOrder
        List<WorkOrder> woList = [select Id, Priority from WorkOrder where Id IN:woIDs];
        
        //Put the WO Data from the List(woList) into a Map(woMAP) of type WorkOrder
        for (WorkOrder WOs : woList){
            WOs.Priority = 'High';
        }        
        Update woList;
        
        //Update the Service Appointment Record and Service Resource Record with the Estimated Travel Time from the Assigned Resource Record
        for (AssignedResource ARs : arList){
            
            ServiceResource Srr = srMAP.get(ARs.ServiceResourceId);
            ServiceAppointment s = saMAP.get(ARs.ServiceAppointmentId);
                           
            If(s.FSL__Schedule_Mode__c == 'Manual' && s.Status == 'Scheduled'){
                s.Tech_Color__c = srr.Gantt_Color__c;
                s.DueDate = ganttEndDate;
                s.FSL__UpdatedByOptimization__c = FALSE;
                
                             
                if(srr.Number_of_Jobs_Scheduled__c<>null){              
                    srr.Number_of_Jobs_Scheduled__c = (srr.Number_of_Jobs_Scheduled__c + 1);                        
                }
                else{
                    srr.Number_of_Jobs_Scheduled__c = 1;
                }
                   
                if(srr.Original_Travel_Time__c<>null){              
                    srr.Original_Travel_Time__c = (srr.Original_Travel_Time__c + ARs.EstimatedTravelTime);                        
                }
                else{
                    srr.Original_Travel_Time__c = ARs.EstimatedTravelTime;
                }
            }
                   
            If(s.FSL__Schedule_Mode__c == 'Optimization' && s.Status == 'Scheduled'){                   
                s.FSL__UpdatedByOptimization__c = TRUE;
                if(srr.Number_of_Jobs_Optimized__c<>null){              
                    srr.Number_of_Jobs_Optimized__c = (srr.Number_of_Jobs_Optimized__c + 1);                        
                }
                else{
                    srr.Number_of_Jobs_Optimized__c = 1;
                }
                if(srr.Updated_Travel_Time__c<>null){
                    srr.Updated_Travel_Time__c = (srr.Updated_Travel_Time__c + ARs.EstimatedTravelTime);  
                }
                else{
                    srr.Updated_Travel_Time__c = ARs.EstimatedTravelTime;
                }               
            }                          
        
            saMAP.put(ARs.ServiceAppointmentId, s);
            srMAP.put(ARs.ServiceResourceId, srr);
            system.debug('****************' + ARS.Id);
        }
            
        update saMAP.values();
        update srMAP.values();
        
        
        String d = 'SA Data Successfully Captured';
        return d;
    } 
}