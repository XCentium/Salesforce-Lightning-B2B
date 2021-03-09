/**
 * Created by scheck on 11/2/18.
 */

public with sharing class qtc_QuickCreditDebitCTRL {

    @AuraEnabled
    public static Id saveCredit(Id invoiceId, Decimal totalAmount) {
        Q2C_Demo_Settings__c settings = Q2C_Demo_Settings__c.getOrgDefaults();
        SObjectType thisObjectType = invoiceId.getSobjectType();
        blng__CreditNote__c newCreditNote = new blng__CreditNote__c();

        if(thisObjectType == blng__Invoice__c.getSObjectType()){

            blng__Invoice__c thisInvoice = [
                    SELECT
                            blng__Account__c
                    FROM blng__Invoice__c
                    WHERE Id =: invoiceId];


            newCreditNote.blng__Account__c = thisInvoice.blng__Account__c;
            newCreditNote.blng__CreditNoteDate__c = System.TODAY();
            newCreditNote.blng__RelatedInvoice__c = thisInvoice.Id;

        } else if (thisObjectType == Account.getSObjectType()){

            newCreditNote.blng__Account__c = invoiceId;
            newCreditNote.blng__CreditNoteDate__c = System.TODAY();

        } else {
            return null;
        }

        Database.insert(newCreditNote);
        if([SELECT Id, Name FROM Product2 WHERE Name =:settings.Credit_Note_Line_Product_Name__c].size()>0){
        Product2 creditProduct = [
                SELECT
                        Id,
                        Name
                FROM Product2
                WHERE Name =: settings.Credit_Note_Line_Product_Name__c
                LIMIT 1];
                blng__CreditNoteLine__c creditNoteLine = new blng__CreditNoteLine__c(
                blng__CreditNote__c = newCreditNote.Id,
                blng__Product__c = creditProduct.Id,
                blng__Subtotal__c = totalAmount,
                blng__TaxAmount__c = 0);

        Database.insert(creditNoteLine);

        newCreditNote.blng__Status__c = 'Posted';

        Database.update(newCreditNote);

        return newCreditNote.Id;
        }else{
            Product2 creditProduct = New Product2(Name = 'Credit', Standard_PriceBook_Price__c = 0);
            insert creditProduct;
            blng__CreditNoteLine__c creditNoteLine = new blng__CreditNoteLine__c(
                blng__CreditNote__c = newCreditNote.Id,
                blng__Product__c = creditProduct.Id,
                blng__Subtotal__c = totalAmount,
                blng__TaxAmount__c = 0);

        Database.insert(creditNoteLine);

        newCreditNote.blng__Status__c = 'Posted';

        Database.update(newCreditNote);

        return newCreditNote.Id;
        }

        
    }

    @AuraEnabled
    public static Id saveDebit(Id invoiceId, Decimal totalAmount) {
        SObjectType thisObjectType = invoiceId.getSobjectType();
        blng__DebitNote__c newDebitNote = new blng__DebitNote__c();
        Q2C_Demo_Settings__c settings = Q2C_Demo_Settings__c.getOrgDefaults();

        if(thisObjectType == blng__Invoice__c.getSObjectType()){
            blng__Invoice__c thisInvoice = [
                    SELECT
                            blng__Account__c
                    FROM blng__Invoice__c
                    WHERE Id =: invoiceId];

            newDebitNote.blng__Account__c = thisInvoice.blng__Account__c;
            newDebitNote.blng__DebitNoteDate__c = System.TODAY();

        } else if (thisObjectType == Account.getSObjectType()){

            newDebitNote.blng__Account__c = invoiceId;
            newDebitNote.blng__DebitNoteDate__c = System.TODAY();

        } else {
            return null;
        }

        Database.insert(newDebitNote);
        
        
        if([SELECT Id, Name FROM Product2 WHERE Name = :settings.Debit_Note_Line_Product_Name__c].size()>0){
        Product2 debitProduct = [
                SELECT
                        Id,
                        Name
                FROM Product2
                WHERE Name =:settings.Debit_Note_Line_Product_Name__c
                LIMIT 1];

        blng__DebitNoteLine__c debitNoteLine = new blng__DebitNoteLine__c(
                blng__DebitNote__c = newDebitNote.Id,
                blng__Product__c = debitProduct.Id,
                blng__Subtotal__c = totalAmount,
                blng__TaxAmount__c = 0);

        Database.insert(debitNoteLine);

        newDebitNote.blng__Status__c = 'Posted';

        Database.update(newDebitNote);

        return newDebitNote.Id;
        }else {
        Product2 debitProduct = new Product2(Name = 'Fee', Standard_PriceBook_Price__c = 0);
        insert debitProduct;
        
                blng__DebitNoteLine__c debitNoteLine = new blng__DebitNoteLine__c(
                blng__DebitNote__c = newDebitNote.Id,
                blng__Product__c = debitProduct.Id,
                blng__Subtotal__c = totalAmount,
                blng__TaxAmount__c = 0);

        Database.insert(debitNoteLine);

        newDebitNote.blng__Status__c = 'Posted';

        Database.update(newDebitNote);

        return newDebitNote.Id;
        }
        

    }
}