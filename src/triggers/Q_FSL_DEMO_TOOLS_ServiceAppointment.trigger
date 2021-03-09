trigger Q_FSL_DEMO_TOOLS_ServiceAppointment on ServiceAppointment (before delete) {
    if(!System.isBatch()) return;
    for(ServiceAppointment rec: Trigger.old){
        if(!String.isEmpty(rec.External_ID__c)) {
            rec.AddError('Cannot Delete record - Part of FSL Demo Tool Data. Deactivate the Q_FSL_DEMO_TOOLS_ServiceAppointment trigger to allow this record to be deleted.');
        }
    }
}