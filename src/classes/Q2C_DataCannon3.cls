public class Q2C_DataCannon3 {

    public static void copyQuote(String quoteId, Date startDate, Date endDate, Integer numRecords, Boolean rndQuantity, Boolean rndTerm, Boolean rndDiscounts) {
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        List<SBQQ__Quote__c> qsToInsertA = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qsToInsertB = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c masterQuote = [SELECT Id, SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];

        List<Account> accts = [SELECT Id, Name FROM Account LIMIT 100];
        Set<String> qInsertIds = new Set<String>();

        // CALCULATE DATE RANGE
        Integer totalMonths = startDate.monthsBetween(endDate);
        Double avgOppsMonth = numRecords;
        Date mutableDate = Date.newInstance(startDate.year(), startDate.month(), 15);
        Date now = Date.today();

        // RANDOMIZE VALUES
        // NOTE ON PERFORMANCE: In order to minimize the number of processing intense math calls, there is a pre-randomized & sorted list for discount deviation.
        List<Double> deviationList = new List<Double>{
                1.13, 1.46, 1.38, 0.92, 0.58, 0.7, 0.5, 1.34, 1.45, 1.34, 0.75, 1.06, 1.21, 0.81, 0.93, 0.64, 0.8, 0.99, 0.93, 0.64, 0.74, 0.83, 1.24, 1.28, 0.65, 0.58, 1.45, 1.08, 0.87, 1.5, 1.27, 0.98, 0.64, 1.06, 1.47, 1.1, 0.66, 1.19, 0.51, 0.86, 1.39, 0.98, 0.61, 0.87, 0.54, 1.37, 0.77, 0.54, 1.47, 0.68, 0.65, 0.73, 1.35, 0.6, 1.02
        };
        Double randomD = Math.random();
        Integer rand100 = (randomD * 100).intValue();
        Integer acctCounter = rand100;
        Integer stageNameAssignment, userAssignment, randListAssignment;

        // GET OPPORTUNITY STAGE VALUES
        // OPPORTUNITIES W/CLOSE DATE BEFORE TODAY CAN ONLY BE CLOSED WON/CLOSED LOST & AFTER TODAY CANNOT BE CLOSED WON
        List<String> stageValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        String mutableValue;
        for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            mutableValue = f.getValue();
            if ((mutableValue != 'Closed Won') && (mutableValue != 'Closed Lost')) {
                stageValues.add(mutableValue);
            }
        }
        Integer stageCount = stageValues.size();
        String stageValue;

        // DEFINE FIXED VALUES
        List<String> oppNames = new List<String>{
                '(New Pilot)', '(Regional Project)', '(Enterprise Deal)', '(One Division Project)', '(South America Project)', '(EMEA Project)', '(Global Rollout)', '(North America Project)', '(Partner Sale)'
        };
        List<Double> termValues = new List<Double>{
                6, 12, 24, 24, 24, 36, 36, 36, 36
        };
        Integer randListSize = oppNames.size();
        Double termValue = masterQuote.SBQQ__SubscriptionTerm__c;

        // DEFINE USER POOL
        // USER POOL IS WEIGHTED TO TOP 20% SALES REPS
        List<User> userPool = [SELECT Id, Name FROM User WHERE isActive = True  LIMIT 10];
        for (Integer i = 0; i < userPool.size() / 5; i++) {
            userPool.add(userPool.get(i));
            userPool.add(userPool.get(i));
        }
        Integer userCount = userPool.size();

        // BEGIN POPULATING OPPORTUNITY AND QUOTE LISTS
        for (Integer i = 0; i < totalMonths; i++) {
            for (Integer ii = 0; ii < avgOppsMonth; ii++) {
                stageNameAssignment = (randomD * stageCount).intValue();
                userAssignment = (randomD * userCount).intValue();
                randListAssignment = (randomD * randListSize).intValue();

                if (rndTerm == true) {
                    termValue = termValues.get(randListAssignment);
                }


                if (mutableDate < now) {
                    if (randomD > 0.30) {
                        stageValue = 'Closed Won';
                    } else {
                        stageValue = 'Closed Lost';
                    }
                } else {
                    stageValue = stageValues.get(stageNameAssignment);
                }

                Account aa = accts.get(acctCounter);
                Opportunity opp = new Opportunity(Name = aa.Name + ' ' + oppNames.get(randListAssignment), AccountId = aa.Id, CloseDate = mutableDate, StageName = stageValue);
                SBQQ__Quote__c qt = new SBQQ__Quote__c(SBQQ__StartDate__c = mutableDate, SBQQ__SubscriptionTerm__c = termValue, SBQQ__Primary__c = false, SBQQ__Account__c = aa.Id, SBQQ__SalesRep__c = userPool.get(userAssignment).Id);

                oppsToInsert.add(opp);
                qsToInsertA.add(qt);

                if (acctCounter < 98) {
                    acctCounter++;
                } else {
                    acctCounter = 0;
                }

                // A SINGLE RANDOM VALUE IS USED TO SET OPP NAME AND STAGE IN ORDER TO MINIMIZE THE NUMBER OF MATH.RANDOM() CALLS.
                randomD = Math.random();

            }
            mutableDate = mutableDate.addMonths(1);
        }

        // INSERT OPPORTUNITIES BEFORE QUOTES BECAUSE OPPORTUNITY IDS ARE REQUIRED FOR QUOTE INSERT
        Database.SaveResult[] srOpps = new Database.SaveResult[]{
        };
        try {
            srOpps = Database.insert(oppsToInsert);
        } catch (Exception e) {
            System.debug('ERROR Mass Upload of Opportunities Failed. Exception: ' + e);
        }

        // UPDATE QUOTE LIST WITH REAL OPPORTUNITY IDS
        Id oId;
        for (Integer i = 0; i < srOpps.size(); i++) {
            oId = srOpps[i].getId();
            SBQQ__Quote__c qtt = qsToInsertA.get(i);
            qtt.SBQQ__Opportunity2__c = oId;
            qsToInsertB.add(qtt);
        }

        Database.SaveResult[] srQuotes = new Database.SaveResult[]{
        };
        try {
            srQuotes = Database.insert(qsToInsertB);
        } catch (Exception e) {
            System.debug('ERROR Mass Insert of Quotes Failed. EXCEPTION: ' + e);
        }

        for (Integer i = 0; i < srOpps.size(); i++) {
            qInsertIds.add(srQuotes[i].getId());
        }

        // CREATE LIST OF MASTER LINES TO BE CLONED
        List<SBQQ__QuoteLine__c> masterLines = new List<SBQQ__QuoteLine__c>();
        SObjectType lineToken = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c');
        DescribeSObjectResult lineDef = lineToken.getDescribe();
        Map<String, SObjectField> lineFieldsMap = lineDef.fields.getMap();
        List<String> lineFieldList = new List<String>(lineFieldsMap.keySet());
        String lineQuery = 'SELECT ' + String.join(lineFieldList, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.id =: quoteId';

        try {
            masterLines = Database.query(lineQuery);
        } catch (Exception e) {
            System.debug('ERROR Query of Master Line Items Failed. EXCEPTION: ' + e);
        }

        // EXECUTE BATCH PROCESSES
        // NOTE: A SECOND BATCH PROCESS IS NESTED IN qLineBlaster. qLineBlaster CREATES THE QUOTE LINES AND THEN priceRuleExecutor TRIGGERS PRICE RULE CALCULATION.
        Id batchProcessOne = Database.executeBatch(new qLineBlaster(masterLines, qInsertIds, deviationList, rndQuantity, rndDiscounts), 10);
    }
}