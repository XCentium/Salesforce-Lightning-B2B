public class VFC_AcctProductFamily{
    public string AcctId {get;set;}
    public List<String> ProductFam {get;set;}
    Public Map<String,Decimal> famCountMap {get;set;}
    Public Map<String,Decimal> oliTotPrice{get;set;}
    Public Map<String,Decimal> prod2Map{get;set;}
    
    public VFC_AcctProductFamily(ApexPages.StandardController controller) {
        AcctId = controller.getId();
        init();
    }
    public void init(){
        famCountMap = new Map<String,Decimal>();
        oliTotPrice = new Map<String,Decimal>();
        prod2Map = new Map<String,Decimal>();
        List<String> oppIds = new List<String>();
        List<String> peIds = new List<String>();
        List<String> prod2Ids = new List<String>();
        List<Product2> prod2 = new List<Product2>();
        List<Opportunity> theOpps = [select Id from Opportunity where AccountId =: AcctId and StageName = 'Closed Won'];
        for(Opportunity o : theOpps){
            oppIds.add(o.Id);
        }
        List<OpportunityLineItem> theOLI = [select PricebookEntryId, TotalPrice from OpportunityLineItem where OpportunityId in: oppIds];
        for(OpportunityLineItem oli : theOLI){
            peIds.add(oli.PricebookEntryId);
            if(oliTotPrice.keySet().contains(oli.PriceBookEntryId)){
                decimal tPrice = oliTotPrice.get(oli.PriceBookEntryId);
                tPrice = tPrice + oli.TotalPrice;
                oliTotPrice.put(oli.PricebookEntryId, tPrice);                
            }else{
                oliTotPrice.put(oli.PricebookEntryId, oli.TotalPrice);
            }
        }
        List<PricebookEntry> peLI = [select Product2Id,Id from PricebookEntry where Id in: peIds];
        for(PricebookEntry pe : peLI){
            prod2Map.put(pe.Product2Id, oliTotPrice.get(pe.Id));
        }
        prod2 = [select Family, Id from Product2 where Id in: prod2Map.keySet()];
        for(Product2 p : prod2){
            if(famCountMap.keySet().contains(p.Family)){
                Decimal fPrice = famCountMap.get(p.Family);
                fPrice += prod2Map.get(p.Id);
                famCountMap.put(p.Family, fPrice);
            }else{
                famCountMap.put(p.Family, prod2Map.get(p.Id));
            }
        }
        //system.assert(false, famCountMap);
    }
    public List<PieWedgeData> getPieData(){
        List<PieWedgeData> data = new List<PieWedgeData>();
        
        for(String s : famCountMap.keySet()){
            data.add(new PieWedgeData(s, famCountMap.get(s)));
        }
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
}