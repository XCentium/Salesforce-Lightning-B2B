global class EinsteinChatbotsGetBotMessage {
    @InvocableMethod(label='Einstein Chatbots - Get random Bot Message by Type')
    global static List<Bot_Message__c> getBotMessage(List<String> inputs)
    {
        for (String input : inputs){
            System.debug('XXXXX Input is ' + input);
            if (input!=null){
                List<Bot_Message__c> result = new List<Bot_Message__c>();
                List<Bot_Message__c> messageList = [SELECT Id, Message_1__c, Message_2__c, Name from Bot_Message__c where Type__c = :input];
                Integer rand = math.round(math.random()*1000);	
                Integer position = math.mod(rand, messageList.size());
                Bot_Message__c botMessage = messageList[position];
                result.add(botMessage);            
                return result; 
            }
        }
        return new List<Bot_Message__c>{new Bot_Message__c()};
    }
}