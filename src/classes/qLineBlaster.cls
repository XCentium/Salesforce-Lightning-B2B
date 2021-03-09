global class qLineBlaster implements Database.Batchable<SObject> {

    global final Set<String> qIds;
    global final Decimal aDisc;
    global final List<SBQQ__QuoteLine__c> mLns;
    global final String query;
    global final List<Double> deviations;
    global final Boolean randQuantity;
    global final Boolean randDiscounts;

    global qLineBlaster(List<SBQQ__QuoteLine__c> masterLines, Set<String> quoteIds, List<Double> deviationList, Boolean rndQuantity, Boolean rndDiscounts) {
        // BIND VALUES TO GLOBAL SCOPE
        mLns = masterLines; qIds = quoteIds; deviations = deviationList; randQuantity = rndQuantity; randDiscounts = rndDiscounts;
        query = 'SELECT id FROM SBQQ__Quote__c WHERE id IN: qIds';
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext info, List<SBQQ__Quote__c> scope) {

        // DISABLE TRIGGERS FOR FAST UPLOAD AND GOVERNOR LIMIT AVOIDANCE
        SBQQ.TriggerControl.disable();

        //INITIALIZING VARIABLES
        Integer devListSize = deviations.size() - 1;
        Double deviation = 0;
        Integer modifier = 1;
        Double discountModified = 0;
        Double quantityModified;
        Double lineDiscount;

        List<SBQQ__QuoteLine__c> linesToInsert = new List<SBQQ__QuoteLine__c>();
        Integer devCounterMutable = deviations.size() * Math.random().intValue();
        for (SBQQ__Quote__c s : scope) {
            List<SBQQ__QuoteLine__c> clonedLines = mLns.deepClone(false, false, false);
            for (SBQQ__QuoteLine__c line : clonedLines) {
                deviation = deviations.get(devCounterMutable);
                lineDiscount = line.Additional_Discount_Calc__c;

                if (lineDiscount > 0) {
                    if (randDiscounts == true) {
                        discountModified = lineDiscount * deviation;
                    } else {
                        discountModified = lineDiscount;
                    }
                } else {
                    discountModified = 0;
                }

                if (randQuantity == true) {
                    quantityModified = line.SBQQ__Quantity__c * modifier;
                } else {
                    quantityModified = line.SBQQ__Quantity__c;
                }

                line.SBQQ__Quote__c = s.Id;
                line.SBQQ__Discount__c = discountModified;
                line.SBQQ__NetPrice__c = line.SBQQ__NetPrice__c;
                line.SBQQ__Quantity__c = quantityModified;
                //BUNDLES & GROUPS ARE NOT CURRENTLY SUPPORTED
                line.SBQQ__RequiredBy__c = null;
                line.SBQQ__OptionLevel__c = null;
                line.SBQQ__Group__c = null;

                linesToInsert.add(line);

                if (devCounterMutable < devListSize) {
                    devCounterMutable++;
                } else {
                    devCounterMutable = 0;
                }
            }

            if (modifier >= 4) {
                modifier = 1;
            } else {
                modifier++;
            }

        }
        Database.insert(linesToInsert);
    }

    global void finish(Database.BatchableContext info) {
        SBQQ.TriggerControl.enable();
        String q = 'SELECT id FROM SBQQ__Quote__c';
        String e = 'SBQQ__Quote__c';
        String f = 'SBQQ__Primary__c';
        Boolean v = true;

        Id batchProcessTwo = Database.executeBatch(new genericBatchExecutor(q, e, f, v), 10);
    }
}