public class FSLVisionController {
    
    public static void getCallVisionContent(String parentId,String relatedId, String feedItemId) {
        // Get the file (ContentVersion)
        ContentVersion content = [select Id from ContentVersion where id =: relatedId limit 1]; 
        
        if (content != null) {
            // Get a public URL that can be sent to Einstein.
            // Using a URL avoids Apex Heap issues if sending large Base64 files.
            String contentUrl = createContentUrl(relatedId);
            
            callEinstein (parentId, contentUrl, feedItemId);            
        }
    }
    
    @future(callout=true)
    private static void callEinstein (String parentId, String contentUrl, String feedItemId) {        
        
        // Retrieve custom settings
        FSLVisSet__c setting = FSLVisSet__c.getInstance('Predict');
        
        // Predict based from the Einstein Playground service
        einsteinplay.Einstein_PredictionService service = new einsteinplay.Einstein_PredictionService(einsteinplay.Einstein_PredictionService.Types.IMAGE);
        einsteinplay.Einstein_PredictionResult prediction = service.predictImageUrl(setting.ModelId__c, contentUrl, 3, null);

        FeedItem post = new FeedItem();
        post.ParentId = parentId; 
        if (prediction.probabilities.size()>0) {
             if(Decimal.valueOf(prediction.probabilities[0].probability) > setting.Threshold__c) {
                post.Body = constructBody(prediction.probabilities[0], setting.Prediction_Response_Template__c);
             } else {
             	post.Body = 'Unable to detect. Please try again!';
             }
        }
        
        // Einstein_User_Name setting might be null if unset
        if (String.isBlank(setting.Einstein_User_Name__c)) {
            post.CreatedById = UserInfo.getUserId();
        } else {
        	String firstName = setting.Einstein_User_Name__c.substringBefore(' ');
        	String lastName = setting.Einstein_User_Name__c.substringAfter(' ');
      		List<User> poster = [SELECT Id FROM User WHERE FirstName = :firstName AND LastName = :lastName];
        
        	if ((firstName.length() == 0) || (lastName.length() == 0) || (poster.size() == 0)) {
            	post.CreatedById = UserInfo.getUserId();
        	} else {
        		post.CreatedById = poster[0].Id;
        	}
        }
        insert Post;
    }
    
    private static String constructBody(einsteinplay.Einstein_Probability prob, String template) {
        String response;
        if (String.isBlank(template)) {
            // Just in case the template setting is blank...
        	response = 'Einstein Vision Predict has identified the following : ';
            response += prob.label;
            response += ' with probability of ';
            response += prob.probability;

        } else {
            // Replace placeholders with values
            response = template.replace('{label}', prob.label).replace('{probability}', String.valueOf(prob.probability));
            
            // Just in case the placeholders weren't in the template, throw them on the end...
            if (!template.contains('{label}')) {
                response += ' label: ' + prob.label;
            }
            if (!template.contains('{probability}')) {
                response += ' probability: ' + prob.probability;
            }
        }
        
        return response;
    }
    
    
    private static string createContentUrl(String contentVersionId) {
        System.debug('createContentUrl ' + contentVersionId);
        string CD_TEMP_PREFIX = 'EinsteinTemp';
        integer EXPIRY = 5;
        
        ContentVersion CV = [select id, Title from ContentVersion where Id =: contentVersionId and isLatest = true];
        ContentDistribution CD = new ContentDistribution();
        CD.ContentVersionId = CV.Id;
        CD.Name = CD_TEMP_PREFIX + '_' + CV.Title;
        CD.PreferencesAllowOriginalDownload = true;
        CD.PreferencesLinkLatestVersion = true;
        CD.ExpiryDate = system.now().addMinutes(EXPIRY);
        CD.PreferencesExpires = true;
        CD.PreferencesNotifyOnVisit = false;
        CD.PreferencesNotifyRndtnComplete = false;
        insert CD;
        
        ContentDistribution CD2 = [select id, ContentDownloadUrl from ContentDistribution where Id =: cd.Id];
        return CD2.ContentDownloadUrl;
    }
    
}