/**
 * @FileName: XC_Util_TestData
 * @Description: Utility for constructing test data
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       11/1/2019         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_Util_TestData {

    public static SObject createSObject(SObject sObj) {
        return createSObject(sObj, false);
    }

    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        String defaultClassName = getDefaultClassName(sObj);

        Type t = Type.forName(defaultClassName);

        if(t == null) {
            throw new TestUtilsException('Invalid defaults class.');
        }

        XC_Util_TestDataDefaults.FieldDefaults defaults = (XC_Util_TestDataDefaults.FieldDefaults)t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults());

        if(doInsert) {
            insert sObj;
        }

        return sObj;
    }

    public static List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects) {
        return createSObjectList(sObj, numberOfObjects, false);
    }

    public static List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        sObj = createSObject(sObj, false);

        List<SObject> sObjList = new List<SObject>();

        // Get the name field for the object
        List<String> incrementFields = XC_Util_TestDataDefaults.incrementFieldMap.get(String.valueOf(sObj.getSObjectType()));

        // Clone the object the number of times requested. Increment the name field so each record is unique
        for(Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = sObj.clone(false, true);

            if(incrementFields != null) {
                for(String incrementField : incrementFields) {
                    clonedSObj.put(incrementField, (String)clonedSObj.get(incrementField) + i);
                }
            }

            sObjList.add(clonedSObj);
        }

        if (doInsert) {
            insert sObjList;
        }

        return sObjList;
    }

    private static String getDefaultClassName(SObject sObj) {
        // Check what type of object we are creating and add any defaults that are needed.
        String objectName = String.valueOf(sObj.getSObjectType());

        // Construct the default values class. Salesforce doesn't allow '__' in class names
        String defaultClassName = objectName.replace('__c', '');

        return 'XC_Util_TestDataDefaults.' + defaultClassName.replace('__', '') + 'Defaults';
    }

    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        // Loop through the map of fields and if they are null on the object, fill them.
        for(String field : defaults.keySet()) {
            if(sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        }
    }

    public class TestUtilsException extends Exception {}
}