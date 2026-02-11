public class NewAccountTriggerHandler implements TriggerInterface {

    public void beforeInsert(List<SObject> newList) {

    }

    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
		//	NewAccountTriggerHelper.relatedContactRecords((Map<Id,Account>) newMap, NULL, 'afterInsert');
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
       
    }

	public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        Map<Id, Account> newAccMap = (Map<Id, Account>) newMap;
        Map<Id, Account> oldAccMap = (Map<Id, Account>) oldMap;
    
  //    NewAccountTriggerHelper.relatedContactRecords(newAccMap, oldAccMap, 'afterUpdate');
  	    NewAccountTriggerHelper.updateRelatedContactWithPhone(newAccMap, oldAccMap);
    
	}


    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
      //  NewAccountTriggerHelper.preventAccountDeletion((Map<Id, Account>) oldMap);
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
        
    }

    public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
        
    }
}