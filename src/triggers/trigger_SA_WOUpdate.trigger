trigger trigger_SA_WOUpdate on ServiceAppointment (after insert) {
    if(!System.isBatch()) return;
    if(trigger.isAfter && trigger.isInsert){

        ServiceAppointment []newServiceAppointment = Trigger.new;
        blogic_SA_WorkOrderUpdate.UpdateWOAfterCreate(newServiceAppointment);
        }
     
}