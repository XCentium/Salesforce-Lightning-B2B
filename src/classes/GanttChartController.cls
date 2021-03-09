//This class is used by the custom Gantt charts on the Projects and Milestones object page layouts.  Added in April 2016.  

public with sharing class GanttChartController {

    public String mytarget {get; set;}
    public String objectType {get;set;}
    public String startDateFieldName {get;set;}
    public String endDateFieldName {get;set;}
    public String idFieldName {get;set;}
    public String fullViewURL {get;set;}
 
    private String nameFieldName;
    private String completedFieldName;
    private String filterFieldName;
    
    public List<Sobject> sobjectList {get;set;}
    public Sobject sobjectList1 {get;set;}
    private static final String REGEXP_QUOTES    = '(?<!\\\\)"';
    
    public static final String COLOR_COMPLETE = '#333333';
    public static final String COLOR_LATE = '#ee3322';
    public static final String COLOR_FUTURE = '#666666';
    public static final String COLOR_CURRENT = '#2299bb';
    
    public String getProjectGanttJson() {
        
        String ret;
        initFieldNames();
        retrieveData();
        ret = toJSon();
        
        return ret;
    }
    
    /*
    *   Initialize the variables depending on the object type possible values: 
    *   Milestone1_Milestone__c and Milestone1_Task__c
    */
    private void initFieldNames(){
      if(mytarget != null){
        if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
          startDateFieldName = 'Kickoff__c';
          endDateFieldName = 'Deadline__c';
          nameFieldName = 'NameClean__c';
          filterFieldName = 'Project__c';
          objectType = 'Milestone1_Milestone__c';
        }else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){
          startDateFieldName = 'Start_Date__c';
          endDateFieldName = 'Due_Date__c';
          nameFieldName = 'Name';
          filterFieldName = 'Project_Milestone__c';
          objectType = 'Milestone1_Task__c';
        } else {
          throw new Milestone1_Exception('[initFieldNames] Unable to generate JSON for ' + mytarget);
        }
        idFieldName = 'Id';
        completedFieldName = 'Complete__c';  
      }
    }
    
    /*
    *   Retrieve the data doing a dynamic query by object type.
    */
    private void retrieveData(){
      
      String query = 'Select '+idFieldName+','+startDateFieldName+','+endDateFieldName+','+nameFieldName+','+completedFieldName+
               ',Percent__c, Dependencies__r.Name from '+objectType+ ' where '+filterFieldName+'=\''+mytarget+'\' order by Name';
      sobjectList = Database.query(query);
    }
    
    /**
    *  Generate the output in json format to be rendered in the jquery gantt.
    */
    private String toJSon(){
      
        String ret = '[';
      Boolean addComma=false,completed;
      Date startDate,endDate;
      String name,id,percent,dependencies;
        
        for (Sobject current : sobjectList){ 
            
            if(current.get(startDateFieldName) == null){
              startDate = Date.today();
            }else{
              startDate = Date.valueOf(current.get(startDateFieldName));
            }
            if(current.get(endDateFieldName) == null){
              endDate = startDate;
            }else{
              endDate = Date.valueOf(current.get(endDateFieldName));
            }
            completed = Boolean.valueOf(current.get(completedFieldName));
            name = escapeDoubleQuotes(String.valueOf(current.get(nameFieldName)));
            id = String.valueOf(current.get(idFieldName));
            
            if(current.get('Percent__c') == null){
              percent = '0';
            }
            else if(Integer.valueOf(current.get('Percent__c')) > 100){
                percent = '100';
            }
            else{
                percent = String.valueOf(current.get('Percent__c'));
            }
            
            System.debug('Dependencies__c!!!!!! '+current.get('Dependencies__c'));
            if(current.get('Dependencies__c') == null || current.get('Dependencies__c') == '' || String.valueOf(current.get('Dependencies__c')) == 'null'){
              dependencies = null;
                System.debug('if dependencies '+dependencies);
            }
            else{
                String query = 'Select Name FROM '+objectType+' where Id = \'' +current.get('Dependencies__c')+ '\' order by Name LIMIT 1';
          sobjectList1 = Database.query(query);
                String dependencies1 = String.valueOf(sobjectList1.get('Name'));
                dependencies = '"'+dependencies1+'"';
                System.debug('else dependencies '+dependencies);
            }
            
            if (addComma) { ret += ','; }
                        
            ret +=  '["'+name+'",'+
                  '"'+name+'",'+
                  'new Date('+startDate.year()+','+(startDate.month()-1)+','+ startDate.day()+'),'+
                  'new Date('+endDate.year()+','+ (endDate.month()-1)+','+ endDate.day()+'),'+
                  'null,'+
                  percent+','+
                  dependencies+
                  ']';
            //System.debug('ret JSON '+ret);
                  
            addComma=true;            
        }
        return ret;     
    }
    
    private String escapeDoubleQuotes(String word){
      return word.replaceAll(REGEXP_QUOTES,'\\\\"');
    }
}