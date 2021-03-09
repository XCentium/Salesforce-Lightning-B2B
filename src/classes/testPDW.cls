@isTest
private class testPDW {
	static testMethod void testPDW(){
		
		Account newAcct = new Account();
		Contact newCont = new Contact();
		Case newCase = new Case();
		Opportunity newOpp = new Opportunity(); 
		Task newTask = new Task();
		Event newEvent = new Event();
		Asset newAsset = new Asset();
		Contract newContract = new Contract();
		Campaign newCampaign = new Campaign();
		Quote newQuote = new Quote();
		
		
		newAcct.Name = 'test';
		newAcct.BillingCountry = 'US';
		insert newAcct;
		
		newCont.firstName = 'test';
		newCont.lastName = 'test';
		
		insert newCont;
		
		
		newOpp.Name = 'Test Job';
		newOpp.Probability = 50;
		newOpp.StageName = 'Prospect';
		newOpp.CloseDate = System.today();
		newOpp.DB_Days__c = 3;
		insert newOpp;
		
		newTask.ActivityDate = System.today();
		newTask.whoId = newCont.Id;
		newTask.whatId = newAcct.Id;
		newTask.Subject = 'test';
		newTask.Priority = 'Normal';
		newTask.Status = 'Not Started';
		newTask.DB_Days__c = 3;
		
		insert newTask;
		
		newEvent.Subject = 'test';
		newEvent.StartDateTime = System.now();
		newEvent.EndDateTime = System.now();
		newEvent.DB_Days__c = 3;
		
		insert newEvent;
		
		newAsset.Name = 'test';
		newAsset.DB_Days__c = 3;
		newAsset.AccountId = newAcct.Id;
		insert newAsset; 
		
		newContract.AccountId = newAcct.Id;
		newContract.Status = 'Draft';
		newContract.StartDate = System.Today();
		newContract.ContractTerm = 36;
		newContract.DB_Days__c = 3;
		
		insert newContract;
		
		newCampaign.Name = 'test';
		newCampaign.DB_Days__c = 3;
		
		insert newCampaign;
		
		newCase.Origin = 'Phone';
		newCase.Status = 'New';
		newCase.DB_Hours__c = 32;
		newCase.DB_Case_Duration_Hours__c = 48;
		
		insert newCase;
		
		newQuote.OpportunityId = newOpp.Id;
		newQuote.Name = 'test';
		
		insert newQuote;
		
		
						
	   perfectionStandard perfectTest = new PerfectionStandard();
	   perfectTest.testing = true;


	   perfectTest.all();
	   
	   	   System.assert(perfectTest.getAss() != null);
	    System.assert(perfectTest.getTs() != null);
	     System.assert(perfectTest.getEs() != null);  
	     System.assert(perfectTest.getOs() != null);
	    System.assert(perfectTest.getCts() != null);
	     System.assert(perfectTest.getCps() != null);  
	     System.assert(perfectTest.getCs() != null);
	    System.assert(perfectTest.getQts() != null);
		
		
			
	}
}