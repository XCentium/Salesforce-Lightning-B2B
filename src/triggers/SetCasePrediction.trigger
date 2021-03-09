trigger SetCasePrediction on Case (before insert, before update) {
    if(system.isFuture()) return;  
    if(System.isBatch()) return;
    // Name of the custom setting
    //private static final String CONFIG_NAME = 'Case';
    
    // get config
    //analytics_edd__SDDPredictionConfig__c config =
    //analytics_edd__SDDPredictionConfig__c.getInstance(CONFIG_NAME);
    
   // List<Map<String, String>> fieldsList = new List<Map<String, String>>();
    
    for (Case sObj: Trigger.new) {
       // Map<String, Schema.SObjectField> objectFields =
       //     Schema.getGlobalDescribe().get(config.analytics_edd__object_api_name__c).getDescribe().fields.getMap();
      //  Map<String, String> fieldValues = new Map<String, String>();
        
      //  for (Schema.SObjectField field: objectFields.values()) {
      //      if (!field.getDescribe().getType().name().endsWithIgnoreCase('textarea')) {
       //         String fieldApiName = field.getDescribe().getName();
       //         if (sObj.get(fieldApiName) != null) {
         //           fieldValues.put(fieldApiName, String.valueOf(sObj.get(fieldApiName)));
      //          }
      //      }
     //   }
        
        // log field values
       // System.debug(fieldValues);
       // fieldsList.add(fieldValues);
        
        if(sObj.CSAT__c == null)
            sObj.CSAT__c = 85.3;
        
        Decimal otherFactors = Math.random()*10;
        Decimal base_csat = (sObj.CSAT__c * 0.75) - 3.135 - 3.017 - 1.555 - otherFactors - 7.949 - 9.998;
        
        if (sObj.Offer_Voucher__c == false && sobj.Send_FieldService__c == false) {
            sObj.ED_Outcome__c = sObj.CSAT__c - 7.949 - 9.998;
            sObj.ED_Leading_Causes__c = '- 3.135 because Origin is Phone and Offer Voucher is false<br>- 3.017 because Origin is Phone and Send Field Service is false<br>- 1.555 because Origin is Phone<br>- ' + otherFactors.setScale(3) + ' because of other factors<br>from the baseline, + ' + base_csat.setScale(3);
            sObj.ED_Prescription__c = '+ 7.949 if you change Offer Voucher to true<br>+ 9.998 if you change Send Field Service to true';
        } else if (sObj.Offer_Voucher__c == true && sobj.Send_FieldService__c == false) {
            sObj.ED_Outcome__c = sObj.CSAT__c - 9.998;
            sObj.ED_Leading_Causes__c = '+ 7.949 because Offer Voucher to true<br>- 3.135 because Origin is Phone<br>- 3.017 because Origin is Phone and Send Field Service is false<br>- 1.555 because Origin is Phone<br>- ' + otherFactors.setScale(3) + ' because of other factors<br>from the baseline, + ' + base_csat.setScale(3);
            sObj.ED_Prescription__c = '+ 9.998 if you change Send Field Service to true';
        } else if (sObj.Offer_Voucher__c == false && sobj.Send_FieldService__c == true) {
            sObj.ED_Outcome__c = sObj.CSAT__c - 7.949;
            sObj.ED_Leading_Causes__c = '+ 9.998 because Send Field Service to true<br>- 3.135 because Origin is Phone<br>- 3.017 because Origin is Phone and Send Field Service is false<br>- 1.555 because Origin is Phone<br>- ' + otherFactors.setScale(3) + ' because of other factors<br>from the baseline, + ' + base_csat.setScale(3);
            sObj.ED_Prescription__c = '+ 7.949 if you change Offer Voucher to true';
        } else {
            sObj.ED_Outcome__c = sObj.CSAT__c;
            sObj.ED_Leading_Causes__c = '+ 7.949 because Offer Voucher to true<br>+ 9.998 because Send Field Service to true<br>- 3.135 because Origin is Phone<br>- 3.017 because Origin is Phone and Send Field Service is false<br>- 1.555 because Origin is Phone<br>- ' + otherFactors.setScale(3) + ' because of other factors<br>from the baseline, + ' + base_csat.setScale(3);
            sObj.ED_Prescription__c = '';
        } 
      
    }

    // make setPrediction call
    //analytics_edd.PredictionIntegration.setPrediction(CONFIG_NAME, JSON.serialize(fieldsList));
}