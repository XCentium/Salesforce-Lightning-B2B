public class Q_QuickContactsController {
    public String cFirstName {get;set;}
    public String cLastName {get;set;}
    public String cEmail {get;set;}
    public String aName {get;set;}
    public String aNum {get;set;}
    
    public List<Contact> lContacts {get;set;}
    public List<Account> lAccounts {get;set;}
    public Contact c {get;set;}

    public Q_QuickContactsController(){
        lContacts = new List<Contact>();
        lAccounts = new List<Account>();
        c = new Contact();
        cFirstName = '';
        cLastName = '';
        cEmail = '';
        aName = '';
        aNum = '';
    }
    
    public void updateList(){
        contactList();
    }
        
    public void contactList(){
        String sQuery = 'SELECT Name, Email, Account.Name, Account.AccountNumber, MailingStreet, MailingCity, MailingState FROM Contact';
        String searchFName = 'FirstName LIKE \'%' + cFirstName +'%\'';
        String searchLName = 'LastName LIKE \'%' + cLastName +'%\'';
        String searchEmail = 'Email LIKE \'%' + cEmail +'%\'';
        String searchAName = 'Account.Name LIKE \'%' + aName +'%\'';
        String searchANum = 'Account.Number LIKE \'%' + aNum +'%\'';
        Boolean wrapperFlag = false;
        Integer flagCount = 0;
        if(cFirstName != '' || cLastName != '' || cEmail != '' || aName != '' || aNum != ''){
            wrapperFlag = true;
            sQuery += ' WHERE ';
            if(cFirstName != ''){
                flagCount++;
                sQuery += searchFName;
            }
            if(cLastName != '' && flagCount > 0){
                flagCount++;
                sQuery += ' and ' + searchLName;
            } else if(cLastName != '' && flagCount < 1){
                flagCount++;
                sQuery += searchLName;
            }
            if(cEmail != '' && flagCount > 0){
                flagCount++;
                sQuery += ' and ' + searchEmail;
            } else if(cEmail != '' && flagCount < 1){
                flagCount++;
                sQuery += searchEmail;
            }
            if(aName != '' && flagCount > 0){
                flagCount++;
                sQuery += ' and ' + searchAName;
            } else if(aName != '' && flagCount < 1){
                flagCount++;
                sQuery += searchAName;
            }
            if(aNum != '' && flagCount > 0){
                flagCount++;
                sQuery += ' and ' + searchANum;
            } else if(aNum != '' && flagCount < 1){
                flagCount++;
                sQuery += searchANum;
            }
        }
        
        // sQuery += ' Limit 10';
        lContacts = database.query(sQuery);
    }
    public void createContact(){
    }
}