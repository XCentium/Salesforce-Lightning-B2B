global class JBPKanbanController {
       
    public List<Task> theTasks { get; set; }
    //public List<String> theStatus { get; set; }
    public String JsonHeading { get; set; }
    public String taskSet { get; set; }
    
    public JBPKanbanController(ApexPages.StandardController stdController){
        theTasks = [ SELECT Id, Subject, Status, Description, ActivityDate FROM Task WHERE WhatId =: ApexPages.currentPage().getParameters().get('id') ORDER BY ActivityDate, Subject];
        
        JsonHeading = getHeadingsJSON();
        System.Debug('JsonHeading:' + JsonHeading);
        
        taskSet = getTasksJSON(theTasks);
        System.Debug('taskSet:' + taskSet);
    }

    // getHeadingsJSON
    public String getHeadingsJSON() {

        String headingsJSON;
        List<String> theStatus = getTaskStatus();

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        
            for(String s : theStatus) {
                gen.writeStartObject();
                gen.writeStringField( 'header', s);
                gen.writeFieldName('body');
                //gen.writeString('body');
                    gen.writeStartObject();
                        gen.writeStringField( 'view', 'kanbanlist');
                        gen.writeStringField( 'status', s);
                        gen.writeStringField( 'type', 'avatars');
                    gen.writeEndObject();
                gen.writeEndObject();
            }
 
        gen.writeEndArray();

        headingsJSON = gen.getAsString();
        return headingsJSON;
    }
    
    // getTasksJSON
    public String getTasksJSON(List<Task> tList) {

        String taskJSON;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        
            for(Task t : tList) {
                gen.writeStartObject();
                    gen.writeStringField( 'id', t.Id );
                    gen.writeStringField( 'status', t.Status );
                    gen.writeStringField( 'text', t.Subject );
                gen.writeEndObject();
            }
 
        gen.writeEndArray();

        taskJSON = gen.getAsString();
        return taskJSON;
    }
    
    public List<String> getTaskStatus() {

        List<String> options = new List<String>();           
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)  {
            options.add( f.getLabel() );
        }       
        return options;
    }
    
    @remoteAction
    global static String getTasks(String thePlanningId){
        List<Task> alltasks = [SELECT Id, Subject, Status, ActivityDate, Description FROM Task WHERE WhatId =: thePlanningId ORDER BY ActivityDate, Subject];
        
        return null;
    }
    
    @remoteAction
    global static Task updateTaskStatus(String theId, String newStatus) {
        Task theTask = [SELECT Id, Status FROM Task WHERE Id =: theId];
        theTask.Status = newStatus;
        update theTask;
        return theTask;
    }
    
}