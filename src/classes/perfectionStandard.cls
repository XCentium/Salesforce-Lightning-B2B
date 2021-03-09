public class perfectionStandard {

Date today = Date.today(); 
String Ts,Os,Ass,Cts,Cps,Es,Cs,Qts,Ods, Is;


public String getTs(){return Ts;}
public String getOs(){return Os;}
public String getAss(){return Ass;}
public String getCts(){return Cts;}
public String getEs(){return Es;}
public String getCps() { return Cps;} 
public String getCs() { return Cs;} 
public String getQts() { return Qts;} 

public Boolean testing;

	public void all() {
		doTasks();
		doOpps();
		doAssets();
		doContracts();
		doCampaigns();
		doEvents();
		doCases();
		doQuotes();

	}

	
	public PageReference doTasks(){
		
		Task[] tasks = [Select ActivityDate, DB_Days__c from Task where DB_Days__c != null and isDeleted = false and ActivityDate != null ALL ROWS];
		
		for( Task t: tasks)
		{
			t.ActivityDate = today.addDays(t.DB_Days__c.intValue()); 
		} 
		
		update tasks;
		Ts= 'Tasks are Perfect!';
		return null;
	}
	
	
	public PageReference doOpps(){
		Opportunity[] Opps;
		if(testing == true){
			 Opps= [Select CloseDate, DB_Days__c from Opportunity where DB_Days__c != null and CloseDate != null limit 5];
		}
		else{
			Opps = [Select CloseDate, DB_Days__c from Opportunity where DB_Days__c != null and CloseDate != null];
		}
		for( Opportunity o: Opps)
		{
			o.CloseDate = today.addDays(o.DB_Days__c.intValue()); 
		
		} 
		
		update Opps;
		Os='Opportunities are Perfect!'; 
		return null;
	}
	
	public PageReference doAssets(){
	
		Asset[] Assets = [Select UsageEndDate, DB_Days__c from Asset where DB_Days__c != null and UsageEndDate != null];
		
			for( Asset a : Assets)
			{
				a.UsageEndDate = today.addDays(a.DB_Days__c.intValue());
				a.PurchaseDate = a.UsageEndDate.addDays(-365);  
			} 
		
		update Assets;
		Ass='Assets are Perfect!'; 
		return null;
	}
	
	
	public PageReference doContracts(){
	
		Contract[] Contracts = [Select StartDate, DB_Days__c from contract where DB_Days__c != null and StartDate != null];
		
			for( Contract c: Contracts)
			{
				c.startdate = today.addDays(c.DB_Days__c.intValue()); 
			} 
		
		update Contracts;
		Cts='Contracts are Perfect!'; 
		return null;
	}
	
	public PageReference doCampaigns(){
	
		Campaign[] Campaigns = [Select EndDate, DB_Days__c from Campaign where DB_Days__c != null and EndDate != null];
		
			for( Campaign c: Campaigns)
			{
				c.EndDate = today.addDays(c.DB_Days__c.intValue()); 
				c.StartDate = c.EndDate.addDays(-30); 
			} 
		
		update Campaigns;
		Cps='Campaigns are Perfect!'; 
		return null;
	}
	
	
	public PageReference doEvents(){
	
		Event[] Events = [Select ActivityDateTime, DB_Days__c from Event where DB_Days__c != null and isdeleted = false and ActivityDateTime != null ALL ROWS];
		
			for( Event e: Events)
			{
				DateTime dtoday = DateTime.newInstance(today.year(),today.month(),today.day(),e.ActivityDateTime.hour(),e.ActivityDateTime.minute(),e.ActivityDateTime.second());
				e.ActivityDateTime = dtoday.addDays(e.DB_Days__c.intValue()); 
			} 
		
		update events;
		Es='Events are Perfect!'; 
		return null;
	} 
	
	
	public PageReference doCases(){
	
		Case[] Cases = [Select DateTime_Opened_c__c, DateTime_Closed_c__c, DB_Hours__c, DB_Case_Duration_Hours__c from Case where DB_Hours__c != null or DB_Case_Duration_Hours__c != null];
		
			for( Case c: Cases)
			{
			 
			DateTime openDate = DateTime.now();
			
			
				if(c.DB_Hours__c != null){
				
					c.DateTime_Opened_c__c = openDate.addHours(c.DB_Hours__c.intValue()); 
				}
				if(c.DB_Case_Duration_Hours__c != null){
					c.DateTime_Closed_c__c = c.DateTime_Opened_c__c.addHours(c.DB_Case_Duration_Hours__c.intValue());
				}  
			} 
		
		update Cases;
		Cs='Cases are Perfect!'; 
		return null;
	}
	public PageReference doQuotes(){
	 
		Quote[] Quotes = [Select id,DB_Days__c from Quote where DB_Days__c != null];
			for( Quote q: Quotes)
			{
			q.ExpirationDate = today.addDays(q.DB_Days__c.intValue()); 
			}  
		 
		update Quotes;
		Qts='Quotes are Perfect!'; 
		return null; 
	}
	
	


}