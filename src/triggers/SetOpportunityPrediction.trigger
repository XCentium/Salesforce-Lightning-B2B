trigger SetOpportunityPrediction on Opportunity (before insert, before update) {
    if(system.isFuture()) return;  
    if(System.isBatch()) return; 
    
    
    // Name of the custom setting
    // private static final String CONFIG_NAME = 'Opportunity';
    
    // get config
    // analytics_edd__SDDPredictionConfig__c config =
    //     analytics_edd__SDDPredictionConfig__c.getInstance(CONFIG_NAME);
    if(system.isFuture()) return;
    List<Map<String, String>> fieldsList = new List<Map<String, String>>();
    
    for (Opportunity sObj: Trigger.new) {
        /*Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Map<String, String> fieldValues = new Map<String, String>();
        
        for (Schema.SObjectField field: objectFields.values()) {
            if (!field.getDescribe().getType().name().endsWithIgnoreCase('textarea')) {
                String fieldApiName = field.getDescribe().getName();
                if (sObj.get(fieldApiName) != null) {
                    fieldValues.put(fieldApiName, String.valueOf(sObj.get(fieldApiName)));
                }
            }
        }
        
        // log field values
        System.debug(fieldValues);
        fieldsList.add(fieldValues);
        */
        if(sobj.DateTimeCreated__c == null) sobj.DateTimeCreated__c = DateTime.now();
        
        Decimal actualTTC = sobj.DateTimeCreated__c.date().daysBetween(sobj.CloseDate);
        Decimal otherFactors = Math.random()*10;
        Decimal base_ttc = (actualTTC * 0.75) + 12.65 + 10.23 - 7.55 + otherFactors + 15.65 + 5.65;
        
        if (sObj.Exec_Meeting__c == false && sObj.Interactive_Demo__C == false) {
            sObj.ED_Outcome__c = actualTTC + 15.65 + 5.65;
            sObj.ED_Leading_Causes__c = '+ 12.65 because Lead Source is Field Sales<br>+ 10.23 because Lead Source is Field Sales and Region is Central<br>- 7.55 because Region is Central and Stage Count is 5 to 7<br>+ ' + otherFactors.setScale(3) + ' because Due to other factors<br>From the baseline, + ' + base_ttc.setScale(3);
            sObj.ED_Prescription__c = '- 15.65 if you change Exec Meeting to true<br>- 5.65 if you change Interactive Demo to true';
        } else if (sObj.Exec_Meeting__c == true && sObj.Interactive_Demo__C == false) {
            sObj.ED_Outcome__c = actualTTC + 5.65;
            sObj.ED_Leading_Causes__c = '- 15.65 because Exec Meeting to true<br>+ 12.65 because Lead Source is Field Sales<br>+ 10.23 because Lead Source is Field Sales and Region is Central<br>- 7.55 because Region is Central and Stage Count is 5 to 7<br>+ ' + otherFactors.setScale(3) + ' because Due to other factors<br>from the baseline, + ' + base_ttc.setScale(3);
            sObj.ED_Prescription__c = '- 5.65 if you change Interactive Demo to true';
        } else if (sObj.Exec_Meeting__c == false && sObj.Interactive_Demo__C == true) {
            sObj.ED_Outcome__c = actualTTC + 15.65;
            sObj.ED_Leading_Causes__c = '- 5.65 because Interactive Demo to true<br>+ 12.65 because Lead Source is Field Sales<br>+ 10.23 because Lead Source is Field Sales and Region is Central<br>- 7.55 because Region is Central and Stage Count is 5 to 7<br>+ ' + otherFactors.setScale(3) + ' because Due to other factors<br>from the baseline, + ' + base_ttc.setScale(3);
            sObj.ED_Prescription__c = '- 15.65 if you change Exec Meeting to true';
        } else {
            sObj.ED_Outcome__c = actualTTC;
            sObj.ED_Leading_Causes__c = '- 15.65 because Exec Meeting to true<br>- 5.65 because Interactive Demo to true<br>+ 12.65 because Lead Source is Field Sales<br>+ 10.23 because Lead Source is Field Sales and Region is Central<br>+ ' + otherFactors.setScale(3) + ' because Due to other factors<br>from the baseline, + ' + base_ttc.setScale(3);
            sObj.ED_Prescription__c = '';
        } 
        
    }
    
    // make setPrediction call
    //analytics_edd.PredictionIntegration.setPrediction(CONFIG_NAME, JSON.serialize(fieldsList));
}