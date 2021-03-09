trigger insertNewWatchWordScheduler on Chatter_Story__c (after insert) {
    if(System.isBatch()) return;
    FeedItem f = new FeedItem();
    for(Chatter_Story__c w : Trigger.New)
    {
        f.parentId = w.id;
        f.body = 'Please insert COMMENTS you want to auto show under this feedItem. DO NOT POST NEW FEEDITEMS ON THIS RECORD!\n\n'+
                 'You can use Chatter Charades on "Chatter Story" object to build custom feed comments.\n' + 
                 'Note: the order is sorted by feedcomment.CreatedDate ASC, so first comment should be earlier than the rest';
        f.type = 'TextPost';
        f.createdDate = System.Now().addHours(-2);
        insert f;
    }
    
}