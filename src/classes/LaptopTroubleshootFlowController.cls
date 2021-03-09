public with sharing class LaptopTroubleshootFlowController{
    public Flow.Interview.Laptop_Troubleshoot_v2 my_interview {get; set;}
    public String newRecord{get;set;}
    public PageReference getPageA() {
        if(my_interview != null){ 
            newRecord=my_interview.vaContactId; // set 'guy' to the variable that has the new record id
        }
        return new PageReference('/' + newRecord);
    }
}