public class AccountTriggerHandler {

    public static void setPriorityAccount(List<Account> newList, Map<Id, Account> oldMap ) {
        
        
        for (Account newRecord : newList) {

            Account oldRecord = (oldMap != null) ? oldMap.get(newRecord.Id) : null;
                
            if (newRecord.Rating == 'Hot' && newRecord.NumberOfEmployees > 1000 && (oldRecord == null || oldRecord.Rating != newRecord.Rating || 
			    oldRecord.NumberOfEmployees != newRecord.NumberOfEmployees)) {
                newRecord.Priority__c = 'High';
            }
        }
    }
}