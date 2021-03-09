public class Q2CinitBilling {

    public static void initBill() {
        clearit();
        createFinancePeriods();
        createRevenueTreatments();
        resetPG();
        resetTR();
    }

    public static void resetPG() {
        List<blng__PaymentGateway__c> PGs = [SELECT adnblng__APILoginId__c , adnblng__APITransactionKey__c  FROM blng__PaymentGateway__c ];
        for (blng__PaymentGateway__c pg : PGs) {
            pg.adnblng__APILoginId__c = '3y33JXnnN5Z4';
            pg.adnblng__APITransactionKey__c = '57zJ2sG376mXkRqf';
        }
        update PGs;
    }

    //tax treatments
    public static void resetTR() {
        List<blng__TaxRate__c> NewTRs = new List<blng__TaxRate__c>();
        List<blng__TaxRate__c> OldTRs = [
                SELECT Name, blng__State__c, blng__City__c, blng__ZipCode__c, blng__Country__c, blng__Priority__c,
                        blng__TaxCode__c, blng__Rate__c, blng__LegalEntity__c
                FROM blng__TaxRate__c
        ];
        for (Integer i = 0; i < OldTRs.size(); i++) {
            blng__TaxRate__c NewTR = OldTRs.get(i).clone(false, true);
            NewTR.blng__AddressComparison__c = NewTR.blng__Country__c+'----'+NewTR.blng__TaxCode__c+'-'+NewTR.blng__LegalEntity__c;
            NewTR.blng__PriorityAddressComparison__c = NewTR.blng__Priority__c+'-'+NewTR.blng__Country__c+'----'+NewTR.blng__TaxCode__c+'-'+NewTR.blng__LegalEntity__c;
            NewTRs.add(NewTR);
        }
        delete OldTRs;
        insert NewTRs;
    }

    //Finance Periods
    public static void createFinancePeriods() {


        Integer mutableYear, mutableMonth;
        Date periodStart, periodEnd;
        List<blng__FinancePeriod__c> fpToInsert = new List<blng__FinancePeriod__c>();
        List<blng__LegalEntity__c> allLegalEntities = [SELECT Id FROM blng__LegalEntity__c];
        Date todayDate = Date.today();
        Integer monthZero = todayDate.month();
        Integer yearZero = todayDate.year();
        Map<Integer, String> monthNameMap = new Map<Integer, String>{
                1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
        };

        for (blng__FinanceBook__c fb : [SELECT Id, Name, blng__PeriodType__c FROM blng__FinanceBook__c]) {
            for (blng__LegalEntity__c le : allLegalEntities) {
                //for (CurrencyType curr : currencies) {
                    for (Integer i = 0; i < 48; i++) {
                        if (i == 0) {
                            periodStart = Date.newInstance(yearZero, monthZero, 1);
                            periodEnd = Date.newInstance(yearZero, monthZero, Date.daysInMonth(yearZero, monthZero));
                        } else {
                            periodStart = periodStart.addMonths(1);
                            mutableYear = periodStart.year();
                            mutableMonth = periodStart.month();
                            periodEnd = Date.newInstance(mutableYear, mutableMonth, Date.daysInMonth(mutableYear, mutableMonth));

                        }
                        blng__FinancePeriod__c fp = new blng__FinancePeriod__c(
                                Name = monthNameMap.get(periodStart.month()) + ' ' + String.valueOf(periodStart.year()) + '-' + fb.blng__PeriodType__c,
                                blng__PeriodStartDate__c = periodStart,
                                blng__PeriodEndDate__c = periodEnd,
                                blng__FinanceBook__c = fb.Id,
                                blng__PeriodStatus__c = 'Open',
                                blng__LegalEntity__c = le.Id
                                //CurrencyIsoCode = curr.IsoCode
                        );
                        fpToInsert.add(fp);
                    }
                //}
            }
        }

        insert fpToInsert;
    }

    //Revenue Distribution Methods
    public static void createRevenueTreatments() {
        List<blng__RevenueRecognitionTreatment__c> NewRevTreats = new List<blng__RevenueRecognitionTreatment__c>();
        List<blng__RevenueRecognitionTreatment__c> OldRevTreats = [
                SELECT Name, blng__Active__c,blng__FlatAmount__c,blng__Notes__c,
                        blng__Percentage__c,blng__ProcessingOrder__c,blng__RevenueAgreementAssociation__c,blng__RevenueDistributionMethod__c,
                        blng__RevenueFinanceBook__c,blng__RevenueGLRule__c,blng__RevenueLegalEntity__c,blng__RevenueRecognitionRule__c,blng__RevenueScheduleAmount__c,
                        blng__RevenueScheduleCreationAction__c, blng__Type__c
                FROM blng__RevenueRecognitionTreatment__c
        ];

        for (Integer i = 0; i < OldRevTreats.size(); i++) {
            blng__RevenueRecognitionTreatment__c NewRev = OldRevTreats.get(i).clone(false, true);
            NewRevTreats.add(NewRev);
        }
        delete OldRevTreats;
        insert NewRevTreats;
        List<blng__TaxRate__c> NewTaxRate = new List<blng__TaxRate__c>();
        List<blng__TaxRate__c> OldTaxRate = [
                SELECT Name, blng__TaxCode__c, blng__State__c,blng__City__c,blng__Rate__c ,blng__ZipCode__c,blng__Country__c,blng__LegalEntity__c ,blng__Priority__c
                FROM blng__TaxRate__c
        ];

        for (Integer i = 0; i < OldTaxRate.size(); i++) {
            blng__TaxRate__c NewTR = OldTaxRate.get(i).clone(false, true);
            NewTaxRate.add(NewTR);
        }
        delete OldTaxRate;
        insert NewTaxRate;
    }

    public static void clearit() {
        List<blng__RevenueSchedule__c> deleteRS = [SELECT Id FROM blng__RevenueSchedule__c];
        delete deleteRS;
        List<blng__RevenueTransaction__c> deleteRT = [SELECT Id FROM blng__RevenueTransaction__c];
        delete deleteRT;
        List<blng__FinancePeriod__c> deleteFP = [SELECT Id FROM blng__FinancePeriod__c];
        delete deleteFP;

    }
}