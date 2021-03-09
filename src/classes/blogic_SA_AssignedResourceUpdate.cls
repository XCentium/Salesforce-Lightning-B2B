public class blogic_SA_AssignedResourceUpdate {

//***************Updates Assigned Resource Field on the Service Appointment 
     public static void UpdateAfterSchedule(AssignedResource[] newAssignedResource){
     
            List<Id> ar = new List<Id>();
            List<Id> sa = new List<Id>();
                                
            List<AssignedResource> ARList = new List<AssignedResource>();
            List<ServiceAppointment> SAList = new List<ServiceAppointment>();                       
            
            for (AssignedResource resource : newAssignedResource) {                 
                        ar.add(resource.Id);
                        sa.add(resource.ServiceAppointmentId);                       
            }
            
            ARList = [select Id, ServiceAppointmentId, ServiceResourceId from AssignedResource where Id IN:ar];    
            SAList = [select Id, FSLDemoTools_Service_Resource__c, Status from ServiceAppointment where ID IN:sa];
                        
            for (AssignedResource ass : ARList){
                for (ServiceAppointment s : SAList){
                    s.FSLDemoTools_Service_Resource__c = ass.ServiceResourceId;                                    
               }
             update SAList;    
               } 
           }
           }