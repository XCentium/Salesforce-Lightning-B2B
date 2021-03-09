public class EinsteinBuilderMegaController {
	
    //Returns the object containing the specified fields in JSON format
    @AuraEnabled
    public static string getObjectData(String objid, String objName, String predictionField, String factorFields,String factorFieldsField) {
        //Factor fields can either be hardcoded or stored in another field on the object. This code handles the latter.
        if (factorFieldsField!='' && factorFieldsField!=null) {
            String factorFieldsQuery = 'SELECT {0} from {1} where Id=:objid';
            List<String> queryList = new String[]{factorFieldsField,objName};
            factorFieldsQuery = String.format(factorFieldsQuery,queryList);
            sObject returnObj = Database.query(factorFieldsQuery);
            String newFactorFields = (String)returnObj.get(factorFieldsField);
            
            System.debug(newFactorFields);
            
            if (newFactorFields!=null && newFactorFields!='') {
                factorFields = newFactorFields;
            }
        }
        
        String query = 'SELECT {0},{1} from {2} where Id=:objid';
        if (factorFieldsField!='' && factorFieldsField!=null) {
            query = 'SELECT {0},{1},{2} from {3} where Id=:objid';
            List<String> queryList = new String[]{predictionField,factorFields,factorFieldsField,objName};
            query = String.format(query,queryList);
        } else {
        	query = 'SELECT {0},{1} from {2} where Id=:objid';
            List<String> queryList = new String[]{predictionField,factorFields,objName};
            query = String.format(query,queryList);
        }
        
        System.debug(query);
            
        sObject returnObj = Database.query(query);
        
        return System.JSON.serialize(returnObj);
    }
    
    @AuraEnabled
    public static string getFieldLabels(String objName) {
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe().Fields.getMap();
        String retJson = '{';
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                List<String> toAdd = new String[]{fd.getName(),fd.getLabel()};
                    
                retJson+=String.format('"{0}":"{1}",',toAdd);
            }
        }
        
        //Remove that last comma and close off the curly
        retJson = retJson.left(retJson.length()-1) + '}';
        
        return retJson;
    }
}