public class JPSDO_TranslateKnowledgeRecords {

    Static String[] tableNameList = new List<String>{'Alert__kav', 'FAQ__kav', 'How_To__kav', 'Order_Support__kav', 'Technical__kav'};

    public String status{get;set;}
    public JPSDO_TranslateKnowledgeRecords(){
        status = '';
    }
    public PageReference TranslateKnowledge() {
        List<String> DraftTranslationList;
        
        for(String tableName : tableNameList){
            DraftTranslationList = new List<String>();
            List<SObject> snl;//sObjectNewList
            String[] inputvalues;
            
            PageReference fileRef = new PageReference('/resource/KnowledgeJP/KnowledgeJP/'+tableName+'.csv');
            Blob knowledgeTranslationData = fileRef.getContent();
            
            List<List<String>> allFields = new List<List<String>>();
            allFields = parseCSV(knowledgeTranslationData.toString(), false);
            
            DraftTranslationList = submitForTranslation(allFields);
            
            snl = database.query('select Id, KnowledgeArticleId from ' + tableName + ' where ID IN : DraftTranslationList'); 
            System.debug('snl.size()'+tableName+':'+snl.size());
            for(sObject sn : snl){
                for(List<String> lineFields : allFields){
                    if(lineFields.get(0) == sn.get('KnowledgeArticleId')){
                        for(Integer i=1;i<lineFields.size();i++){
                            sn.put(allFields.get(0).get(i), lineFields.get(i));
                        }
                    }
                }
            }
            Update snl;
            for(sObject sn : snl){
                KbManagement.PublishingService.completeTranslation((ID)sn.get('Id'));
            }
        }
        status = 'done!';
        return null;
    }
    public List<ID> submitForTranslation(List<List<String>> allFields){
    
        String DraftTranslation;
        String userId = UserInfo.getUserId();
        Datetime now = Datetime.now();
        List<String> DraftTranslationList = new List<String>();
        String KnowledgeArticleId;

        for(Integer i=1;i<allFields.size();i++){
            KnowledgeArticleId = allFields.get(i).get(0);
            DraftTranslation = KbManagement.PublishingService.submitForTranslation(KnowledgeArticleId, 'ja', userId, now);
            DraftTranslationList.add(DraftTranslation);
        }
        return DraftTranslationList;
    }
    
    public PageReference publishAllDraftArticles(){
        for(String tableName : tableNameList){
        
            List<sObject> spl = database.query('select Id, KnowledgeArticleId from ' + tableName + ' where publishstatus = \'draft\' and language = \'en_US\' and IsMasterLanguage = true '); 
            for(sObject s : spl){
                KbManagement.PublishingService.publishArticle((ID)s.get('KnowledgeArticleId'), true);
            }
        }
        status = 'done!';
        return null;
    }
    public PageReference deleteAllTranslationArticle(){
        for(String tableName : tableNameList){
        
            List<sObject> spl = database.query('select Id, KnowledgeArticleId from ' + tableName + ' where publishstatus = \'draft\' and language = \'en_US\' and IsMasterLanguage = true '); 
            for(sObject s : spl){
                KbManagement.PublishingService.publishArticle((ID)s.get('KnowledgeArticleId'), true);
            }
        
            List<sObject> sdl = database.query('select Id, KnowledgeArticleId from ' + tableName + ' where publishstatus = \'draft\' and language = \'ja\' and IsMasterLanguage = false '); 
            for(sObject s : sdl){
                KbManagement.PublishingService.deleteDraftTranslation ((ID)s.get('Id'));
            }
            List<sObject> sol = database.query('select Id, KnowledgeArticleId from ' + tableName + ' where publishstatus = \'online\' and language = \'ja\''); 
            for(sObject s : sol){
                KbManagement.PublishingService.editPublishedTranslation((ID)s.get('KnowledgeArticleId'), 'ja', true);
            }
            List<sObject> sdl2 = database.query('select Id, KnowledgeArticleId from ' + tableName + ' where publishstatus = \'draft\' and language = \'ja\' and IsMasterLanguage = false '); 
            for(sObject s : sdl2){
                KbManagement.PublishingService.deleteDraftTranslation ((ID)s.get('Id'));
            }
        }
        status = 'done!';
        return null;
    }
    
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
    List<List<String>> allFields = new List<List<String>>();

    // replace instances where a double quote begins a field containing a comma
    // in this case you get a double quote followed by a doubled double quote
    // do this for beginning and end of a field
    contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
    // now replace all remaining double quotes - we do this so that we can reconstruct
    // fields with commas inside assuming they begin and end with a double quote
    contents = contents.replaceAll('""','DBLQT');
    // we are not attempting to handle fields with a newline inside of them
    // so, split on newline to get the spreadsheet rows
    List<String> lines = new List<String>();
    try {
        lines = contents.split('\n');
    } catch (System.ListException e) {
        System.debug('Limits exceeded?' + e.getMessage());
    }
    Integer num = 0;
    for(String line : lines) {
        // check for blank CSV lines (only commas)
        if (line.replaceAll(',','').trim().length() == 0) break;
        
        List<String> fields = line.split(',');  
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
        for(String field : fields) {
            if (field.startsWith('"') && field.endsWith('"')) {
                //cleanFields.add(field.replaceAll('DBLQT','"'));
                cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
            } else if (field.startsWith('"')) {
                makeCompositeField = true;
                compositeField = field;
            } else if (field.endsWith('"')) {
                compositeField += ',' + field;
                cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                makeCompositeField = false;
            } else if (makeCompositeField) {
                compositeField +=  ',' + field;
            } else {
                cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
            }
        }
        
        allFields.add(cleanFields);
    }
    if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
}