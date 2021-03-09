public with sharing class VFC_AcctOptyClosedController {

    public Account a {get;set;}
    public Map<Integer,Map<Integer,Decimal>> oList {get;set;}
    public List<PlotPoint> testList {get;set;}
    public List<Integer> yearList {get;set;}
    public String legend {get;set;}

    public VFC_AcctOptyClosedController(ApexPages.StandardController controller) {
        a = [Select Id From Account Where Id =: controller.getID()];
        testList = new List<PlotPoint>();
        testList = convertMapToChartData(generateMonthMap(grabOpportunities(a)));
    }
    
    /* Gets List of Associated Opportunities in Closed Won Status over last 3 years */
    public List<Opportunity> grabOpportunities(Account a) {
        
        yearList = new List<Integer>();
        yearList.add( Date.Today().Year());     
        yearList.add( Date.Today().Year()-1);   
        yearList.add( Date.Today().Year()-2);   

        return [Select o.StageName, o.CloseDate, o.Amount From Opportunity o 
                Where o.StageName = 'Closed Won' and o.AccountID =: a.Id];  
    }
    
    /* Generates Year/Month/Amount Map */
    public Map<Integer,Map<Integer,Decimal>> generateMonthMap(List<Opportunity> oList) {
        Map<Integer,Map<Integer,Decimal>> m = new Map<Integer,Map<Integer,Decimal>>();
        /* Populating the map with empty data */
        for(Integer i = 1; i <= 12; i++) {
            m.put(i,new Map<Integer,Decimal>());
            for(Integer j = 0; j < yearList.size(); j++ ) {
                m.get(i).put(yearList[j],0);
            }
        }           
        
        Decimal totalAmount = 0;
        Integer month = 0;
        for( Opportunity o : oList ) {
            month = o.CloseDate.month();
            Map<Integer,Decimal> existingMonth = m.get(month);
            if(existingMonth.containsKey(o.CloseDate.year())) {
                Decimal amt = (Decimal)existingMonth.get(o.CloseDate.year());
                amt += o.Amount;
                existingMonth.put(o.CloseDate.year(),amt);
            } else {
                existingMonth.put(o.CloseDate.year(),o.Amount);
            }
        }
        return m;
    }
    
    public List<PlotPoint> convertMapToChartData( Map<Integer,Map<Integer,Decimal>> a) {
        List<PlotPoint> p = new List<PlotPoint>();
        for(Integer m : a.keySet()) {
            PlotPoint tmp = new PlotPoint();
            tmp.m = m;
            List<Integer> yrs = new List<Integer>();
            legend = '';
            for(Integer x : a.get(m).keySet()) {
                yrs.add(x);
                legend += x + ',';
            }
            legend = legend.substring(0,legend.length()-1);
            
            tmp.y1 = (Integer)yrs[0];
            tmp.y2 = (Integer)yrs[1];
            tmp.y3 = (Integer)yrs[2];
            tmp.a1 = a.get(m).get(yrs[0]);
            tmp.a2 = a.get(m).get(yrs[1]);
            tmp.a3 = a.get(m).get(yrs[2]);
            p.add(tmp);
        }
        return p;
    }
    
    public class PlotPoint {
        public Integer m  {get;set;}
        public Integer y1 {get;set;}
        public Integer y2 {get;set;}
        public Integer y3 {get;set;}
        public Decimal a1 {get;set;}
        public Decimal a2 {get;set;}
        public Decimal a3 {get;set;}
        
        public PlotPoint() {}
        
        public PlotPoint(Integer m, Integer y1, Integer a1, Integer y2, Integer a2, Integer y3, Integer a3) {
            this.m = m;
            this.y1 = y1;
            this.y2 = y2;
            this.y3 = y3;
            this.a1 = a1;
            this.a2 = a2;
            this.a3 = a3;
        }
    }
}