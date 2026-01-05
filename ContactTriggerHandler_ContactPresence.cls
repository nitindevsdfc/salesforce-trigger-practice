public class ContactTriggerHandler {

    public static void SetContactsPresence(Map<Id, Contact> oldMap) {

        Set<Id> accountIds = new Set<Id>();

        for (Contact con : oldMap.values()) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Aggregate remaining contacts
        Map<Id, Integer> accMap = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) total
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accMap.put((Id) ar.get('accId'), (Integer) ar.get('total'));
        }

        List<Account> accList = new List<Account>();

        for (Id accId : accountIds) {
            // Only accounts with ZERO remaining contacts
            if (!accMap.containsKey(accId)) {
                accList.add(
                    new Account(
                        Id = accId,
                        Has_Contacts__c = false
                    )
                );
            }
        }

        if (!accList.isEmpty()) {
            Database.update(accList, false);
        }
    }
}
