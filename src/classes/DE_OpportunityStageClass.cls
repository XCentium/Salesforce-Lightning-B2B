/*public with sharing class DE_OpportunityStageClass {

    private final Opportunity mysObject;
    public String oppStageList {get;set;}
    public String oppStageNum {get;set;}
    public DE_OpportunityStageClass(ApexPages.StandardController stdController) {
        this.mysObject = (Opportunity)stdController.getRecord();
        oppStageList = '[\'';
        oppStageNum = '[\'';
        getPicklistValues();
    }

    public void getPicklistValues()
    {
        //Set Stage Number 
        Integer i = 1;
        //Query for All Stages in list that aren't 0% Probable (aka 'Closed Lost')
        for (OpportunityStage os : [select MasterLabel, SortOrder from OpportunityStage 
            where IsActive=true and DefaultProbability!=null and DefaultProbability!=0.0 order by SortOrder])
        {
            oppStageList += os.MasterLabel + '\', \'';
            oppStageNum += i + '\', \'';
            i += 1;
        }

        oppStageList = oppStageList.substring(0, oppStageList.length()-3);
        oppStageList = oppStageList + ']';

        oppStageNum = oppStageNum.substring(0, oppStageNum.length()-3);
        oppStageNum = oppStageNum + ']';
    }
}*/

public with sharing class DE_OpportunityStageClass {

    private final Opportunity mysObject;
    public String oppStageList {get;set;}
    public String oppStageNum {get;set;}

    public List<String> pickListVals {get; set;}
    public String valsText {get; set;}
    public Boolean loadOnce {get; set;}

    public DE_OpportunityStageClass(ApexPages.StandardController stdController) {
        this.mysObject = (Opportunity)stdController.getRecord();
        oppStageList = '[\'';
        oppStageNum = '[\'';
        loadOnce=true;
        
    }

    public void getPicklistValues()
    {
        //Set Stage Number 
        Integer i = 1;

        Set<String> closedLostStages = new Set<String>();
        //Query for All Stages in list that are 0% Probable (aka 'Closed Lost')
        for (OpportunityStage os : [select MasterLabel, SortOrder from OpportunityStage 
            where IsActive=true and DefaultProbability!=null and DefaultProbability = 0.0 order by SortOrder]) {
            closedLostStages.add(os.MasterLabel);
        }
        
        for (String os : pickListVals) {
            //Ensure 0% probability stages aren't included in header
            if (!closedLostStages.contains(os)) {
                oppStageList += os  + '\', \'';
                oppStageNum += i + '\', \'';
                i += 1;    
            }
                    
        }

        oppStageList = oppStageList.substring(0, oppStageList.length()-3);
        oppStageList = oppStageList + ']';

        oppStageNum = oppStageNum.substring(0, oppStageNum.length()-3);
        oppStageNum = oppStageNum + ']';
    }

    public PageReference reload(){
        pickListVals=new List<String>();
        Boolean skip=true;
        for (String val : valsText.split(':')){
            if (skip){
                skip=false;
            } else {
                pickListVals.add(val);
            }
        }
        getPicklistValues();
        loadOnce=false;

        return null;
    }
}