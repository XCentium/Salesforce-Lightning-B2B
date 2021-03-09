/**
* interface for mapping triggers to handlers
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-22 
*/
public interface SCCTriggerHandlerInterface {
    
    void onBeforeInsert(List<SObject> newList);
    void onAfterInsert(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);

}