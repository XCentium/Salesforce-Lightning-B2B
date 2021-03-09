global with sharing class GetFranchiseeData {
    @InvocableMethod
    public static List<Results> getCreditScore(List<Requests> requests)
       {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://repair-service.herokuapp.com/api/creditScore?customerId='+ requests[0].custId);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
             Results curResult = new Results();
            curResult.creditScore = Integer.valueOf(response.getBody());
           
            List<Results> resultsList = new List<results>();
            resultsList.add(curResult);
            return resultsList;
       }
    
    global class Requests {
        @InvocableVariable
      global String custId;
        
    }
    
    global class Results {
        @InvocableVariable
      global Integer creditScore;
    }
}