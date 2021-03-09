trigger trigger_ServiceAppointment on ServiceAppointment (after update) {
    if(!System.isBatch()) return;
    if(trigger.isAfter && trigger.isUpdate){

        ServiceAppointment []newServiceAppointment = Trigger.new;
        list<ServiceAppointment> newSAList = new list<ServiceAppointment>();
            for(ServiceAppointment s: trigger.new){
            if(s.Work_Acceptance_Status__c == 'Reject'){
                    newSAList.add(s);
            }
            }
             if(newSAList.size() > 0){
                blogic_SA_ContractorAcceptance.UpdateAfterReject(newServiceAppointment);
        }   
}

    if(trigger.isAfter && trigger.isUpdate){

        ServiceAppointment []newServiceAppointment = Trigger.new;
        list<ServiceAppointment> newSAList = new list<ServiceAppointment>();
            for(ServiceAppointment s: trigger.new){
            if(s.Work_Acceptance_Status__c == 'Accept'){
                    newSAList.add(s);
            }
            }
             if(newSAList.size() > 0){
                blogic_SA_ContractorAcceptance.UpdateAfterAccept(newServiceAppointment);
        }   
}


}