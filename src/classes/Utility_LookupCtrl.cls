public without sharing class Utility_LookupCtrl {

    @AuraEnabled
    public static Object[] getLookup(String lookupObject, String lookupField, String searchTerm, String filters){
        String likeSearchTerm = searchTerm+'%';
        
        String queryString = 'Select Id, ' + lookupField;
        queryString += ' From ' + lookupObject;
        queryString += ' Where ' + lookupField + ' Like \'' + likeSearchTerm + '\'';
        if(filters != '' && filters != null){
            queryString += ' And ' + filters;
        }
        queryString += ' Limit 5';
        
        return Database.query(queryString);
    }
}