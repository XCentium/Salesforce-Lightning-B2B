public class VFC_AccountController{
    public Account a {get;set;}
    public Decimal ClosedWon{get;set;}
    public Decimal ClosedLoss{get;set;}
    public Decimal ClosedWonValue{get;set;}
    public Decimal OpenOpptyValue{get;set;}
    
    public VFC_AccountController(ApexPages.StandardController controller) {
        a = [SELECT Id,Closed_Won_Opptys__c,Closed_Lost_Opptys__c, Open_Oppty_Value__c, Closed_Won_Value__c
            FROM Account WHERE Id =: controller.getId()];
        ClosedWon = a.Closed_Won_Opptys__c;
        ClosedLoss = a.Closed_Lost_Opptys__c;
        ClosedWonValue = a.Closed_Won_Value__c;
        OpenOpptyValue = a.Open_Oppty_Value__c;
    }
    /* Pie Chart */
    public List<PieWedgeData> getPieData(){
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Wins', ClosedWon));
        data.add(new PieWedgeData('Losses', ClosedLoss));
        return data;
    }
    public class PieWedgeData{
        public String name {get;set;}
        public Decimal data {get;set;}
        public PieWedgeData(String name, Decimal data){
            this.name = name;
            this.data = data;
        }
    }
    /* Bar Chart */
    public List<BarData> getBar(){
        List<BarData> bdata = new List<BarData>();
        bdata.add(new BarData('Closed Won', ClosedWonValue));
        bdata.add(new BarData('Open', OpenOpptyValue));
        return bdata;
    }
    public class BarData{
        public String bname{get;set;}
        public Decimal bdata{get;set;}
        public BarData(String bname, Decimal bdata){
            this.bname = bname;
            this.bdata = bdata;
        }
    }
}