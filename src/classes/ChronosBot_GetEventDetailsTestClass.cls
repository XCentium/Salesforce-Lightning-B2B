@isTest
private with sharing class ChronosBot_GetEventDetailsTestClass 
{
    static testMethod void validateEventTime() 
    {
        List<Event> e1=new List<Event>();
        DateTime d1=System.now();
        Event ev=new Event();
        ev.StartDateTime=d1;
        ev.EndDateTime=d1+1;
        e1.add(ev);
        List<ChronosBot_GetEventDetails.ChatResponses> chatResponses = ChronosBot_GetEventDetails.getTSlots(e1);
        System.assertEquals(d1,chatResponses[0].startTime);
    }
}