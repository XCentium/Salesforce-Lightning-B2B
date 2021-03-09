global class DE_KanbanFullCtrl {

    
    @RemoteAction
    global static Object[] getTasks(){
        IDO_Project_Task__c[] tasks = new IDO_Project_Task__c[]{};
        tasks = [Select Id, Name, Location__c From IDO_Project_Task__c Where Owner__c = :UserInfo.getUserId() AND Owner__c != null];
        
    return tasks;
    }
    
    @RemoteAction
    global static Object[] getEmployees(String locationId, String taskId){
        EmployeeWrapper[] employeeWrappers = new EmployeeWrapper[]{};
        IDO_Employee__c[] employees = new IDO_Employee__c[]{};
        IDO_Project_Line_Item__c[] items = new IDO_Project_Line_Item__c[]{};
        
        employees = [Select Id, Location__c, User__r.Name, User__r.Id, User__r.SmallPhotoURL From IDO_Employee__c Where Location__c =: locationId];
        
        String[] employeeUserIds = new String[]{};
        for(IDO_Employee__c emp: employees){
            employeeUserIds.add(emp.User__r.Id);
        }
        
        items = [Select Id, Name, Priority__c, Assigned__c, Start_Date__c, End_Date__c, Item_Image__c From IDO_Project_Line_Item__c Where Assigned__c =:employeeUserIds And Task__c =: taskId];
        
        for(IDO_Employee__c emp: employees){
            IDO_Project_Line_Item__c[] tempItems = new IDO_Project_Line_Item__c[]{};
            for(IDO_Project_Line_Item__c item: items){
                if(emp.User__r.Id == item.Assigned__c)
                    tempItems.add(item);
            }
            employeeWrappers.add(new EmployeeWrapper(emp, tempItems));
        }
        
    return employeeWrappers;
    }
    
    @RemoteAction
    global static Object[] getLineItems(String taskId){
        IDO_Project_Line_Item__c[] items = new IDO_Project_Line_Item__c[]{};
        items = [Select Id, Name, Priority__c, Assigned__c, Start_Date__c, End_Date__c, Item_Image__c From IDO_Project_Line_Item__c Where Task__c =:taskId And Assigned__c = null];
    return items;
    }
    
    @RemoteAction
    global static String updateLineItems(IDO_Project_Line_Item__c[] lineItems){
        update lineItems;
        return 'success';
    }
    
    global class EmployeeWrapper {
        global IDO_Employee__c employee {get;set;}
        global IDO_Project_Line_Item__c[] items {get;set;}
        
        global EmployeeWrapper(IDO_Employee__c e, IDO_Project_Line_Item__c[] i){
      this.employee = e;
            this.items = i;
        }
    }
    

    
}