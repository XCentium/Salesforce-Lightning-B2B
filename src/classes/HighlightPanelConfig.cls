public with sharing class HighlightPanelConfig {
    public List<FieldInfo> Fields {get;set;}
    public List<FieldInfo> NumberFields {get;set;}
    public string selectedObject {get;set;}
    
    public HighlightPanelConfig() {
        Fields = new List<FieldInfo>();
        NumberFields = new List<FieldInfo>();
        selectedObject = 'Account';
        updateFieldList();
    }
   
    public List<SelectOption> getObjects() {
        List<SelectOption> options = new List<SelectOption>();
        
		options.add(new SelectOption('Account','Account'));
		options.add(new SelectOption('Contact','Contact'));
		options.add(new SelectOption('Lead','Lead'));
        
        return options;
    }
    
    public void updateFieldList() {
        Fields.clear();
        NumberFields.clear();
        
        if (selectedObject != null && selectedObject != '') {
            SObjectType objType = Schema.getGlobalDescribe().get(selectedObject);
 			Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
             for (Schema.SObjectField fieldObj : fieldMap.values()){
                 if (fieldObj.getDescribe().isCreateable() 
                     || fieldObj.getDescribe().isCalculated()
                     || fieldObj.getDescribe().isNameField()
                    ) {
                     FieldInfo field = new FieldInfo(fieldObj.getDescribe().getName(),
                                              fieldObj.getDescribe().getLabel());
                     Fields.add(field);
                     if (fieldObj.getDescribe().getType() == DisplayType.Integer
                         || fieldObj.getDescribe().getType() == DisplayType.Double
                         || fieldObj.getDescribe().getType() == DisplayType.Currency
                         || fieldObj.getDescribe().getType() == DisplayType.Percent) {
                             NumberFields.add(field);
                     }
                 }
             }
        }
    }
    
    public class FieldInfo {
        public string label {get;set;}
        public string name {get;set;}
        public FieldInfo(string name, string label) {
            this.name = name;
            this.label = label;
        }
    }
}