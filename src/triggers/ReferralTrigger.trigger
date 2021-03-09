trigger ReferralTrigger on Referral__c (after insert) {
    if(System.isBatch()) return;
    //just renumber all the referrals
    list<Referral__c> referrals = [select id, candidate_Id__c from Referral__c];
    for (integer k=0; k<referrals.size(); k++){
        referrals[k].candidate_Id__c = string.valueOf(k+1);
    }
    update referrals;
}