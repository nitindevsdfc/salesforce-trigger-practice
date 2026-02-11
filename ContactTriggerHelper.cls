public class ContactTriggerHelper {
    
    // -----------------------------------------------------------------------------
    // Method: countAccountRelatedContacts
    // Purpose: Recalculates and updates the Number_of_Contacts__c field on related 
    //          Account records whenever Contact records are inserted, updated, 
    //          deleted, or undeleted. Ensures data consistency by using 
    //          aggregate queries to count all active Contacts linked to each Account.
    // Trigger Context: after insert, after update, after delete, after undelete
    // Parameters:
    //    newRecordsMap - Map of newly inserted or updated Contact records
    //    oldRecordsMap - Map of previous Contact records (for update/delete context)
    //    event         - String representing the current trigger event (e.g., 'afterInsert')
    // -----------------------------------------------------------------------------

    
    
public static void countAccountRelatedContacts(Map<Id, Contact> newRecordsMap,Map<Id, Contact> oldRecordsMap,String event) {

    Set<Id> accIdSet = new Set<Id>();

    if (event == 'afterUpdate') {
        for (Contact newCon : newRecordsMap.values()) {
            Contact oldCon = oldRecordsMap.get(newCon.Id);
            if (newCon.AccountId != oldCon.AccountId) {
                if (newCon.AccountId != null) accIdSet.add(newCon.AccountId);
                if (oldCon.AccountId != null) accIdSet.add(oldCon.AccountId);
            }
        }
    } else {
        Map<Id, Contact> mapToProcess = (event == 'afterDelete') ? oldRecordsMap : newRecordsMap;    
        for (Contact con : mapToProcess.values()) {
            if (con.AccountId != null) accIdSet.add(con.AccountId);
        }
    }

    if (accIdSet.isEmpty()) return;

    Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
    for (Id accId : accIdSet) {
        accountsToUpdate.put(accId, new Account(Id = accId, Number_of_Contacts__c = 0));
    }

    for (AggregateResult ar : [
        SELECT AccountId accId, COUNT(Id) cnt
        FROM Contact
        WHERE AccountId IN :accIdSet
        GROUP BY AccountId
    ]) {
        accountsToUpdate.get((Id)ar.get('accId')).Number_of_Contacts__c = (Integer)ar.get('cnt');
    }

    try {
        update accountsToUpdate.values();
    } catch (DmlException e) {
        System.debug('Error updating accounts: ' + e.getMessage());
    }
}
    
    
public static void operationOnContactRelationship(Map<Id, Contact> newRecordsMap, Map<Id, Contact> oldRecordsMap, String event) {
    
    Map<Id, Contact> mapToProcess = (event == 'beforeDelete' || event == 'afterDelete') ? oldRecordsMap : newRecordsMap;
    
    if (mapToProcess.isEmpty())
        return;
    
    Set<Id> contactIds = mapToProcess.keySet();
    
    if (event == 'afterInsert') {
        List<Contact_Relationship__c> crList = new List<Contact_Relationship__c>();
        for (Contact con : mapToProcess.values()) {
            if (con.Contact_Relationship__c) {
                crList.add(new Contact_Relationship__c(Contact__c = con.Id, Contact_Relationship_Name__c = 'Related to ' + con.LastName));
            }
        }
        
        if (!crList.isEmpty()) insert crList;
        
    } else if (event == 'beforeDelete') {
        List<Contact_Relationship__c> crList = [SELECT Id FROM Contact_Relationship__c WHERE Contact__c IN :contactIds];
        if (!crList.isEmpty()) delete crList;
        
    } else if (event == 'afterUndelete') {
        List<Contact_Relationship__c> crList = [SELECT Id FROM Contact_Relationship__c WHERE Contact__c IN :contactIds AND IsDeleted = true ALL ROWS];
        if (!crList.isEmpty()) undelete crList;
    }
}
    
}