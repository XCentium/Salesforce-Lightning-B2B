global class PSMetaUtils
{
  public PSMetaUtils()
  {

  }

  global static String getObjectMetaFieldDesc(String objtype, String field)
  {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

    Schema.DescribeFieldResult descField = fieldMap.get(field).getDescribe();
    return JSON.serializePretty(descField);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  // borrrowed and slightly modified this method from Shane McLaughlin for my needs //
  ////////////////////////////////////////////////////////////////////////////////////
  @AuraEnabled
  global static String getMetaFieldDesc2(String objtype, String filterFields)
  {
    System.debug('objtype=' + objtype);
    System.debug('filterFields=' + filterFields);

    List<PSField> fieldList = new List<PSField>();


    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
    if (targetType == null)
    {
      return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
    }

    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

    // set list of fields to describe
    List<String> keySet = null;
    keySet = PSDemoUtils.parseCSVString(filterFields);
    if (keySet == null)
    {
      keySet = new List<String>(fieldMap.keySet()); 
    }
    System.debug('keySet=' + keySet);

    String fld;
    String fieldKeyDef = null;

    for (String key : keySet)
    {
      fld = key;

      if (key.contains('>'))
      {
         fld = key.substringBefore('>');
         fieldKeyDef = key.substringAfter('>');
      }

      /////////////////////////////////////////
      // get the core metadata def for field //
      /////////////////////////////////////////
      Schema.DescribeFieldResult descField = fieldMap.get(fld).getDescribe();
      PSField field = new PSField();
      field.ftype = descField.getType().name().toLowerCase();
      field.label = descField.getLabel();
      field.name = descField.getName();

      //if a field is a picklist, I want the values
      if (field.ftype == 'picklist' || field.ftype == 'multipicklist')
      {
        List<Schema.PicklistEntry> pickListValues = descField.getPickListValues();
        List<pickListValues> options = new List<picklistValues>();
        for (Schema.PicklistEntry plv : pickListValues)
        {
          field.addOption(plv.getLabel(), plv.getValue());
        }
      }

      /////////////////////////////////////////
      // check for field definition override //
      /////////////////////////////////////////
      if (fieldKeyDef != null)
      {
         System.debug('fieldKeyDef=' + fieldKeyDef);

         List<PSSearchFieldDef__c> defList = [SELECT Field_Definition__c FROM PSSearchFieldDef__c WHERE Key__c = :fieldKeyDef];

         if (defList != null && defList.size() == 1)
         {
           System.debug('def=' + defList[0].Field_Definition__c);
           field = PSSearchFieldDef.parseFieldDef(defList[0].Field_Definition__c);
           System.debug('fld=' + JSON.serializePretty(field));
         }
      }

      fieldList.add(field);
    }

    return JSON.serialize(fieldList);
  }
    
  @AuraEnabled
  global static String getMetaFieldDesc3(String objtype, String filterFields)
  {
    System.debug('objtype=' + objtype);
    System.debug('filterFields=' + filterFields);
    filterFields = prepFilterFieldString(filterFields, '^');

    List<PSField> fieldList = new List<PSField>();
      
    List<String> keyList = null;
    keyList = PSDemoUtils.parseCSVString(filterFields);
    
    for (String key : keyList)
    {
      String fieldName = key;
      String fieldOptions = null;
      PSField psField;

      // get field options if they exist
      if (fieldName.contains('|'))
      {
         fieldName = key.substringBefore('|');
         fieldOptions = key.substringAfter('|').replace('^',',');
      }
        
      // traverse field parent references  
      if (fieldName.contains('.'))
      {
         psField = getFieldDef(objtype, fieldName, fieldOptions);
      }
      else
      {
         psField = getFieldDef(objtype, fieldName, fieldOptions);
      }
      /*
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
    if (targetType == null)
    {
      return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
    }

    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

    // set list of fields to describe
    List<String> keySet = null;
    keySet = PSDemoUtils.parseCSVString(filterFields);
    if (keySet == null)
    {
      keySet = new List<String>(fieldMap.keySet()); 
    }
    System.debug('keySet=' + keySet);

    String fld;
    String fieldKeyDef = null;

    for (String key : keySet)
    {
      fld = key;

      // get field options if they exist
      if (fld.contains('|'))
      {
         fld = key.substringBefore('|');
         fieldKeyDef = key.substringAfter('|');
      }
        
      // traverse field parent references  
      PSField field;
      if (fld.contains('.'))
      {
         String origFieldName = fld;
         List<String> tmpList = PSDemoUtils.parseDelimitedString(fld, '.');
         for (String tmpStr : tmpList)
         {
             Map<String, Schema.SObjectField> tmpMap = Schema.getGlobalDescribe().get(objtype).getDescribe().fields.getMap();

         }
      }
      else
      {
          field = convertField(fieldMap, fld, fieldKeyDef);
      }
*/

      fieldList.add(psField);
    }

    return JSON.serialize(fieldList);
  }
  
  private static PSField convertField(Map<String, Schema.SObjectField> fieldMap, String fld, String fieldKeyDef)
  {
      Schema.DescribeFieldResult descField = fieldMap.get(fld).getDescribe();
      PSField field = new PSField();
      field.ftype = descField.getType().name().toLowerCase();
      field.label = descField.getLabel();
      field.name = descField.getName();

      //if a field is a picklist, I want the values
      if (field.ftype == 'picklist' || field.ftype == 'multipicklist')
      {
        List<Schema.PicklistEntry> pickListValues = descField.getPickListValues();
        List<pickListValues> options = new List<picklistValues>();
        for (Schema.PicklistEntry plv : pickListValues)
        {
          field.addOption(plv.getLabel(), plv.getValue());
        }
      }

      ////////////////////////////////////
      // check for field config options //
      ////////////////////////////////////
      if (fieldKeyDef != null)
      {
         field.setConfigOptions((Map<String, String>)JSON.deserialize(fieldKeyDef, Map<String,String>.class));
      } 
      
      return field;
  }

  ////////////////////////////////////////////////////////////////////////////////////
  // borrrowed and slightly modified this method from Shane McLaughlin for my needs //
  ////////////////////////////////////////////////////////////////////////////////////
  @AuraEnabled
  global static String getMetaFieldDesc(String objtype, String filterFields)
  {
    System.debug('objtype=' + objtype);
    System.debug('filterFields=' + filterFields);


    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
    if (targetType == null)
    {
      return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
    }

    Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

    // set list of fields to describe
    List<String> keySet = null;
    keySet = PSDemoUtils.parseCSVString(filterFields);
    if (keySet == null)
    {
      keySet = new List<String>(fieldMap.keySet()); 
    }
    System.debug('keySet=' + keySet);

    List<Object> fields = new List<Object>();
    for (String key : keySet)
    {
      Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
      Map<String, Object> field = new Map<String, Object>();

      field.put('type', descField.getType().name().toLowerCase());
      field.put('name', descField.getName());
      field.put('value', null);
      field.put('label', descField.getLabel());
      field.put('userCanRead', descField.isAccessible());
      field.put('userCanEdit', descField.isUpdateable());
      field.put('help', descField.getInlineHelpText());
      field.put('default', descField.getDefaultValue());
      field.put('isHTML', descField.isHtmlFormatted());

      //if a field is a picklist, I want the values
      if (field.get('type') == 'picklist')
      {
        List<Schema.PicklistEntry> pickListValues = descField.getPickListValues();
        List<pickListValues> options = new List<picklistValues>();
        for (Schema.PicklistEntry plv : pickListValues)
        {
          pickListValues pv = new pickListValues();
          pv.label = plv.getLabel();
          pv.value = plv.getValue();
          options.add(pv);
        }
        field.put('picklistOptions', options);
      }

      List<String> references = new List<String>();
      for (Schema.sObjectType t : descField.getReferenceTo())
      {
        references.add(t.getDescribe().getName());
      }
      if (!references.isEmpty())
      {
        field.put('referenceTo', references);
      }

      fields.add(field);
    }

    Map<String, Object> result = new Map<String, Object>();
    result.put('fields', fields);

    Map<string, string> objectProperties = new map<string, string>();
    objectProperties.put('pluralLabel', sobjResult.getLabelPlural());
    result.put('objectProperties', objectProperties);

    return JSON.serialize(result);
  }
    
    public static PSField getFieldDef(String objtype, String fld, String fieldOptions)
    {
        System.debug('objtype=' + objtype);
        System.debug('field=' + fld);
        System.debug('fieldOptions=' + fieldOptions);
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null)
        {
             throw new PSIllegalArgumentException('Invalid object name [' + objtype + ']');
        }
        
        PSField tmpField;
        
        if (fld.contains('.'))
        {
            String tmpStr = fld.substringBefore('.');
            tmpField = getFieldDef(objtype, tmpStr, fieldOptions);
            if (tmpField == null) return null;
            tmpField = getFieldDef(tmpField.referenceTo, fld.substringAfter('.'), fieldOptions);
            tmpField.name = fld;
            //return tmpField;
        }
        else
        {
            
            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
            Schema.DescribeFieldResult descField;
            if (fieldMap.containsKey(fld))
            {
                descField = fieldMap.get(fld).getDescribe();
            }
            else if (fieldMap.containsKey(fld + 'Id'))
            {
                descField = fieldMap.get(fld + 'Id').getDescribe();
            }
            else
            {
               throw new PSIllegalArgumentException('Invalid field name [' + fld + '] for object [' + objtype + ']');
            }
            
            tmpField = new PSField();
            tmpField.ftype = descField.getType().name().toLowerCase();
            tmpField.label = descField.getLabel();
            tmpField.name = descField.getName();
            
            //if a field is a picklist, I want the values
            if (tmpField.ftype == 'picklist' || tmpField.ftype == 'multipicklist')
            {
                List<Schema.PicklistEntry> pickListValues = descField.getPickListValues();
                List<pickListValues> options = new List<picklistValues>();
                for (Schema.PicklistEntry plv : pickListValues)
                {
                    tmpField.addOption(plv.getLabel(), plv.getValue());
                }
            }
            else if (tmpField.ftype == 'reference')
            {
                tmpField.referenceTo = descField.getReferenceTo()[0].getDescribe().getName();
                tmpField.relationshipName = descField.getRelationshipName();
            }
            
            if (fieldOptions != null)
            {
                Map<String, String> options = (Map<String, String>)JSON.deserialize(fieldOptions, Map<String,String>.class);
                tmpField.setConfigOptions(options);
                
                if (options.containsKey('label'))
                {
                    tmpField.label = options.get('label');
                }
                
                if (options.containsKey('value'))
                {
                    tmpField.value = options.get('value');
                }
                
                if (options.containsKey('wildcard'))
                {
                    tmpField.wildcard = Boolean.valueOf(options.get('wildcard'));
                }
            } 
        }
        
        
        
        return tmpField;
        
    }
    
    public static String prepFilterFieldString(String str, String replaceStr)
    {
        // ********************************************************************* //
        // I'm not a regex person so doing this for now until I can figure out a //
        // regex expression to do this                                           //
        // ********************************************************************* //
        if (str == null || str.length() ==0) return str;
        
        String[] chars = str.split('');
        chars.remove(0);

        Boolean insideCurly = false;
        for (Integer i=0; i<chars.size(); i++)
        {
            if (chars[i] == '{')
            {
                insideCurly = true;
            }
            else if (chars[i] == '}')
            {
                insideCurly = false;
            }
            else if (chars[i] == ',')
            {
               if (insideCurly)
               {
                   chars[i] = replaceStr;
               }
            }

        }
        
        return String.join(chars, '');
    }
    
    @AuraEnabled
    global static String getSingleFieldDesc(String objtype, String fld)
  {
    PSField field = getFieldDef(objtype, fld, null);
    if (field == null)
    {
        return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
    }
    
    return JSON.serialize(field);

  }

  global class picklistValues
  {
    String label {get; set;}
    String value {get; set;}
  }

  // Converts a base64 string into a list of integers representing the encoded bytes
  public static List<Integer> B64ToBytes (String sIn)
  {
    Map<Integer, Integer> base64 = new Map<Integer, Integer> {65 => 0, 66 => 1, 67 => 2, 68 => 3, 69 => 4, 70 => 5, 71 => 6, 72 => 7, 73 => 8, 74 => 9, 75 => 10, 76 => 11, 77 => 12, 78 => 13, 79 => 14, 80 => 15, 81 => 16, 82 => 17, 83 => 18, 84 => 19, 85 => 20, 86 => 21, 87 => 22, 88 => 23, 89 => 24, 90 => 25
        , 97 => 26, 98 => 27, 99 => 28, 100 => 29, 101 => 30, 102 => 31, 103 => 32, 104 => 33, 105 => 34, 106 => 35, 107 => 36, 108 => 37, 109 => 38, 110 => 39, 111 => 40, 112 => 41, 113 => 42, 114 => 43, 115 => 44, 116 => 45, 117 => 46, 118 => 47, 119 => 48, 120 => 49, 121 => 50, 122 => 51
        , 48 => 52, 49 => 53, 50 => 54, 51 => 55, 52 => 56, 53 => 57, 54 => 58, 55 => 59, 56 => 60, 57 => 61, 43 => 62, 47 => 63
                                                             };

    List<Integer> lstOut = new List<Integer>();
    if ( sIn == null || sIn == '' ) return lstOut;

    sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

    for ( Integer idx = 0; idx < sIn.length(); idx += 4 )
    {
      if ( base64.get(sIn.charAt(idx + 1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx + 1)) >>> 4) );
      if ( base64.get(sIn.charAt(idx + 2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx + 1)) & 15) << 4) | (base64.get(sIn.charAt(idx + 2)) >>> 2) );
      if ( base64.get(sIn.charAt(idx + 3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx + 2)) & 3) << 6) | base64.get(sIn.charAt(idx + 3)) );
    }

    //System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
    return lstOut;
  }//B64ToBytes
  public static List<Integer> BlobToBytes (Blob input)
  {
    return B64ToBytes( EncodingUtil.base64Encode(input) );
  }//BlobToBytes

// Converts a base64 string into a list of integers indicating at which position the bits are on
  public static List<Integer> cnvBits (String b64Str)
  {
    List<Integer> lstOut = new List<Integer>();
    if ( b64Str == null || b64Str == '' ) return lstOut;

    List<Integer> lstBytes = B64ToBytes(b64Str);

    Integer i, b, v;
    for ( i = 0; i < lstBytes.size(); i++ )
    {
      v = lstBytes[i];
      //System.debug ( 'i['+i+'] v['+v+']' );
      for ( b = 1; b <= 8; b++ )
      {
        //System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
        if ( ( v & 128 ) == 128 ) lstOut.add( (i * 8) + b );
        v <<= 1;
      }
    }

    //System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
    return lstOut;
  }//cnvBits

  public class TPicklistEntry
  {
    public string active {get; set;}
    public string defaultValue {get; set;}
    public string label {get; set;}
    public string value {get; set;}
    public string validFor {get; set;}
    public TPicklistEntry() {}
  }//TPicklistEntry

  public static List<String> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName, String value)
  {
    Map<String, List<String>> valueMap = GetDependentOptions(pObjName, pControllingFieldName, pDependentFieldName);
    if (valueMap.containsKey(value))
    {
      List<String> tmpList = valueMap.get(value);
      if (tmpList == null || tmpList.size() == 0)
      {
        return null;
      }
      else
      {
        tmpList.add('');
        tmpList.sort();
        return tmpList;
      }

    }
    return null;
  }

  public static Map<String, List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName)
  {
    Map<String, List<String>> mapResults = new Map<String, List<String>>();

    //verify/get object schema
    Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
    if ( pType == null ) return mapResults;
    Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

    //verify field names
    if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;

    //get the control & dependent values
    List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
    List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

    //clear heap
    objFieldMap = null;

    //initialize results mapping
    for (Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++)
    {
      mapResults.put( ctrl_ple[pControllingIndex].getLabel(), new List<String>());
    }
    //cater for null and empty
    mapResults.put('', new List<String>());
    mapResults.put(null, new List<String>());

    //serialize dep entries
    List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
    objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

    List<Integer> validIndexes;
    for (TPicklistEntry objDepPLE : objDS_Entries)
    {

      validIndexes = cnvBits(objDepPLE.validFor);
      //System.Debug('cnvBits: [' + objDepPLE.label + '] = ' + validIndexes);

      for (Integer validIndex : validIndexes)
      {
        mapResults.get( ctrl_ple[validIndex - 1].getLabel() ).add( objDepPLE.label );
      }
    }

    //clear heap
    objDS_Entries = null;

    return mapResults;
  }//GetDependentOptions
}