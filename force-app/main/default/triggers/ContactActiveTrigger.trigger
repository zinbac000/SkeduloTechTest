trigger ContactActiveTrigger on Contact (after update) {
    List<Account> accountToUpdates = new List<Account>();
    for (Contact updatedActiveContact : [SELECT Id, Account.Id, Account.Total_Contacts__c FROM Contact WHERE Active__c = TRUE AND Id IN :Trigger.new]) {
        Account accountToUpdate = updatedActiveContact.Account;
        accountToUpdate.Total_Contacts__c = accountToUpdate.Total_Contacts__c == null ? 1 : accountToUpdate.Total_Contacts__c + 1;
        accountToUpdates.add(accountToUpdate);
    }

    update accountToUpdates;
}