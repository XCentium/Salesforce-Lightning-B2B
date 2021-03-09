trigger Q_FSL_DEMO_TOOLS_ServiceResource on ServiceResource (before delete) {
    if(System.isBatch()) return;
    for(ServiceResource rec: Trigger.old){
        if(!String.isEmpty(rec.External_ID__c)) {
            rec.AddError('Cannot Delete record - Part of FSL Demo Tool Data. Deactivate the Q_FSL_DEMO_TOOLS_ServiceResource trigger to allow this record to be deleted.');
        }
    }
}