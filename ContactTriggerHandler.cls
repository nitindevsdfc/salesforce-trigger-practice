public with sharing class ContactTriggerHandler implements TriggerInterface {

    public void beforeInsert(List<SObject> newList) {

    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
        	ContactTriggerHelper.countAccountRelatedContacts((Map<Id, Contact>) newMap, NULL, 'afterInsert');
        	ContactTriggerHelper.operationOnContactRelationship((Map<Id, Contact>) newMap, NULL, 'afterInsert');
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        System.debug('Before Update logic for Contact');
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
		ContactTriggerHelper.countAccountRelatedContacts((Map<Id, Contact>) newMap, (Map<Id, Contact>) oldMap ,'afterUpdate');
    }

    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        ContactTriggerHelper.operationOnContactRelationship(NULL,(Map<Id, Contact>) oldMap,'beforeDelete');
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
        ContactTriggerHelper.countAccountRelatedContacts(NULL, (Map<Id, Contact>) oldMap ,'afterDelete');
        

    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
             ContactTriggerHelper.countAccountRelatedContacts((Map<Id, Contact>) newMap, NULL ,'afterUndelete');
        	 ContactTriggerHelper.operationOnContactRelationship((Map<Id, Contact>) newMap, NULL, 'afterUndelete');

    }
}