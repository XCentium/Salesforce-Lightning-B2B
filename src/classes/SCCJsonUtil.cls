public with sharing class SCCJsonUtil {

    public static Object deserializeUntyped(String jsonBody){
        return (Map<String, Object>)System.JSON.deserializeUntyped(jsonBody);
    }

    public static Object getValueByKey(String keyString, Map<String, Object> jsonObject, SCCFileLogger logger){
        List<String> keys = keyString.split('\\.');
        logger.debug('SCCJsonUtil.getValueByKey','Key components count : '+ keys.size());
        Object value;
        String index;
        try{
            if(keys.size()>0){
                for (Integer i = 0; i < keys.size(); i++) {
                    String key = keys.get(i);
                    logger.trace('SCCJsonUtil.getValueByKey','i : '+ i + ' Key : '+ key);
                    if(key.contains('[')){
                        logger.debug('SCCJsonUtil.getValueByKey','Key from list key component: '+key.substring(0, key.indexOf('[')));
                        value = jsonObject.get(key.substring(0, key.indexOf('[')));
                        if(value instanceof List<Object>){
                            index = key.substring(key.indexOf('[')+1, key.indexOf(']'));
                            logger.debug('SCCJsonUtil.getValueByKey','Key index from list key component: '+index);
                            if(index.equalsIgnoreCase('n')){
                                String compositeChildKey = getCompositeChildKey(keys, i+1);
                                i = i+compositeChildKey.split('\\.').size();
                                for (Object element : ((List<Object>)value)){
                                    value = getValueByKey(compositeChildKey, (Map<String, Object>)element, logger);
                                    logger.debug('SCCJsonUtil.getValueByKey','Calling getValueByKey iterative using composite key:  '+ compositeChildKey + ' Value from getValueByKey iterative:  '+ value);
                                }
                            }else{
                               value = ((List<Object>)value).get(Integer.valueOf(index));
                            }
                        }else{
                            logger.error('SCCJsonUtil.getValueByKey','Key doesnt exist in input JSON: '+ keyString);
                        }
                    }else{
                        value = jsonObject.get(key);
                    }
                    logger.debug('SCCJsonUtil.getValueByKey','i: '+i+ ' Key: '+ key +' keys.size() : '+  keys.size() + ' value: '+ value);
                    if(i == keys.size()-1 && (value instanceof String
                                              || value instanceof Boolean
                                              || value instanceof Decimal
                                              || value instanceof Integer)){
                        logger.trace('SCCJsonUtil.getValueByKey','Sring value for multi key: '+ keyString +' is : '+  value);
                        break;
                    }else if(value instanceof Map<String, Object>){
                        logger.trace('SCCJsonUtil.getValueByKey','Object value for key component: '+ key +' is : '+  value);
                        jsonObject = (Map<String, Object>)value;
                    }else{
                        logger.error('SCCJsonUtil.getValueByKey','Unexpected value for key component: '+ key +' is : '+  value);
                        value = null;
                        break;
                    }
                }
            }
        }catch(Exception e){
            logger.error('SCCJsonUtil.getValueByKey','Exception : '+ e.getMessage() +' StackTraceString '+e.getStackTraceString());
        }
        return value;
    }

    private static String getCompositeChildKey(List<String> keys, Integer startingIndex){
        String compositeChildKey;
        for (Integer i = startingIndex; i < keys.size(); i++) {
            if(String.isEmpty(compositeChildKey)){
               compositeChildKey = keys.get(i);
            }else{
               compositeChildKey = compositeChildKey+'.'+keys.get(i);
            }
        }
        return compositeChildKey;
    }

    /**
    * This method create string object map using patched data so later it can be serialized to JSON.
    * @param patchDataMap: Map<String, Object>
    * @param objectName: String
    * @param logger: SCCFileLogger
    * @return Map<String, Object>.
    */
    public static Map<String, Object> initializeJsonObject(Map<String, Object> patchDataMap, String objectName, SCCFileLogger logger) {
    	Map<String, Object> jsonObject = new Map<String, Object>();
    	Map<String, SObject> fieldMappings = SCCUtilityClass.getPatchCustomSettingValues(objectName, true, logger);
    	Set<String> patchDataMapKeySet = patchDataMap.keySet();
    	logger.debug('SCCJsonUtil.initializeJsonObject','fieldMappings: '+fieldMappings+' patchDataMapKeySet: '+patchDataMapKeySet);
    	String objectMappingvalue;
        for(String key : fieldMappings.keySet()) {
        	objectMappingvalue = ((String)fieldMappings.get(key).get('Field_Api_Name__c')).toLowerCase();
        	logger.debug('SCCUtilityClass.initializeJsonObject', 'key: '+ key + ' objectMappingvalue: '+objectMappingvalue +' value: '+ patchDataMap.get(objectMappingvalue));
        	if(patchDataMapKeySet.contains(objectMappingvalue) && !key.contains('[') ){
                logger.debug('SCCUtilityClass.initializeJsonObject', 'adding key: '+ key + ' objectMappingvalue: '+objectMappingvalue +' value: '+ patchDataMap.get(objectMappingvalue));
		        List<String> keyElements = key.split('\\.');
		        if(keyElements.size()>1){
		        	List<Object> tempJsonObjList = null;
		        	Map<String, Object> tempJsonObjMap = null;
	                for (Integer i = keyElements.size()-1; i >= 0; i--) {
	                    String keyComponent = keyElements.get(i);
	                    if(keyComponent.contains('[')){
	                    	//To do for later
	                    	logger.debug('SCCJsonUtil.initializeJsonObject', 'not supported keyComponent: '+ keyComponent);
	                    }else{
	                    	//If top element then add in jsonOBject
	                    	if(i == 0){
	                    		logger.debug('SCCJsonUtil.initializeJsonObject', 'adding in jsonMap key: '+ key + ' value: '+tempJsonObjMap);
	                    		jsonObject.put(keyComponent, tempJsonObjMap);
	                    	}else if(i == keyElements.size()-1){
	                    		tempJsonObjMap = new Map<String, Object>{keyComponent => patchDataMap.get(objectMappingvalue)};
	                    	}else{
	                    		tempJsonObjMap = new Map<String, Object>{keyComponent => tempJsonObjMap};
	                    	}
	                    }
	                }
		        }else{
		        	logger.debug('SCCJsonUtil.initializeJsonObject', 'adding in jsonMap key: '+ key + ' value: '+patchDataMap.get(objectMappingvalue));
		        	jsonObject.put(key, patchDataMap.get(objectMappingvalue));
		        }
        	}else{
        		logger.debug('SCCJsonUtil.initializeJsonObject', 'Ignoring key: '+ key + ' patchDataMapKeySet.contains(objectMappingvalue) :'+patchDataMapKeySet.contains(objectMappingvalue));
        	}
        }
        return jsonObject;
    }
}