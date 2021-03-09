trigger AI_CaseSentimentTrigger on Case (after insert) {
    if(System.isBatch()) return;
    AI_SvcCloudPredictionHelper.caseSubjectSentiment(trigger.new[0].id);
}