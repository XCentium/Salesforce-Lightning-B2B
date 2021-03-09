global class DealRegistrationPagedResult {
    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : May 12, 2016
    
    @AuraEnabled
    public Integer pageSize { get;set; }

    @AuraEnabled
    public Integer page { get;set; }
    
    @AuraEnabled
    public Integer total { get;set; }
    
    @AuraEnabled
    public List<String> fldLabels { get;set; }

    @AuraEnabled
    public List<String> fldNames { get;set; }
    
    @AuraEnabled
    //public List<DisplayType> fldTypes { get;set; }old
	public List<String> fldTypes { get;set; }
    
    @AuraEnabled
    public List<SObject> records { get;set; }
    
}