trigger update_contact on User bulk (after update) {   
    if(!System.isBatch()) return;
    User cuser = [Select Id, IsPortalEnabled, Name From User Where Id =: UserInfo.getUserID()];
    if(cuser != null && cuser.IsPortalEnabled) {           
        for (User u : Trigger.new) {
            if(u.IsActive && String.IsBlank(u.ContactID)) {
                // There is no Contact ID associated with this User, do nothing!
            } else if(u.IsActive && !String.IsBlank(u.ContactID)) {
                String contactID = u.ContactID;
                if(u.Contact.IsPersonAccount == true) {
                    try {
                        // This is a Person Account
                        Account pa = [Select Id, PersonEmail, FirstName, LastName, PersonTitle, Phone, Fax, PersonMobilePhone, 
                                      PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry
                                      From Account where Id =: u.Contact.AccountId Limit 1];
                        pa.PersonEmail = u.Email; 
                        pa.FirstName = u.FirstName; 
                        pa.LastName = u.LastName; 
                        pa.PersonTitle = u.Title; 
                        pa.Phone = u.Phone; 
                        pa.Fax = u.Fax; 
                        pa.PersonMobilePhone = u.MobilePhone; 
                        pa.PersonMailingStreet = u.Street; 
                        pa.PersonMailingCity = u.City; 
                        pa.PersonMailingState = u.State; 
                        pa.PersonMailingPostalCode = u.PostalCode; 
                        pa.PersonMailingCountry = u.Country; 
                        update pa; 
                    } catch(Exception e) {
                        System.debug(e);
                    }
                } else {
                    try {
                        // Regular Contact Record
                        Contact c = [Select Id, Email, FirstName, LastName, Title, Phone, Fax, MobilePhone,
                                     MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                                     From Contact Where Id =: u.ContactID Limit 1];
                        c.Email = u.Email; 
                        c.FirstName = u.FirstName; 
                        c.LastName = u.LastName; 
                        c.Title = u.Title; 
                        c.Phone = u.Phone; 
                        c.Fax = u.Fax; 
                        c.MobilePhone = u.MobilePhone; 
                        c.MailingStreet = u.Street; 
                        c.MailingCity = u.City; 
                        c.MailingState = u.State; 
                        c.MailingPostalCode = u.PostalCode; 
                        c.MailingCountry = u.Country; 
                        update c;
                    } catch(Exception e) {
                        System.debug(e);
                    }
                }
            }
        }
    }           
}