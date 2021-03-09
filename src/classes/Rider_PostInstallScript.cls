global class Rider_PostInstallScript implements InstallHandler 
{
    global void onInstall(InstallContext context)
    {
        List<MessagingTemplate> objTemplates = new List<MessagingTemplate>();
        List<String> objDevNames = new List<String>{'Rider_Scheduled', 'Rider_Dispatched', 'Rider_Onsite', 'Rider_Completed', 'Rider_Canceled'};
        
        MessagingTemplate schTemplate = new MessagingTemplate();
        schTemplate.MasterLabel = 'Rider - Scheduled';
        schTemplate.DeveloperName = 'Rider_Scheduled';
        schTemplate.Language = 'en_US';
        schTemplate.Message = 'Hi {!ServiceAppointment.Rider_ContactFirstName__c}, your appointment "{!ServiceAppointment.Subject}" is scheduled for {!ServiceAppointment.Rider_StartTime__c}. We\'ll text you status updates, and you can always respond to make changes (ie reschedule, cancel, etc).';
        objTemplates.add(schTemplate);
        
        MessagingTemplate disTemplate = new MessagingTemplate();
        disTemplate.MasterLabel = 'Rider - Dispatched';
        disTemplate.DeveloperName = 'Rider_Dispatched';
        disTemplate.Language = 'en_US';
        disTemplate.Message = 'You\'re All Set! "{!ServiceAppointment.Subject}" is confirmed for {!ServiceAppointment.Rider_StartTime__c}. We\'ll let you know when your technician has arrived.';
        objTemplates.add(disTemplate);
        
        MessagingTemplate onsiteTemplate = new MessagingTemplate();
        onsiteTemplate.MasterLabel = 'Rider - Onsite';
        onsiteTemplate.DeveloperName = 'Rider_Onsite';
        onsiteTemplate.Language = 'en_US';
        onsiteTemplate.Message = '{!ServiceAppointment.Rider_ContactFirstName__c}, your technician has arrived for your Appointment "{!ServiceAppointment.Subject}".';
        objTemplates.add(onsiteTemplate);
        
        MessagingTemplate completeTemplate = new MessagingTemplate();
        completeTemplate.MasterLabel = 'Rider - Completed';
        completeTemplate.DeveloperName = 'Rider_Completed';
        completeTemplate.Language = 'en_US';
        completeTemplate.Message = 'Your Appointment "{!ServiceAppointment.Subject}" is complete. Thanks for choosing {!Organization.Name}!{!ServiceAppointment.Rider_ServiceReport_URL__c}';
        objTemplates.add(completeTemplate);
        
        MessagingTemplate cancelTemplate = new MessagingTemplate();
        cancelTemplate.MasterLabel = 'Rider - Canceled';
        cancelTemplate.DeveloperName = 'Rider_Canceled';
        cancelTemplate.Language = 'en_US';
        cancelTemplate.Message = '{!ServiceAppointment.Rider_ContactFirstName__c}, your Appointment "{!ServiceAppointment.Subject}" has been canceled.';
        objTemplates.add(cancelTemplate);
        
        MessagingTemplate statusTemplate = new MessagingTemplate();
        statusTemplate.MasterLabel = 'Rider - Status';
        statusTemplate.DeveloperName = 'Rider_Status';
        statusTemplate.Language = 'en_US';
        statusTemplate.Message = 'Appointment Info:{!ServiceAppointment.AppointmentNumber}Subject: {!ServiceAppointment.Subject}Status: {!ServiceAppointment.Status}StartTime: {!ServiceAppointment.Rider_StartTime__c}Location: {!ServiceAppointment.Street} {!ServiceAppointment.City}, {!ServiceAppointment.State} {!ServiceAppointment.PostalCode}';
        objTemplates.add(statusTemplate);
        
        List<MessagingTemplate> existingTemplates = new List<MessagingTemplate>([SELECT ID FROM MessagingTemplate WHERE DeveloperName IN : objDevNames]);
        if (existingTemplates.size() == 0)
        {
            //insert objTemplates;
        }
    }
}