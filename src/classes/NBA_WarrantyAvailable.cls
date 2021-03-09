global class NBA_WarrantyAvailable {
    global NBA_WarrantyAvailable() {
    
        }
        @InvocableMethod(label='Contact Warranty Products' description='Find Contact Orders that have products available for warranty')
        global static List<Integer> calculate(List<WarrantyCalculate> contactToCalculate) {
            
            List<Integer> results = new List<Integer>();
            integer count = 0;
            
            For (WarrantyCalculate warranty : contactToCalculate)
            {
                String contid = warranty.ContactId;
                count = database.countQuery('SELECT Count() FROM Order WHERE BillToContactId = ' + contid);
				results.add(count);
            }
            return results;
    		
        }
    global class WarrantyCalculate {
        @InvocableVariable(label='Contact Record Id' required=true)
        global String ContactId;
    }
}