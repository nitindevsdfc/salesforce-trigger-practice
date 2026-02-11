public class NewAccountTriggerHelper {

    // -----------------------------------------------------------------------------
    // Method: updateAccountIndustry
    // Purpose: Updates default field values for Account records.
    //          - Sets Industry to 'Education'.
    //          - Sets Description if blank.
    // Trigger Context: before insert, before update
    // -----------------------------------------------------------------------------
    public static void updateAccountIndustry(List<Account> accountList) {
        for (Account acc : accountList) {
            acc.Industry = 'Education';
            
            if (String.isBlank(acc.Description)) {
                acc.Description = 'Account Description is Blank';
            }
        }
    }

    // -----------------------------------------------------------------------------
    // Method: createAccountRelatedTask
    // Purpose: Creates follow-up Tasks and sends email alerts for Accounts
    //          missing both Industry and Phone fields.
    // Trigger Context: after insert, after update
    // -----------------------------------------------------------------------------
    public static void createAccountRelatedTask(List<Account> accountList) {
        List<Task> taskList = new List<Task>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (Account acc : accountList) {
            if (acc.Industry == null && acc.Phone == null) {
                // Create a follow-up Task
                Task t = new Task(
                    Subject = 'Created From Apex Trigger',
                    Status = 'Not Started',
                    Priority = 'High',
                    Description = 'Created From Apex Trigger',
                    ActivityDate = System.today().addDays(7),
                    WhatId = acc.Id,
                    OwnerId = acc.OwnerId
                );
                taskList.add(t);

                // Prepare Email Notification
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('New Account ' + acc.Name + ' is missing contact details');
                email.setPlainTextBody(
                    'Hello,\n\n' +
                    'This is to inform you that the following Account record is missing important contact details.\n\n' +
                    'Account Name: ' + acc.Name + '\n' +
                    'Phone: Not Provided\n' +
                    'Email: Not Provided\n\n' +
                    'Please update the Account record with valid contact details.\n\n' +
                    'Thank you,\nSalesforce Notification System'
                );

                // Placeholder: Replace with actual owner email fetch query
                email.setToAddresses(new List<String>{'example@company.com'});
                email.setBccAddresses(new List<String>{'nitinkumar28007@gmail.com'});

                emailMessages.add(email);
            }
        }

        // Send all emails
        if (!emailMessages.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);

            for (Messaging.SendEmailResult res : results) {
                if (res.isSuccess()) {
                    System.debug('Email sent successfully.');
                } else {
                    System.debug('Failed to send email: ' + res.getErrors()[0].getMessage());
                }
            }
        }

        // Insert all created Tasks
        if (!taskList.isEmpty()) {
            insert taskList;
        }
    }

    // -----------------------------------------------------------------------------
    // Method: checkDuplicateAccount
    // Purpose: Prevents duplicate Account records from being created or updated
    //          with the same Name and Rating.
    // Trigger Context: before insert, before update
    // -----------------------------------------------------------------------------
   public static void checkDuplicateAccount(List<Account> newRecords) {
        for (Account acc : newRecords) {
            List<Account> accList = [
                SELECT Id, Name 
                FROM Account
                WHERE Name = :acc.Name AND Rating = :acc.Rating
                LIMIT 1
            ];
            if (accList != null && accList.size() > 0) {
                acc.Name.addError('Duplicate Account already exists with the same Name.');
                acc.Rating.addError('Duplicate Account already exists with the same Rating.');
            }
        }
    }

    // -----------------------------------------------------------------------------
    // Method: updateAnnualRevenue (DAY 1 : DIY 3, DAY 2 : DIY 1)
    // Purpose: Automatically sets AnnualRevenue to 2,000,000 for Accounts
    //          with Rating = 'Hot'.
    // Trigger Context: before insert, before update
    // -----------------------------------------------------------------------------
    public static void updateAnnualRevenue(List<Account> accountList) {
        for (Account acc : accountList) {
            if (acc.Rating == 'Hot' && acc.AnnualRevenue == NULL) {
                acc.AnnualRevenue = 2000000;
            }
        }
    }

    // -----------------------------------------------------------------------------
    // Method: createAccountRelatedContact (DAY 1 : DIY 1)
    // Purpose: Creates a related Contact for each Account record.
    //          - Contact LastName is set to "<Account Name> Related Contact".
    //          - Linked to the same Account via AccountId.
    // Trigger Context: after insert
    // -----------------------------------------------------------------------------
    public static void createAccountRelatedContact(List<Account> accountList) {
        List<Contact> conList = new List<Contact>();

        for (Account acc : accountList) {
            if (acc.Id != null) {
                conList.add(new Contact(
                    LastName = acc.Name + ' Related Contact',
                    AccountId = acc.Id
                ));
            }
        }

        if (!conList.isEmpty()) {
            insert conList;
        }
    }

    // -----------------------------------------------------------------------------
    // Method: deleteAllRelatedRecordToAccountAfterDeactive (DAY 1 : DIY 2, DAY 2 : DIY 2)
    // Purpose: Deletes all related Contacts and Opportunities when an Account
    //          is deactivated (Active__c changes from 'Yes' to 'No').
    // Trigger Context: after update
    // -----------------------------------------------------------------------------
      public static void deleteAllRelatedRecordToAccountAfterDeactive(List<Account> accountList,Map<Id, Account> oldAccountMap ) {

            Set<Id> accountIdSet = new Set<Id>();
        
            for (Account acc : accountList) {
                Account oldAcc = oldAccountMap.get(acc.Id);
        
                
                if (oldAcc != null &&
                    acc.Active__c != oldAcc.Active__c &&     // field changed
                    String.valueOf(oldAcc.Active__c) == 'Yes' &&
                    String.valueOf(acc.Active__c) == 'No') {
                    
                    accountIdSet.add(acc.Id);
                }
            }
        
            if (!accountIdSet.isEmpty()) {
                List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId IN :accountIdSet];
                List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE AccountId IN :accountIdSet];
        
                if (!conList.isEmpty()) delete conList;
                if (!oppList.isEmpty()) delete oppList;
            }
    }

    
    // -----------------------------------------------------------------------------
    // Method: deactivateAccountOnColdRating (DAY 2 : DIY 3)
    // Purpose: Rating is changed from Hot to cold and AnnualRevenue is 
    //			Blank then set the (Active__c changes from 'Yes' to 'No').
    // Trigger Context: before update
    // -----------------------------------------------------------------------------
	public static void deactivateAccountOnColdRating(List<Account> newList, Map<Id, Account> oldMap) {
        for (Account acc : newList) {
            Account oldRecord = oldMap.get(acc.Id);
    
            // Run only if Rating field actually changed
            if (oldRecord != null && acc.Rating != oldRecord.Rating) {
    
                
                if (oldRecord.Rating == 'Hot' && acc.Rating == 'Cold' && acc.AnnualRevenue == null) {

                    acc.Active__c = 'No';
                }
            }
        }
	}

    
    
    // -----------------------------------------------------------------------------
    // Method: preventDeletionIfRatingHot (DAY 2 : DIY 4)
    // Purpose: Cannot Delete the Account Record if its rating is Hot at the time of
    // 			Deletion.
    // Trigger Context: before delete
    // -----------------------------------------------------------------------------
    public static void preventDeletionIfRatingHot(Map<Id, Account> accountMap){
        
        for(Account record : accountMap.values()){
            if(record.Rating == 'Hot'){
                record.Rating.addError('Cannot Delete Record Whose Rating is Hot');
            }
        }
    }
    
    
    // -----------------------------------------------------------------------------
    // Method: preventDeletionIfRatingHot (DAY 2 : DIY 5)
    // Purpose: Cannot Delete the Account Record if it is has a Parent Account 
    // 			Assocoated With it.
    // Trigger Context: before delete
    // -----------------------------------------------------------------------------
	
    public static void preventDeletionIfParentAccountAssociated(Map<Id, Account> accountMap){
        
        for(Account record : accountMap.values()){
            if(record.ParentId != NULL){
                record.ParentId.addError('Cannot delete an Account that has a Parent Account associated with it.');
            }
        }
        
    }
    
	// -----------------------------------------------------------------------------
    // Method: setParentAccountOnRestore (DAY 2 : DIY 6)
    // Purpose: Whenever a deleted Account is restored (i.e., in an after undelete trigger),
  	//          we need to set one of the existing Accounts as the Parent Account on the restored Account.
    // Trigger Context: after undelete
    // -----------------------------------------------------------------------------   
     
     public static void setParentAccountOnRestore(List<Account> restoredAccounts) {
        
        
            Account parentAccount = [
                SELECT Id 
                FROM Account 
                WHERE Active__c = 'Yes' 
                LIMIT 1
            ];
            
            List<Account> accListToUpdate = new List<Account>();
        
            for (Account record : restoredAccounts) {
                
                accListToUpdate.add(
                    new Account(
                        Id = record.Id,
                        ParentId = parentAccount.Id
                    )
                );
            } 
        
            if (!accListToUpdate.isEmpty()) {
                update accListToUpdate;
            }
            
    
    }
    
    // -----------------------------------------------------------------------------
    // Method: preventAccountDeletion (Case Study : 1)
    // Purpose: Prevents users from deleting any Account record.
    // Trigger Context: before delete
    // ---------------------------------------------------------------------------
    // 
    public static void preventAccountDeletion(Map<Id, Account> accountMap) {
        
        Id sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        if (UserInfo.getProfileId() != sysAdminProfileId) {
            for (Account acc : accountMap.values()) {
                acc.addError('Only System Administrators can delete Account records.');
            }
        }
    }



    
     // -----------------------------------------------------------------------------
    // Method: createRelatedContactRecords (Case Study : 3)
    // Purpose: Create Related Contact records basd on the Number of Locations fields 
    //          value in the Account Object
    // Trigger Context: after insert, after update
    // -----------------------------------------------------------------------------
    
public static void relatedContactRecords(Map<Id, Account> newMap, Map<Id, Account> oldMap, String event) {
    
    List<Contact> conList = new List<Contact>();
    List<Contact> delList = new List<Contact>();
    
    
    // --- Switch for Trigger Events ---
    switch on event {
        
        when 'afterInsert' {
            for (Account accRec : newMap.values()) { 
                if (accRec.NumberofLocations__c != null && accRec.NumberofLocations__c > 0) {
                    Integer totalContacts = (Integer)accRec.NumberofLocations__c;
                    for (Integer i = 0; i < totalContacts; i++) {
                        conList.add(new Contact(
                            LastName = 'Contact ' + i,
                            AccountId = accRec.Id
                        ));
                    }
                }
            }
            if (!conList.isEmpty()) {
                insert conList;
            }
        }
        
        when 'afterUpdate' {
            Map<Id, Account> oldRecordMap = oldMap;
            
            for (Account accRec : newMap.values()) {
                Account oldAcc = oldRecordMap.get(accRec.Id);
                
                if (accRec.NumberofLocations__c != oldAcc.NumberofLocations__c) {
                    Integer difference = (Integer)(accRec.NumberofLocations__c - oldAcc.NumberofLocations__c);
                    
                    if (difference > 0) {
                        // Create additional contacts
                        for (Integer i = 0; i < difference; i++) {
                            conList.add(new Contact(
                                LastName = 'Contact New ' + i,
                                AccountId = accRec.Id
                            ));
                        }
                    } else if (difference < 0) {
                        // Remove extra contacts if reduced
                        Integer numToDelete = Math.abs(difference);
                        
                        // Query newest contacts to delete (DESC)
                        List<Contact> remConList = [
                            SELECT Id
                            FROM Contact
                            WHERE AccountId = :accRec.Id
                            ORDER BY CreatedDate DESC
                            LIMIT :numToDelete
                        ];
                        
                        delList.addAll(remConList);
                    }
                }
            }
            
            if (!conList.isEmpty()) {
                insert conList;
            }
            if (!delList.isEmpty()) {
                delete delList;
            }
        }
    }
}
    
    
    public static void updateRelatedContactWithPhone(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        
        List<Account> accList = new List<Account>();
        
        
        for(Account newRecord : newMap.values()){
            Account oldRecord = oldMap.get(newRecord.Id);
            if(newRecord.Phone != oldRecord.Phone){
                accList.add(newRecord);
            }
        }
        
        if(!accList.isEmpty()){
    		  String accountlistString = JSON.serialize(accList);
              AccountTriggerHelperFuture.updateAccountRelatedContactPhone(accountlistString);		
        }
    }


    

    /**
     * Updates the IsActive__c field on Contacts when their parent Account
     * changes its Type to 'Customer'.
     *
     * This method compares the new and old versions of Account records.
     * If an Account's Type changes from anything else to 'Customer',
     * all related Contacts are queried and their IsActive__c field is set to true.
     *
     * @param newMap Map of new Account records (Trigger.newMap)
     * @param oldMap Map of old Account records (Trigger.oldMap)
     */
        public static void updateIsActiveField(Map<Id, Account> newMap, Map<Id, Account> oldMap) {

            Set<Id> accIds = new Set<Id>();

            for (Account acc : newMap.values()) {
                Account oldAcc = oldMap.get(acc.Id);

                if (oldAcc.Type != 'Customer' && acc.Type == 'Customer') {
                    accIds.add(acc.Id);
                }
            }

            if (accIds.isEmpty()) {
                return;
            }

            List<Contact> conListToUpdate = new List<Contact>();

            for (Contact con : [
                SELECT Id, AccountId, IsActive__c
                FROM Contact
                WHERE AccountId IN :accIds
            ]) {
                con.IsActive__c = true;
                conListToUpdate.add(con);
            }

            if (!conListToUpdate.isEmpty()) {
                update conListToUpdate;
            }
        }

}