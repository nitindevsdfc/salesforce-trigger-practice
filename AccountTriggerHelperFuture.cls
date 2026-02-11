public class AccountTriggerHelperFuture {
	
    
    @future
    public static void updateAccountRelatedContactPhone(String accountRecords) {
        
        
        List<Account> accList = (List<Account>) JSON.deserialize(accountRecords, List<Account>.class);
        
        
        Set<Id> accIds = new Set<Id>();
        for (Account acc : accList) {
            if (acc.Id != null) {
                accIds.add(acc.Id);
            }
        }
        
        
        List<Contact> conList = [SELECT Id, AccountId, Account.Phone FROM Contact WHERE AccountId IN :accIds];

        for (Contact con : conList) {
            con.Phone = con.Account.Phone;
        }
        
        
        if (!conList.isEmpty()) {
            update conList;
        }
    }
}