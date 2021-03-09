public class blogic_SA_WorkOrderUpdate {

//***************Copies Parent Record ID to Custom Work order lookup field
     public static void UpdateWOAfterCreate(ServiceAppointment[] newServiceAppointment){
     
            List<Id> sa = new List<Id>();
                                
            List<ServiceAppointment> SAList = new List<ServiceAppointment>();                       
            
            for (ServiceAppointment service : newServiceAppointment) {                 
                        sa.add(service.Id);                        
            }
                
            SAList = [select Id, ParentRecordId, Parent_Work_Order__c, ParentRecordType from ServiceAppointment where ID IN:sa];
                                     
              
                   for (ServiceAppointment serv : SAList){
                        if (serv.ParentRecordType == 'WorkOrder')                                                
                            serv.Parent_Work_Order__c = serv.ParentRecordId;
               }
             update SAList;
             
               }  
               
               }