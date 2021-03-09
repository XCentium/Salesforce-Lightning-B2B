trigger CheckDefaultOrderStatusOnPricebook on Pricebook2 (before update,before insert) {
    if(System.isBatch()) return;
    List<Pricebook2> pbList = [select id,Default_Order_Pricebook__c from pricebook2];
    String pbID = null;
    for(Pricebook2 pb : trigger.new) {
        if(pb.Default_Order_Pricebook__c == true && trigger.oldMap.get(pb.id).Default_Order_Pricebook__c == false) {
            pbID = pb.id;
        }
    }
    List<Pricebook2> updateList = new List<Pricebook2>();
    if (pbID != null) {
       for(Pricebook2 pb2 : pbList) {
           if(pbId != pb2.id) {
               pb2.Default_Order_Pricebook__c = false;
               updateList.add(pb2);
           }
       }
       update updateList;
    }
   
}