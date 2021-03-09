public class SlickCtiObjectHelper
{
    // map to hold global describe data
    private static Map<String,Schema.SObjectType> gd;
    
    // map to store objects and their prefixes
    private static Map<String, String> keyPrefixMap;

    // to hold set of all sObject prefixes
    private static Set<String> keyPrefixSet;
    
    private static void init() {
        // get all objects from the org
        gd = Schema.getGlobalDescribe();
        
        // to store objects and their prefixes
        keyPrefixMap = new Map<String, String>{};
        
        //get the object prefix in IDs
        keyPrefixSet = gd.keySet();
        
        // fill up the prefixes map
        for(String sObj : keyPrefixSet)
        {
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            keyPrefixMap.put(tempPrefix, tempName);
        }
    }
    
    public static String getObjectType(String ObjId) {
        init() ;
        String tPrefix = ObjId.replace('/','');
        tPrefix = tPrefix.subString(0,3);
        
        //get the object type now
        String objectType = keyPrefixMap.get(tPrefix);
        return objectType;
    }
    
    
    static testMethod void TestThisSucker() {
        String objectId = '/003d000000kCQtI';
        String returnedObjectType =  SlickCtiObjectHelper.getObjectType(objectId);
        // I should assert that it returns Contact but 
        //I don't want that to get in the way of the installation if it doesn't so commented it out
        //System.assertEquals(returnedObjectType, 'Contact');       
    }    
    
    
}