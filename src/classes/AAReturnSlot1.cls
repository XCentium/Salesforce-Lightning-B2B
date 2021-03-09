public class AAReturnSlot1 {

    @invocableMethod(label='Deserialize Selected Slot')
    public static list<JSONSlotOut> AAJSONInOut1(list<JSONSlotIn> SlotIn) {
        JSONSlotIn JSI = SlotIn[0]; 
        JSONSlotOut JSO = new JSONSlotOut();
        list<JSONSlotOutTemp> listIn = (list<JsonSlotOutTemp>) JSON.deserialize(JSI.JSONIn,List<JSONSlotOutTemp>.class);
        for(object theMap1 : listIn){
            JSONSlotOutTemp theMapIn = (JSONSlotOutTemp) theMap1;
            if(JSI.SlotId == theMapIn.Id) {
                JSO.Id = theMapIn.Id;
                JSO.territoryId = theMapIn.territoryId;
                JSO.territoryName = theMapIn.territoryName;
                JSO.resources = theMapIn.resources;
                JSO.resourceName = theMapIn.resourceName;
                JSO.startTime = datetime.newinstance(theMapIn.startTime);
                JSO.endTime = datetime.newinstance(theMapIn.endTime);
            }
        }
        return new list<JSONSlotOut>{JSO};
    }
    
    public Class JSONSlotOut
    {
        @InvocableVariable
        public String Id;
        @InvocableVariable
        public String territoryId;
        @InvocableVariable
        public String territoryName;
        @InvocableVariable
        public datetime startTime;
        @InvocableVariable
        public datetime endTime;
        @InvocableVariable
        public String resources;
        @InvocableVariable
        public String resourceName;
        
    }
    
    public Class JSONSlotOutTemp
    {
        @InvocableVariable
        public String Id;
        @InvocableVariable
        public String territoryId;
        @InvocableVariable
        public String territoryName;
        @InvocableVariable
        public long startTime;
        @InvocableVariable
        public long endTime;
        @InvocableVariable
        public String resources;
        @InvocableVariable
        public String resourceName;
        
    }
    
    public Class JSONSlotIn
    {
        @InvocableVariable
        public String JSONIn;
        @InvocableVariable
        public String SlotId;
    }


}