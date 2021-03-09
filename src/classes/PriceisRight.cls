//////*************************************************************************************//////
//        Price is Right v1.2                                                                  //
//                                                                                             //
//     Created by Mark Crumpacker... After 32 cups of coffee, 3 energy drinks, and 1 donut     //
//                                                                                             //                                                                  
//   The Price is Right is a component that quickly adjusts the Opportunity Line Items so      //
//   that the product prices and quantities are reflective of the companies typical purchase   //
//   order                                                                                     //
//                                                                                             //
//    Thanks to Jon Hersh, Javi Mendezona, Greg Gsell,  Ralph Callaway, and                    //
//    Iman Maghroori for all the help                                                          //  
//                                                                                             //
//////*************************************************************************************//////




public class PriceisRight {
    public Product2[] products {get; set;}
    public OpportunityLineItem[] OLI { get; set; }
    public PricebookEntry[] pricebook {get; set;}
    String[] Price = new String[]{};
    String[] Quantity = new String[]{};
    public PIR[] priceright {get; set;}
    public Decimal randDisc {get; set;}
    public Decimal randQuantity {get; set;}
    public Decimal randListPrice {get; set;}
    public String done {get; set;}
    public Decimal GlobalAmount {get; set;}
    public Decimal GlobalAvg {get; set;}
    public Decimal GlobalNum {get; set;}
    
    
    public PriceisRight(){
        products = [select                       
                        Name,
                        Id 
                    from Product2
                    where Name != null];
        
        priceright = new PIR[]{};
        
        for (product2 p : products){
            priceright.add(new PIR(p,'',''));   
        }   
    }
    
    public List<SelectOption> getItems() { 
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Pennies','Pennies'));
        options.add(new SelectOption('Singles','Singles'));
        options.add(new SelectOption('Tens','Tens'));
        options.add(new SelectOption('Hundreds','Hundreds'));
        options.add(new SelectOption('Thousands','Thousands'));
        options.add(new SelectOption('TenThousands','10\'s of Thousands'));
        options.add(new SelectOption('HunThousands','100\'s of Thousands'));
        options.add(new SelectOption('Millions','Million+'));

        return options;
    }
        
    public List<SelectOption> getQuant() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Small','Small Quantity'));
        options.add(new SelectOption('Medium','Medium Quantity'));
        options.add(new SelectOption('Large','Large Quantity'));

        return options;
    }
      
    public String[] getPrice() {    return Price;       }
    public void setPrice(String[] Price) {      this.Price = Price;     }
    public String [] getQuantity(){     return Quantity;    }
    public void setQuantity(String[] Quantity) {    this.Quantity = Quantity;       }
  
  
  
    
     public PageReference ComeOnDown() {
        
        for (PIR p : priceright){
            
                String ProductName = p.prod.name; 
                
                OLI = [select  
                        UnitPrice, 
                        Quantity,
                        PricebookEntry.Product2.Name
                    from OpportunityLineItem
                    where PricebookEntry.Product2.Name = :ProductName and HasSchedule = false];
                    
                    
                    
                pricebook = [Select UnitPrice
                             From PricebookEntry
                             where Name = :ProductName and UseStandardPrice = false];
                         
            for(PricebookEntry pb : pricebook){
                if (p.price == 'Pennies'){
                    randListPrice = math.random()*0.89+.10;
                    randListPrice = randListPrice.setScale(2);
                    pb.UnitPrice = randListPrice;
                    
                }
                if (p.price == 'Singles'){
                    randListPrice = math.roundToLong(math.random()*8+1);
                    pb.UnitPrice = randListPrice;
                    
                }
                
                if (p.price == 'Tens'){
                    randListPrice = math.roundToLong(math.random()*89+10);
                    pb.UnitPrice = randListPrice;
                    
                }
                if (p.price == 'Hundreds'){
                    
                    randListPrice = math.roundToLong(math.random()*899+100);
                    pb.UnitPrice = randListPrice;
                }
                if (p.price == 'Thousands'){
                    
                    randListPrice = math.roundToLong(math.random()*8999+1000);
                    pb.UnitPrice = randListPrice;
                }
                if (p.price == 'TenThousands'){
                    
                    randListPrice = math.roundToLong(math.random()*89999+10000);
                    pb.UnitPrice = randListPrice;
                }
                if (p.price == 'HunThousands'){
                    
                    randListPrice = math.roundToLong(math.random()*899999+100000);
                    pb.UnitPrice = randListPrice;
                }
                if (p.price == 'Millions'){
                    
                    randListPrice = math.roundToLong(math.random()*8999999+1000000);
                    pb.UnitPrice = randListPrice;
                }
            }  
            for (OpportunityLineItem o : OLI){


                if(p.Quantity == 'small'){
                    randDisc = math.random()*50+100;
                    randDisc = randDisc/100;
                    randQuantity = math.roundToLong(math.random()*9+1);
                    o.Quantity = randQuantity;
                    Double UnitPrice = randListPrice/randDisc;
                    o.UnitPrice = UnitPrice;
                }

                if(p.Quantity == 'medium'){
                    randDisc = math.random()*50+100;
                    randDisc = randDisc/100;
                    randQuantity=math.roundToLong(math.random()*75+80);
                    o.Quantity = randQuantity;
                    Double UnitPrice = randListPrice/randDisc;
                    o.UnitPrice = UnitPrice;
                }
                if(p.Quantity == 'large'){
                    randDisc = math.random()*50+100;
                    randDisc = randDisc/100;
                    randQuantity= math.roundToLong(math.random()*200+200);
                    o.Quantity = randQuantity;
                    Double UnitPrice = randListPrice/randDisc;
                    o.UnitPrice = UnitPrice;
                }
            }//end OLI loop 
        update pricebook;
        update OLI;
        

        
        }//end priceright loop
        updateOpptyNames();
        updateNoOLI();
        return null;
     
    } 
    
     public PageReference updateOpptyNames(){
        Opportunity[] opty = [select Id, Amount, Name, Account.Name from Opportunity where HasOpportunityLineItem = true ];
        
        
        OpportunityLineItem[] OL  = [select OpportunityId, TotalPrice from OpportunityLineItem ]; 
        
        GlobalNum = 0;
        GlobalAmount = 0;
        
        for(Opportunity o : opty){
        
            Double OpptyAmount = 0;
                for (OpportunityLineItem OpL : OL){
                    
                    if(o.ID == Opl.OpportunityId)
                        { 
                            OpptyAmount += OpL.TotalPrice;
                        }
                }
             
            o.Amount = OpptyAmount;
            
            Decimal DecOppty = o.Amount;
            String astName = o.Name;
            Boolean NameHasAst = astName.endsWith('*');
            
            
            
            String OpptyName = o.Account.Name+' - ' ;
            
                if (o.amount > 1000000){
                   DecOppty = DecOppty.setScale(1);
                    DecOppty = DecOppty/1000000;
                    OpptyName += DecOppty+''+'M';
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
                    
                }else if (o.amount > 1000){
                     DecOppty = DecOppty.setScale(1);
                    DecOppty = DecOppty/1000;
                    OpptyName += DecOppty+''+'K';
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
                    
                }else {
                    OpptyName = OpptyName + DecOppty.setScale(0);
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                }
            
            o.Name = OpptyName;
            
            
            GlobalAmount = GlobalAmount + o.Amount;
            GlobalNum++;
            
        }
            update opty; 
             done = 'Opportunity Line Items, and Opportunities Updated';
        
            return null;
            
    }
    
public PageReference updateNoOLI(){
Opportunity[] NoOLI = [select Id, Amount, Name, Account.Name from Opportunity where HasOpportunityLineItem = false ];   
    
GlobalAvg = GlobalAmount/GlobalNum;


for(Opportunity o : NoOLI){
    
    Decimal NoOLIAmount = math.random()*50 +75;
    NoOLIAmount = NoOLIAmount/100;
    NoOLIAmount = NoOLIAmount.SetScale(2);
    
    o.Amount = GlobalAvg * NoOLIAmount;
    Decimal DecOppty = o.Amount;
    String astName = o.Name;
    Boolean NameHasAst = astName.endsWith('*');
            
            
            
            String OpptyName = o.Account.Name+' - ' ;
            
                if (o.amount > 1000000){
                   DecOppty = DecOppty.SetScale(1);
                   DecOppty = DecOppty/1000000;
                   OpptyName += DecOppty+''+'M';
                    
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
                    
                }else if (o.amount > 1000){
                     DecOppty = DecOppty.setScale(1);
                    DecOppty = DecOppty/1000;
                    OpptyName += DecOppty+''+'K';
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
                    
                }else {
                    OpptyName = OpptyName + DecOppty.setScale(0);
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                }
            
            o.Name = OpptyName;
             
            
        }
    update NoOLI;
    done = 'Opportunity Line Items, and Opportunities Updated';
    
return null;    
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public class PIR{
        
        public product2 prod{get; set;}
        public String price {get; set;}
        public String Quantity {get; set;}
        
        
        public PIR(product2 p, String pr, String Q){
            prod = p;
            price = pr;
            Quantity = Q;
            
                
        }
        
    }
    
    
    
    
   
    
    
    
    
    
}