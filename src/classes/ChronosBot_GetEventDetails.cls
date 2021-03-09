global with sharing class ChronosBot_GetEventDetails {
    
    @InvocableMethod(label='Chronos Bot - Get Event Details' description='Returns the StartDateTime and EndDateTime fields for the specified Event')
    public static List<ChatResponses> getTSlots(List<Event> events)
    {
        List<ChatResponses> chatResponses=new List<ChatResponses>();
        for(Event ev1:events)
        {
            ChatResponses ch1=new ChatResponses();
            ch1.startTime=ev1.StartDateTime;
            ch1.endTime=ev1.EndDateTime;
            chatResponses.add(ch1);
        }
        return chatResponses;
        
    }
     global class ChatResponses
    {
        @InvocableVariable
        public DateTime startTime;
        @InvocableVariable
        public DateTime endTime;
    }
}