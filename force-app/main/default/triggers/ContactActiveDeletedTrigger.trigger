trigger ContactActiveDeletedTrigger on Contact (after delete) {
    List<Account> accountToUpdates = new List<Account>();
    List<Id> accountIds = new List<Id>();
    for(Contact contact : Trigger.old) {
        if (contact.Active__c) {
            accountIds.add(contact.AccountId);
        }
    }

    for(Account accountToUpdate : [SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :accountIds]) {
        accountToUpdate.Total_Contacts__c = accountToUpdate.Total_Contacts__c - 1;
        accountToUpdates.add(accountToUpdate);
    }

    update accountToUpdates;
}