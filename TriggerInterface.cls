public interface TriggerInterface {
    void beforeInsert(List<SObject> newList);
    void afterInsert(List<SObject> newList, Map<Id, SObject> newMap);
    void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
    void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
    void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap);
    void afterDelete(Map<Id, SObject> oldMap);
    void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap);
}