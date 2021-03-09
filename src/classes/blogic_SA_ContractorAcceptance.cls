public class blogic_SA_ContractorAcceptance {

//***************add excluded resource to Work Order when Service Appointment is rejected, then auto reassigned Service Appointment to next Resource
     public static void UpdateAfterReject(ServiceAppointment[] newServiceAppointment){
     
            List<Id> wo = new List<Id>();
            List<Id> sa = new List<Id>();
                                
            List<ResourcePreference> RPList = new List<ResourcePreference>();
            List<AssignedResource> ARList = new List<AssignedResource>();
            List<ServiceAppointment> SAList = new List<ServiceAppointment>();                       
            List<WorkOrder> WOList = new List<WorkOrder>();
            
            for (ServiceAppointment service : newServiceAppointment) {                 
                        sa.add(service.Id);
                        wo.add(service.ParentRecordId);
                        
            }
                
            SAList = [select Id, FSL__Auto_Schedule__c, Status, ParentRecordId, Work_Acceptance_Status__c, ServiceTerritoryId, City, State, PostalCode, Street from ServiceAppointment where ID IN:sa];
            ARList = [select Id, ServiceAppointmentId, ServiceResourceId from AssignedResource where ServiceAppointmentId IN:sa];
            WOList = [select Id FROM WorkOrder where Id IN:wo];
            
            for (WorkOrder workorder : WOList){ 
                  for (AssignedResource ass : ARList){
                       for (ServiceAppointment s : SAList){
                                             
                RPList.add(new ResourcePreference  (
                ServiceResourceId = ass.ServiceResourceId,
                RelatedRecordId = workorder.Id,               
                PreferenceType = 'Excluded'
                )
                );                          
                }
                }
                }
               
             insert RPList;
                                     
               for (ServiceAppointment serv : SAList){                                                
                serv.Work_Acceptance_Status__c = '';
                //serv.Status = 'Scheduled';
                serv.FSL__Auto_Schedule__c = true ;                
               }
             update SAList;
               }  
               
                                                 
              
//***************change Service Territory on Work Order to Contractor's when Service Appointment is accepted by a Contractor and change Service Appointment status to Dispatched
              
            public static void UpdateAfterAccept(ServiceAppointment[] newServiceAppointment){
     
            List<Id> wo = new List<Id>();
            List<Id> sa = new List<Id>();
                  
            List<ServiceAppointment> SAList = new List<ServiceAppointment>();                       
            List<WorkOrder> WOList = new List<WorkOrder>();
            List<AssignedResource> ARList = new List<AssignedResource>();
            List<ServiceAppointment> NEWSAList = new List<ServiceAppointment>();                       
            
            for (ServiceAppointment service : newServiceAppointment) {                  
                        sa.add(service.Id);
                        wo.add(service.ParentRecordId);
                        }
              
            SAList = [select Id, FSL__Auto_Schedule__c, Status, ParentRecordId, Work_Acceptance_Status__c, ServiceTerritoryId, City, State, PostalCode, Street from ServiceAppointment where ID IN:sa];
            WOList = [select Id, ServiceTerritoryId FROM WorkOrder where Id IN:wo];
            ARList = [select Id, ServiceAppointmentId, ServiceResourceId, ServiceResource.Contractor_s_Service_Territory__c from AssignedResource where ServiceAppointmentId IN:sa];
            
            
            for (ServiceAppointment serv : SAList){ 
                                                               
                serv.Status = 'Dispatched';
                serv.Work_Acceptance_Status__c = '';
                 
                 }
             update SAList;
            
           for (WorkOrder workorder : WOList){ 
                  for (AssignedResource ass : ARList){ 
                    if(  ass.ServiceResource.Contractor_s_Service_Territory__c != null) {                                           
                workorder.ServiceTerritoryId = ass.ServiceResource.Contractor_s_Service_Territory__c;
               }
               }                
               }
             update WOList;
             
             
             for (WorkOrder w : WOList){                  
                       for (ServiceAppointment s : SAList){                                            
                NEWSAList.add(new ServiceAppointment  (
                ParentRecordId = w.Id,
                Related_Contractor_Appointment__c = s.Id,                               
                Requires_Contractor__c = true
                )
                );                          
                }                
                }
               
             insert NEWSAList; 
                
                
             }
             
             
            
             
             }