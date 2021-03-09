public class VFDashboardController2 {
   public String displayObject {get; set;}
   
   public VFDashboardController2() {
       displayObject = 'Accounts';
   }
   
   public String getStateInfo() {
       String returnString = '';
       if (displayObject == 'Accounts') {
         List<Account>aList = [select id, BillingState from Account where BillingState != ''];
         Map<String, Integer>theMap = new Map<String, Integer>();
         
         for (Account acct : aList) {
           if (!theMap.containsKey(acct.BillingState)) {
             Integer temp = [select count() from Account where BillingState = :acct.BillingState];
             theMap.put(acct.BillingState, temp);
           }
         }
         Set<String>aSet = new Set<String>();
         for (Account a : aList) {
           aSet.add(a.BillingState);
         }
         
         for(String acct : aSet) {
           returnString = returnString + acct;
         }
         returnString += '&chd=t:';
         for (String acct : aSet) {
           returnString += theMap.get(acct) + ',';
         }
         returnString = returnString.substring(0, returnString.length()-1);
        // System.assert(false, 'this is the return string: ' + returnString);
       }
       if (displayObject == 'Contacts') {
           List<Contact>cList = [select id, MailingState from Contact where MailingState != ''];
          Map<String, Integer>theMap = new Map<String, Integer>();
          
          for (Contact con : cList) {
            if (!theMap.containsKey(con.MailingState)) {
                Integer temp = [select count() from Contact where MailingState = :con.MailingState];
                theMap.put(con.MailingState, temp);
            }
          }
          Set<String>aSet = new Set<String>();
          for (Contact c : cList) {
            aSet.add(c.MailingState);
          }
          
          for(String con : aSet) {
            returnString = returnString + con;
          }
          returnString += '&chd=t:';
          for (String con : aSet) {
            returnString += theMap.get(con) + ',';
          }
          returnString = returnString.substring(0, returnString.length()-1);
       }
       if (displayObject == 'Leads') {
          List<Lead>cList = [select id, State from Lead where State != ''];
          Map<String, Integer>theMap = new Map<String, Integer>();
          
          for (Lead con : cList) {
            if (!theMap.containsKey(con.State)) {
                Integer temp = [select count() from Lead where State = :con.State];
                theMap.put(con.State, temp);
            }
          }
          Set<String>aSet = new Set<String>();
          for (Lead c : cList) {
            aSet.add(c.State);
          }
          
          for(String con : aSet) {
            returnString = returnString + con;
          }
          returnString += '&chd=t:';
          for (String con : aSet) {
            returnString += theMap.get(con) + ',';
          }
          returnString = returnString.substring(0, returnString.length()-1);
      }
       return returnString;
   }
   public PageReference refreshMap() {
       return null;
   }
   public List<SelectOption>getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Accounts','Accounts'));
        options.add(new SelectOption('Contacts','Contacts'));
        options.add(new SelectOption('Leads','Leads'));
        return options;
   }
   public String getColors() {
       if (displayObject == 'Accounts') {
            return 'FFFFFF,9AD2FF,2A31FF';
       } else if (displayObject == 'Contacts') {
            return 'FFFFFF,B8B1CE,6C5D9B';
       } else {
            return 'FFFFFF,F7E3C6,E39423';
       }
     
   }
}