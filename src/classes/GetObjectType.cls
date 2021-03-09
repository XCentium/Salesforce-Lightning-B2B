global class GetObjectType {
	global class Response {
        @InvocableVariable
        global string objtype;
    }
    
    global class Input {
        @InvocableVariable
        global String recId;
    }
    @InvocableMethod(label='Get Object Type' description='Uses Record ID to determine which Object you are starting from.')
    global static List<Response> getObjectResults(List<Input> inputs) {
        List<Response> responses = new List<Response>();
        for(Input input : inputs) {
            Id rid = input.recId;
            Response response = new Response();
            Schema.SObjectType sobjectType = rid.getSObjectType();
            
            string type = String.valueOf(sobjectType);
            if(type == 'Account'){
            	String checkType = [SELECT RecordType.Name FROM Account WHERE ID = :rid].RecordType.Name;
                if(checkType == 'Person Accounts'){
                    response.objtype = 'Person Account';
                }else{
                   response.objtype = type; 
                }
            }else{
               response.objtype = type; 
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}