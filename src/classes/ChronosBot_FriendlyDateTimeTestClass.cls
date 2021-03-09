@isTest
private with sharing class ChronosBot_FriendlyDateTimeTestClass 
{
    static testMethod void validateSATime() 
    {
        List<ServiceAppointment> sList = new List<ServiceAppointment>();
        List<List<ServiceAppointment>> sll = new List<List<ServiceAppointment>>();
        DateTime d1=System.now();
        ServiceAppointment sa = new ServiceAppointment();
        sa.SchedStartTime=d1;
        sa.SchedEndTime=d1+1;
        sa.ContactId = '0033i000002BXPcAAO';
        sList.add(sa);
        sll.add(sList);
        List<List<ServiceAppointment>> friendlySAs = ChronosBot_FriendlyDateTime.makeFriendlyDateTime(sll);
        System.assertEquals(d1,friendlySAs[0][0].SchedStartTime);       
    }
}