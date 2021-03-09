trigger Q_FSL_DEMO_TOOLS_ServiceTerritory on ServiceTerritory (before delete) {
    if(System.isBatch()) return;
    for(ServiceTerritory rec: Trigger.old){
        if(!String.isEmpty(rec.External_ID__c)) {
            rec.AddError('Cannot Delete record - Part of FSL Demo Tool Data. Deactivate the Q_FSL_DEMO_TOOLS_ServiceTerritory trigger to allow this record to be deleted.');
        }
    }
}