public class AI_SvcCloudPredictionHelper {
    
    private static scrubDemo_Interaction_Analysis__c createSentimentRecord(string textToPredict, ID caseID, string ObjectToAnalyze, ID idOfObject){
        // Predict based from the Einstein Playground service
        einsteinplay.Einstein_PredictionService service = new einsteinplay.Einstein_PredictionService(einsteinplay.Einstein_PredictionService.Types.SENTIMENT);
        einsteinplay.Einstein_PredictionResult prediction = service.predictSentiment('CommunitySentiment', textToPredict, 3, null);
        scrubDemo_Interaction_Analysis__c ia = new scrubDemo_Interaction_Analysis__c(
            Case__c = caseID,
            Prediction_Result_1__c = prediction.probabilities[0].label,
            Prediction_Conf_1__c = prediction.probabilities[0].probability,
            Prediction_Result_2__c = prediction.probabilities[1].label,
            Prediction_Conf_2__c = prediction.probabilities[1].probability,
            Prediction_Result_3__c = prediction.probabilities[2].label,
            Prediction_Conf_3__c = prediction.probabilities[2].probability,
            Analyzed_Object__c = objectToAnalyze,
            Analyzed_Object_ID__c = idOfObject
        );
        insert ia;
        return ia;
    }
    
    @future(callout=true)
    public static void caseSubjectSentiment(ID caseID){
        //scan case subject, get initial sentiment value
        Case c = [select id, subject from Case where id = :caseID];
        createSentimentRecord(c.subject, c.id, 'Case Subject', c.id);
    }
    
    @future(callout=true)
    public static void emailMessageSubjectSentiment(ID emID){
        EmailMessage em = [select id, textBody, relatedToID from emailMessage where id = :emID];
        createSentimentRecord(em.textBody, em.relatedToID, 'Email Body', em.id);
    }
    
    @future(callout=true)
    public static void caseCommentSentiment(ID ccID){
        CaseComment cc = [select id, commentBody, parentID from CaseComment where id = :ccID];
        createSentimentRecord(cc.commentBody, cc.parentID, 'Case Comment Body', cc.id);
    }
    
    @future(callout=true)
    public static void communityUserFeedItemSentiment(ID fiID){
        FeedItem fi = [select id, body, parentID from FeedItem where id = :fiID];
        createSentimentRecord(fi.body, fi.ParentId, 'Chatter Post', fi.id);
    }
    
    @future(callout=true)
    public static void communityUserFeedCommentSentiment(ID fcID){
        FeedComment fc = [select id, commentBody, parentID from FeedComment where id = :fcID];
        createSentimentRecord(fc.commentBody, fc.ParentId, 'Chatter Comment', fc.id);
    }
    
}