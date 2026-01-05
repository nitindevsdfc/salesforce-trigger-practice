public class AccountTriggerHandler {

    public static Boolean isProcessed = false;

    public static void LastRatedDateUpdate(Map<Id, Account> newMap, Map<Id, Account> oldMap ) {
       

        if (isProcessed) {
            return;
        }

        for (Account acc : newMap.values()) {

            Account oldAccount = oldMap.get(acc.Id);

            if (acc.Rating == 'Hot' && oldAccount != null &&  oldAccount.Rating != acc.Rating ){
                   
                acc.Last_Rated_Date__c = Date.today();
            }
        }

        isProcessed = true;
    }
}