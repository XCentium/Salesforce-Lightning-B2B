global class IDO_NBA_classExample {
    
global class NBAResponse {
        @InvocableVariable
        global Integer numCases;
        @InvocableVariable
        global Integer getWonOppties;
    }
    
    global class NBAInput {
        @InvocableVariable
        global String recordId;
    }
    
    @InvocableMethod(label='NBA Connection' description='Return variables for NBA check')
    global static List<NBAResponse> getNBAResults(List<NBAInput> inputs) {
        List<NBAResponse> responses = new List<NBAResponse>();
        
        for(NBAInput input : inputs) {
            NBAResponse response = new NBAResponse();
            
            response.numCases = getNumberOfCases(input.recordId); // Call method to get number of cases
            response.getWonOppties = getWonOppties(input.recordId); // Call method to get number of policies
            
            responses.add(response);
        }
        
        return responses;
    }
    
    private static Integer getNumberOfCases(String accountId) {
        date casePeriod;
        casePeriod = Date.today();
        casePeriod = casePeriod.adddays(-5);
        List<Case> cases = [SELECT Id FROM Case WHERE AccountId = :accountId 
                            AND IsEscalated = True 
                            AND CreatedDate <= :casePeriod]
           ;
        return cases.size();        
    }
    
    private static Integer getWonOppties(String accountId) {
       date oppPeriod;
        oppPeriod = Date.today();
        oppPeriod = oppPeriod.addmonths(-6);
       List<AggregateResult> groupedResults =
           [select sum(Amount)sumAmount FROM Opportunity WHERE AccountId = :accountId AND IsWon = TRUE AND CreatedDate >= :oppPeriod];
     return Integer.valueOf(groupedResults[0].get('sumAmount'));
    }
}