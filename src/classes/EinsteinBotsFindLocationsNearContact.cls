global class EinsteinBotsFindLocationsNearContact 
{
	@InvocableMethod(label='Einstein Bots - Find Locations Near Contact' description='Returns a list of 3 Locations nearest the specified Contact')
    global static List<List<Schema.Location>> findLocationsNearContact(List<Contact> thisContact)
    {        
        List<Schema.Location> locationsNearContact = new List<Schema.Location>();
        
        For (Contact currentContact : thisContact)
        {
            if (currentContact != null && String.IsNotBlank(currentContact.id))
            {
                //SOQL Query that pulls back Location objects, and shows the 3 that are closest to the Contact
                //Logic done by comparing geolocation of the Location Address and of Contacts Mailing Address
                List<Schema.Location> foundLocations = [SELECT Id, Name, Location, Latitude, Longitude, Opening_Time__c, Closing_Time__c, TimeZone, Phone__c, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country  
                                           FROM Location 
                                           WHERE DISTANCE(Location, GEOLOCATION(:currentContact.MailingLatitude, :currentContact.MailingLongitude), 'mi') < 50
                                           ORDER BY DISTANCE(Location, GEOLOCATION(:currentContact.MailingLatitude, :currentContact.MailingLongitude), 'mi') ASC
                                           LIMIT 3];

                if (foundLocations != null && foundLocations.size() > 0)
                {
                    return new List<List<Schema.Location>>{foundLocations}; 
                } 
                break;
            }
        }
        
        return new List<List<Schema.Location>>{new List<Schema.Location>{new Schema.Location()}};
    }
}