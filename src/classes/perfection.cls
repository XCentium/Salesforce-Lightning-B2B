public class perfection {

Date today = Date.today(); 
String Ts,Os,Ass,COs,Cps,Es,Cs,Qts, Is, Qs, PMs, CMs;


public String getTs(){return Ts;}
public String getOs(){return Os;}
public String getAss(){return Ass;}
public String getCOs(){return COs;}
public String getEs(){return Es;}
public String getCps() { return Cps;} 
public String getCs() { return Cs;} 
public String getQts() { return Qts;} 
public String getIs() { return Is;} 
//public String getOds() { return Ods;} 
public String getQs() { return Qs;} 
public String getPMs() { return PMs;} 
public String getCMs() { return CMs;} 


    public PageReference all() {
        doQueueStat();  
        doTasks();
        doAssets();
        //doContracts();
        doCampaigns();
        doEvents();
        doCases();
        doQuotes();
        doContractandOrders();
        doInvoices();
        doOpps();
        doQueueStats();
        doMilestonesPM();
        doCaseMilestones();
        
    
    return null;
    }
    
    /*Added by CHRIS HUANG to fix opp swarm, 9-25-13*/
    /*public Boolean howdy {get;set;}
    public ApexTrigger mytriggers {get;set;}
    
    public perfection(){
        mytriggers=new ApexTrigger();
        
        for(ApexTrigger a :[SELECT Id,Name,Status FROM ApexTrigger where Status='Active' And Name='opptySwarm' limit 1]){
            mytriggers = a;
        }
        if(mytriggers.id != null){
            howdy=true;
        }
        else{
            howdy=false;
        }
    }*/
    /*End Added by CHRIS HUANG to fix opp swarm, 9-25-13*/
    
    
    public PageReference doCaseMilestones(){
        
        CaseMilestone[] CaseMilestones = [Select TargetDate,  StartDate, CompletionDate, CaseId, Case.Status From CaseMilestone where isCompleted = false order by CaseId];         
        
        for ( CaseMilestone cm : CaseMilestones){
            if(cm.Case.Status == 'Closed'){
                continue;
            }else{
            cm.StartDate = System.now();
            }
            
        }
        
        update CaseMilestones;
        
        CMs= 'Case Milestones are Perfect!';
        
        return null;
    }
    public PageReference doQueueStat(){ 
        
        Queue_Stat__c[] stats = [Select  dbdays__c, Date__c From Queue_Stat__c q where dbdays__c != null ];
        
        for( Queue_Stat__c t: stats)
        {
            t.Date__c = today.addDays(t.dbdays__c.intValue()); 
        } 
        
        update stats;
        Qs= 'Queue Stats are Perfect!';
        return null;
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
    
        /*
        Opportunity[] Opps = [Select CloseDate, DB_Days__c from Opportunity where DB_Days__c != null and CloseDate != null];
        
        for( Opportunity o: Opps)
        {
            o.CloseDate = today.addDays(o.DB_Days__c.intValue()); 
        } 
        
        update Opps;
        */
        SchedulePerfectDateWiz wizOppty = new SchedulePerfectDateWiz();
        String schDateTime = calculateScheduleTimeStr(); //string format for system scheduler, to NOW
        system.schedule('Scheduled PerfectDateWiz for Oppty now!'+System.now().format(), schDateTime, wizOppty); //SCHEDULE THE Date Wizard!!!!

        Os='Apex Batch Job In Process'; 
        return null;
    }
    private String calculateScheduleTimeStr()
    {
        DateTime schDateTime = System.now().addSeconds(3); //add 3 seconds to make sure it runs in the future
        String scheduleStr = '';
        scheduleStr = schDateTime.format('s m H d M')+ ' ? '+schDateTime.format('yyyy');
        return scheduleStr;
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
    
/*   
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
*/   
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
    
    public PageReference doContractandOrders(){
        
        Contract[] Contracts = [Select StartDate, DB_Days__c from contract where DB_Days__c != null and StartDate != null];
        
            for( Contract c: Contracts)
            {
                c.startdate = today.addDays(c.DB_Days__c.intValue()); 
            } 
        
        update Contracts;
        
        
        Order[] Orders = [Select EffectiveDate,DB_Days__c from Order where DB_Days__c != null];
            for( Order o: Orders)
            {
                o.EffectiveDate = today.addDays(o.DB_Days__c.intValue()); 
            } 
             
        update Orders;
        COs='Contracts and Orders are Perfect!'; 
        return null;
    }
    
    public PageReference doQueueStats(){
        Queue_Stat__c[] Stats = [SELECT Abandoned_Calls__c,Abandon_Rate__c,Avg_Queue_Time__c,Calls_Per_Agent__c,Calls_Queued__c,Date__c,dbdays__c,Handle_Time__c,Id,Inbound_Calls__c,Longest_Queue_Time__c,Name,Outbound_Calls__c,Queue_Name__c,Speed_to_Answer__c,Utilization__c FROM Queue_Stat__c where dbdays__c != null];
            for(Queue_Stat__c s:Stats){
                s.Date__c = today.addDays(s.dbdays__c.intValue());
            }
            update Stats;
            Qs='Telephony Stats are Perfect!';
            return null;
            
    }
    
    public PageReference doInvoices(){
    
        Invoice_Example__c[] Invoices = [Select Invoice_Date__c, Invoice_Due_Date__c,DB_Days__c from Invoice_Example__c where DB_Days__c != null];
            for( Invoice_Example__c i: Invoices)
            {
                i.Invoice_Date__c = today.addDays(i.DB_Days__c.intValue()); 
                i.Invoice_Due_Date__c = i.Invoice_Date__c.addDays(30); 
            } 
         
        update Invoices;
        Is='Invoices are Perfect!'; 
        return null;
    }
    public PageReference doMilestonesPM(){
        
        
        
        Milestone1_Project__c[] projects = [Select Kickoff__c, Deadline__c, DB_Days__c, DB_Days_Start__c,id From Milestone1_Project__c where DB_Days__c !=null and DB_Days_Start__c != null];
        
        for( Milestone1_Project__c p: projects)
        {
            p.Kickoff__c = today.addDays(p.DB_Days_Start__c.intValue());
            p.Deadline__c = p.kickoff__c.addDays(p.DB_Days__c.intValue()); 
            
            
            
        } 
        
        Milestone1_Milestone__c[] Milestones = [Select Kickoff__c, Deadline__c, DB_Days__c,DB_Days_Start__c, id From Milestone1_Milestone__c where DB_Days__c !=null and DB_Days_Start__c != null];
        
        for( Milestone1_Milestone__c m: Milestones)
        {
            m.Kickoff__c = today.addDays(m.DB_Days_Start__c.intValue());            
            m.Deadline__c = m.kickoff__c.addDays(m.DB_Days__c.intValue()); 
        }  
        
        Milestone1_Task__c[] tasks = [Select Start_Date__c, Due_Date__c, DB_Days__c,DB_Days_Start__c, id From Milestone1_Task__c where DB_Days__c !=null and DB_Days_Start__c != null];
        
        for( Milestone1_Task__c t: tasks)
        {
            t.Start_Date__c = today.addDays(t.DB_Days_Start__c.intValue());         
            t.Due_Date__c = t.Start_Date__c.addDays(t.DB_Days__c.intValue()); 
        }  
        
        Milestone1_Expense__c[] expenses = [Select Date_Incurred__c, DB_Days__c, id From Milestone1_Expense__c where DB_Days__c !=null];
        
        for( Milestone1_Expense__c e: expenses)
        {
            e.Date_Incurred__c = today.addDays(e.DB_Days__c.intValue());            
        }  
        
        Milestone1_Time__c[] Ptime = [Select Date__c, DB_Days__c, id From Milestone1_Time__c where DB_Days__c !=null];
        
        for( Milestone1_Time__c t: Ptime)
        {
            t.Date__c = today.addDays(t.DB_Days__c.intValue());         
        }  
        update projects;
        update Milestones;
        update tasks;
        update expenses;
        update Ptime;
        
        PMs= 'Milestone PM is Perfect!';
        return null;
    } 


}