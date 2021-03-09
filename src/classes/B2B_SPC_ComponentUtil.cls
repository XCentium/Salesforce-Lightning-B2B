public with sharing class B2B_SPC_ComponentUtil {
    
    public static void addMessage(Message msg, Integer pos, Map<String, Object> responseMap) {

        List<Message> retMessages = null;

        if(responseMap.containsKey('messages')) {
            retMessages = (List<Message>)responseMap.get('messages');
        }
        else {
            retMessages = new List<Message>();
        }

        if(pos == null) {
            retMessages.add(msg);
        }
        else if(retMessages.size() <= 0) {
            retMessages.add(msg);
        }
        else {
            retMessages.add(pos, msg);
        }

        responseMap.put('messages', retMessages);

    }    

    public static final String ERROR = 'error';
    public static final String INFO = 'info';
    public static final String SUCCESS = 'success';
    public static final String WARN = 'warn';

    public class Message {

        public String severity {get; set;}
        public String title {get; set;}
        public String message {get; set;}
        public Boolean toast {get; set;}

        public Message() {
            toast = true;
        }

        public Message(String title, String message, String severity) {
            this();
            this.title = title;
            this.message = message;
            this.severity = severity;
        }

        public Message(String title, String message, String severity, Boolean toast) {
            this();
            this.title = title;
            this.message = message;
            this.severity = severity;
            this.toast = toast;
        }

    }
    
}