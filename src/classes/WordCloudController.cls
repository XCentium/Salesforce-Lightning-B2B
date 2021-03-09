public class WordCloudController {

     @AuraEnabled
    @Readonly
    @RemoteAction
   public static Map<String, Integer>  getWordCloudData(String objectName, String fieldName){
       Integer maxSize =12000;
      
       List<SObject > dataList =  Database.query('SELECT ' + fieldName + ' FROM ' + objectName + ' limit ' + maxSize);
       Map<String, Integer> wordCounts = new  Map<String, Integer>();
       
        for (Integer i = 0; i < dataList.size() && i < maxSize; i++) {
            SObject  obj = dataList.get(i);
             String text = (String)obj.get(fieldName);
            
			List<String> wordList = getWords( text);   
           
                for(String word: wordList) {       
                    Integer itemCount = wordCounts.get(word);
                    if(itemCount == null) {
                        itemCount = 1;
                        
                    } else {
                       itemCount++; 
                    }
                    wordCounts.put(word, itemCount);
                }    
        }
       
      
       return wordCounts;
   }
    
 
    
    private static List<String> getWords(String text) {
        
           List<String> wordList = new  List<String>();
        
         if(text == null || text.length() == 0) {
        	return wordList;
         }
         text = cleanText(text);
        text = text.toLowerCase();
        Integer wordIndex = text.indexOf(' ');
        Integer loopCount = 0;
 
        while(wordIndex != -1 && loopCount < 200) {
            
            String word = text.left(wordIndex);
         
            text = text.right(text.length() - (wordIndex + 1));
            wordIndex = text.indexOf(' ');
            loopCount++;
            
            if(!excludeWord(word)) {
            	wordList.add(word);
            }
        }
       wordList.add(text);
        
       // System.debug(loopCount);
      
        return wordList;
    }
   
     private static String cleanText(String text) {
         text = text.replaceAll('[!@#$%^&*(),.?":{}|<>1234567890_/-]', '');
         
         return text;
     }
    
     private static boolean excludeWord(String text) {
         List<String> wordList = new list<String> { 'i' , 'to' , 'a', 'be' , 'the', 'to' , 'but', 'like' , 'and', 'with' , 
             'what', 'how' , 'from', 'do' , 'my', 'your' , 'is', 'on' , 'can', 'not' , 'where', 'need', 'can\'t' , 'was', 'no' , 
             'get', 'for' , 'of', 'in' , 'this' , 'are', 'an', 'has' , 'in' , 'by',  'you', 'it',  'me',  'i\'m',   'i\'ve', 
             'will', 'just', 'at', 'this', 'that', 'so', 'very' , 'some', 'or', 'really' , 'it\'s', 'had',  'wasn\'t', 'as' , 
             'been', 'his', 'her', 'our', 'did', 'there', 'i\'d', 'we', 'they', 'which', 'have', 'if', 'he', 'too', 'because', 
             'could', 'say', 'all', 'them', 'us', 'would', 'one', 'when', 'up', 'were', 'also', 'about', 'got', 'any', 'through',
             'their', 'put', 'way', 'able', 'than', 'set', 'lot', 'then', 'add', 'being', 'etc', 'always', 'yet', 'other', 'out',
             'am', 'bit', 'ie', 'off', 're', 'use', 'does', 'up', 'most'};
		return wordList.contains(text);
         
     }

  @AuraEnabled
    public static String goClassify( String sourceName, String destinationName, String objectName, Integer batchSize, String modelId,  String overwriteValues, String latestId) {
         

        System.debug('---- Started Classification ----');
         Boolean overwrite = Boolean.valueOf(overwriteValues);
        System.debug(modelId + ' '  + latestId + ' ' + batchSize  + ' ' + overwrite);
      //  System.debug( overwriteValues);
  
       Integer maxSize = Integer.valueOf(batchSize);
      
       
        List<SObject > dataList = null;
        if(latestId == null ) {
             System.debug('- Started From Scratch --');
           dataList =  Database.query('SELECT id, ' + sourceName + ',' + destinationName +  ' FROM ' + objectName + ' order by id limit ' + maxSize);
        } else {
            dataList =  Database.query('SELECT id, ' + sourceName + ',' + destinationName +  ' FROM ' + objectName + ' where id > \'' + latestId + '\' order by id limit ' + maxSize);
        }
        
         System.debug('Got dataset of size ' + dataList.size());
       List<SObject > shortList  = new List<SObject >();   
        
        einsteinplay.Einstein_PredictionService service;
        service = new einsteinplay.Einstein_PredictionService(einsteinplay.Einstein_PredictionService.Types.Intent);
        
              for (Integer i = 0; i < dataList.size() && i < maxSize; i++) {
                  
                  SObject  obj = dataList.get(i);
                  latestId = (string) obj.get('id');
                  String text = (String)obj.get(sourceName);
                   String existingValue = (String)obj.get(destinationName);
              
                   if((overwrite || existingValue == null || existingValue.length() ==0) && (text != null && text.length() >0) ) {
                      
                 
                        einsteinplay.Einstein_PredictionResult predictionList = null;
                       if(modelId == 'CommunitySentiment') {
                         	predictionList = service.predictSentiment(modelId, text, 2, null);
                        } else {
							predictionList  = service.predictIntent(modelId, text, 2, null);
                        }
                        Double topPred = 0;
                        String label = '';
                       
                       
                        if (service.httpStatusCode>200) {
                            throw new AuraHandledException('API http error:' + service.httpErrorMessage);
                        }
                                    
                        for(einsteinplay.Einstein_Probability pred : predictionList.probabilities) {
                           // System.debug(pred);
                            if(pred.probability > topPred) {
                               label = pred.label;
                               topPred = pred.probability;
                            }
                        }  
                       
						//System.debug(label); 
                        obj.put(destinationName, label);
                 
                        shortList.add(obj);
                       
                    }
                }
            System.debug('---- Saving List ' + shortList.size() + ' ----');
        	update shortList; 
           
            return latestId;  
   }
    
}