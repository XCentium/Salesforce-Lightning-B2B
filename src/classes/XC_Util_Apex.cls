/**
 * @FileName: XC_Util_Apex
 * @Description: Apex utility methods
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/15/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_Util_Apex {

    /*
     * @Name        filterOnFieldChange
     * @Description Check a list of records for field changes
     * @Author      Graeme Ward
     * @Params      newRecords: list of new versions of records
     *              oldRecords: list of previous versions of records
     *              field: field to evaluate for change
     * @Return      List<SObject>: list of records with specified fields that have changed
     */
    public static List<SObject> filterOnFieldChange(List<SObject> newRecords, Map<Id, SObject> oldRecords, String field) {
        return filterOnFieldChange(newRecords, oldRecords, new Set<String>{field});
    }

    /*
     * @Name        filterOnFieldChange
     * @Description Check a list of records for field changes
     * @Author      Graeme Ward
     * @Params      newRecords: list of new versions of records
     *              oldRecords: list of previous versions of records
     *              fields: list of fields to evaluate
     * @Return      List<SObject>: list of records with specified fields that have changed
     */
    public static List<SObject> filterOnFieldChange(List<SObject> newRecords, Map<Id, SObject> oldRecords, Set<String> fields) {
        List<SObject> fieldChangedList = new List<SObject>();

        for (SObject so : newRecords) {
            if (fieldChanged(so, oldRecords.get((Id) so.get('Id')), fields)) {
                fieldChangedList.add(so);
            }
        }

        return fieldChangedList;
    }

    /*
     * @Name        fieldChanged
     * @Description Check whether or not a field has changed on a record
     * @Author      Graeme Ward
     * @Params      newRecord: new version of the record
     *              oldRecord: previous version of the record
     *              field: field to evaluate
     * @Return      Boolean: whether or not a field has changed
     */
    public static Boolean fieldChanged(SObject newRecord, SObject oldRecord, String field) {
        return fieldChanged(newRecord, oldRecord, new Set<String>{field});
    }

    /*
     * @Name        fieldChanged
     * @Description Check whether or not a field has changed on a record
     * @Author      Graeme Ward
     * @Params      newRecord: new version of the record
     *              oldRecord: previous version of the record
     *              fields: list of fields to evaluate
     * @Return      Boolean: whether or not a field has changed
     */
    public static Boolean fieldChanged(SObject newRecord, SObject oldRecord, Set<String> fields) {
        Boolean hasChanged = false;

        for(String field : fields) {
            if(getFieldValue(newRecord, field) != getFieldValue(oldRecord, field)) {
                hasChanged = true;
                break;
            }
        }

        return hasChanged;
    }

    /*
     * @Name        writeToTargetRecord
     * @Description write field values from one record to another
     * @Author      Graeme Ward
     * @Params      target: target record
     *              source: source record
     *              fieldMapping: field mapping, source field api name => target field api name
     * @Return      SObject: updated target record
     */
    public static SObject writeToTargetRecord(SObject target, SObject source, Map<String,String> fieldMapping) {
        return writeToTargetRecord(target, source, fieldMapping, false);
    }

    /*
     * @Name        writeToTargetRecord
     * @Description write field values from one record to another
     * @Author      Graeme Ward
     * @Params      target: target record
     *              source: source record
     *              fieldMapping: field mapping, source field api name => target field api name
     * @Return      SObject: updated target record
     */
    public static SObject writeToTargetRecord(SObject target, SObject source, Map<String,String> fieldMapping, Boolean checkNull) {

        for(String field : fieldMapping.keySet()) {
            if(!checkNull || (checkNull && target.get(fieldMapping.get(field)) == null)) {
                target.put(fieldMapping.get(field), getFieldValue(source, field));
            }
        }

        return target;
    }

    /*
     * @Name        convertListToMap
     * @Description create a map from a list of records with any field as the key
     * @Author      Graeme Ward
     * @Params      records: list of records to be converted to the map
     *              keyField: field to use as the key
     * @Return      String: serialized map, to be deserialized to the appropriate type by the calling method
     */
    public static String convertListToMap(List<SObject> records, String keyField) {
        return convertListToMap(records, keyField, null, true);
    }

    /*
     * @Name        convertListToMap
     * @Description create a map from a list of records with any field as the key
     * @Author      Graeme Ward
     * @Params      records: list of records to be converted to the map
     *              keyField: field to use as the key
     *              valueList: whether or not to store more than one value per key (defaults to true)
     * @Return      String: serialized map, to be deserialized to the appropriate type by the calling method
     */
    public static String convertListToMap(List<SObject> records, String keyField, Boolean valueList) {
        return convertListToMap(records, keyField, null, valueList);
    }

    /*
    * @Name        convertListToMap
    * @Description create a map from a list of records with any field as the key
    * @Author      Graeme Ward
    * @Params      records: list of records to be converted to the map
    *              keyField: field to use as the key
    *              valueField: field to use as the value, if parameter is blank the record is used as the value
    *              valueList: whether or not to store more than one value per key (defaults to true)
    * @Return      String: serialized map, to be deserialized to the appropriate type by the calling method
    */
    public static String convertListToMap(List<SObject> records, String keyField, String valueField, Boolean valueList) {
        Map<Object,List<Object>> recordMapList;
        Map<Object,Object> recordMapObject;

        if(valueList) {
            recordMapList = new Map<Object,List<Object>>();
        } else {
            recordMapObject = new Map<Object,Object>();
        }

        for (SObject rec : records) {
            Object keyFieldValue = getFieldValue(rec, keyField);
            List<Object> objs;
            Object obj = String.isNotBlank(valueField) ? getFieldValue(rec, valueField) : rec;

            if (valueList) {
                objs = recordMapList.get(keyFieldValue);
            }

            if (valueList && objs == null) {
                objs = new List<Object>();
            }

            if(valueList) {
                objs.add(obj);
                recordMapList.put(keyFieldValue, objs);
            } else {
                recordMapObject.put(keyFieldValue, obj);
            }
        }

        String response;

        if(valueList) {
            response = JSON.serialize(recordMapList);
        } else {
            response = JSON.serialize(recordMapObject);
        }

        return response;
    }

    public static Id getRecordTypeIdByDeveloperName(String objName, String developerName) {
        return Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }

    public static String getRecordTypeDeveloperNameById(String objName, String id) {
        return Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosById().get(id).getDeveloperName();
    }

    /*
     * @Name        getFieldPicklistValues
     * @Description get the picklist values from an object field
     * @Author      Graeme Ward
     * @Params      objectName: API name of the object
     *              fieldName: API name of the field
     *              defaultNone: whether the picklist values should include a 'None' option
     * @Return      List<OptionWrapper>: wrapper class containing picklist value, key and label
     */
    public static List<OptionWrapper> getFieldPicklistValues(String objectName, String fieldName, Boolean defaultNone) {
        List<OptionWrapper> options = new List<OptionWrapper>();

        if(defaultNone) options.add(new OptionWrapper('', ''));

        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.SObjectField field = objectType.getDescribe().fields.getMap().get(fieldName);
        List<Schema.PicklistEntry> listAllValues = field.getDescribe().getPicklistValues();

        for(Schema.PicklistEntry status : listAllValues ) {
            options.add(new OptionWrapper(status.getValue(),status.getLabel()));
        }

        return options;
    }

    /*
     * @Name        getFieldValue
     * @Description get field value from SObject field, including lookup fields to any level
     * @Author      Graeme Ward
     * @Params      SObject: SObject record
     *              field: api name of field to fetch the value of
     * @Return      Object: value of field as object
     */
    public static Object getFieldValue(SObject o, String field) {
        if(o == null) return null;

        if(field.contains('.')) {
            String relation = field.substringBefore('.');
            String nextField = field.substringAfter('.');
            return getFieldValue((SObject)o.getSObject(relation), nextField);
        } else {
            return o.get(field);
        }
    }

    /*
     * @Name        getIdsFromField
     * @Description iterates over a list of records and fetches the id values from a specified field
     * @Author      Graeme Ward
     * @Params      SObject: SObject record
     *              field: api name of field from which to fetch ids
     * @Return      Set<Id>: set of collected ids
     */
    public static Set<Id> getIdsFromField(List<SObject> records, String field) {
        Set<Id> ids = new Set<Id>();

        for(SObject o : records) {
            String id = String.valueOf(getFieldValue(o, field));

            if(String.isNotBlank(id)) {
                ids.add(id);
            }
        }

        return ids;
    }

    public static String generateRandomEmail() {
        return generateRandomString(5) + '@' + generateRandomString(5) + '.com';
    }

    public static String generateRandomPhoneNumber() {
        return generateRandomInteger(3) + '-' + generateRandomInteger(3) + '-' + generateRandomInteger(4);
    }

    public static String generateRandomString() {
        return generateRandomString(5, 15);
    }

    public static String generateRandomString(Integer characters) {
        return generateRandomString(characters, characters);
    }

    public static String generateRandomString(Integer min, Integer max) {
        Integer length = Math.round(Math.random() * (max - min)) + min;
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

        String randStr = '';

        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }

        return randStr;
    }

    public static Integer generateRandomInteger() {
        return generateRandomInteger(3);
    }

    public static Integer generateRandomInteger(Integer characters) {
        return generateRandomInteger(characters, characters);
    }

    public static Integer generateRandomInteger(Integer min, Integer max) {
        Integer length = Math.round(Math.random() * (max - min)) + min;
        String chars = '0123456789';

        String randStr = '';

        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }

        return Integer.valueOf(randStr);
    }

    // WRAPPER CLASSES
    public class OptionWrapper {
        public String key;
        public String label;
        public String value; // value used for lightning:dualListBox

        public OptionWrapper(String key, String label) {
            this.key = key;
            this.label = label;
            this.value = key;
        }
    }
}