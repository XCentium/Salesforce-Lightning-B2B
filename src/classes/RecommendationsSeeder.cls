public class RecommendationsSeeder {
    public void seed(){
        List<Recommendation> recommendations = new List<Recommendation>();
        Recommendation rec1 = new Recommendation(
            Name='Send technician onsite',
            Description='Send a technician onsite for this enterprise customer',
            ActionReference='Dispatch_Field_Technician',
            AcceptanceLabel = 'Send Technician',
            RejectionLabel = 'No Thanks',
            Category__c = 'Support_premium'
        );
        recommendations.add(rec1);
        
        Recommendation rec2 = new Recommendation(
            Name='Discuss Self Service',
            Description='This customer has not been active on our community portal. Explain the benefits of using the portal.',
            ActionReference='Dispatch_Field_Technician',
            AcceptanceLabel = 'Offer Self Service',
            RejectionLabel = 'No Thanks',
            Category__c = 'Support_standard'
        );
        recommendations.add(rec2);
        
       Recommendation rec3 = new Recommendation(
        Name='Thank customer for loyalty',
        Description='Thank you for being a loyal customer. We truly appreciate your business!',
        ActionReference='Dispatch_Field_Technician',
        AcceptanceLabel = 'Thank customer',
        RejectionLabel = 'Not Today',
        Category__c = 'Loyalty'
        );
        recommendations.add(rec3);
        
       Recommendation rec4 = new Recommendation(
        Name='Upgrade to an X120 Soft Serve',
        Description='Upgrade to a Twenty Gallon Single Nozzle Soft Serve Machine',
        ActionReference='Dispatch_Field_Technician',
        AcceptanceLabel = 'Upgrade to an X120 Soft Serve',
        RejectionLabel = 'No Thanks',
        Category__c = 'Upsell',
        Ranking__c = 2
        );
        recommendations.add(rec4);
        
       Recommendation rec5 = new Recommendation(
        Name='Add a Hot Waffle Press',
        Description='Add a new Stanley Waffle Cone Press',
        ActionReference='Dispatch_Field_Technician',
        AcceptanceLabel = 'Add Hot Waffle Press',
        RejectionLabel = 'No Thanks',
        Category__c = 'Upsell',
        Ranking__c = 1
        );
        recommendations.add(rec5);
        
        Recommendation rec6 = new Recommendation(
        Name='0% Refinancing!',
        Description='0% Refinancing on existing equipment',
        ActionReference='Dispatch_Field_Technician',
        AcceptanceLabel = 'Offer refinance',
        RejectionLabel = 'No Thanks',
        Category__c = 'Upsell',
        Ranking__c = 3
        );
        recommendations.add(rec6);
          
        insert recommendations;   
    }
}