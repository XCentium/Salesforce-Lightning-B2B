global class SSETriggerBuilder {

    //Get a list of all objects in the org
    @RemoteAction
    global static List<objectWrapper> getObjects() {
        List<objectWrapper> allObjects = new List<objectWrapper>();
        for(Schema.SObjectType singleObject : ProcessInstance.TargetObjectId.getDescribe().getReferenceTo()){ 
            if(!singleObject.getDescribe().getName().contains('__kav'))
                allObjects.add(new objectWrapper(singleObject.getDescribe().getName(), singleObject.getDescribe().getLabel()));
        }
        return allObjects;
    }

    //Get a list of an objects fields
    @RemoteAction
    global static List<fieldWrapper> getFields(String objectName) {
        List<fieldWrapper> allFields = new List <fieldWrapper>();
        for(Schema.SObjectField singleField : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()){ 
            allFields.add(new fieldWrapper(singleField.getDescribe().getName(),singleField.getDescribe().getType().name(), singleField.getDescribe().getLabel()));
        }
        return allFields;
    }
    
    //Wrapper to contain object name and label
    global class objectWrapper{
        public String fieldName {get;set;}
        public String fieldLabel {get;set;}
        public objectWrapper(String fieldName, String fieldLabel){
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
        }
    }
    
    //Wrapper to container field name, label and type
    global class fieldWrapper{
        public String fieldName {get;set;}
        public String fieldType {get;set;}
        public String fieldLabel {get;set;}
        public fieldWrapper(String fieldName, String fieldType, String fieldLabel){
            this.fieldName = fieldName;
            this.fieldType = fieldType;
            this.fieldLabel = fieldLabel;
        }
    }
    
    //Test Method
    static testMethod void triggerCreateTest() {
        SSETriggerBuilder.getObjects();
        SSETriggerBuilder.getFields('Account');
    }


}