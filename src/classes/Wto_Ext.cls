public class Wto_Ext {

      public List<String> rt_ids {get;set;}
      public List<RecordType> rts {get;set;}
      public String sObjectName {get;set;}
      private ApexPages.StandardController ctrl;
    
        public Wto_Ext(ApexPages.StandardController controller) {
         ctrl = controller;
           sObjectName = controller.getRecord().getSObjectType().getDescribe().getName();
        }
    
        public List<SelectOption> getRecordTypes() {
            List<SelectOption> options = new List<SelectOption>();
    
            rts = [SELECT Id, Name From RecordType WHERE SobjectType =: sObjectName ];
    
            for (RecordType r : rts) {
                options.add(new SelectOption(r.Id,r.Name));
            }
    
            return options;
        }
    
        public void save() {
            try {
          ctrl.save();
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Thank you for your submission');
                ApexPages.addMessage(myMsg);
            } catch(Exception e) {
              System.Debug('Error: ' + e.getMessage() + e.getCause().getMessage() + e.getTypeName());
            }
    
       }
}