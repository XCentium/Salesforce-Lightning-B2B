global class genericBatchExecutor implements Database.Batchable<SObject> {

    global final String query;
    global final String entity;
    global final String field;
    global final Boolean value;

    global genericBatchExecutor(String q, String e, String f, Boolean v) {
        query = q;
        entity = e;
        field = f;
        value = v;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        for (SObject s : scope) {
            s.put(field, value);
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }
}