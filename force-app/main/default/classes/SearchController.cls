global with sharing class SearchController {
    public string Keyword {get;set;}

    public SearchController() {
        Keyword = '';
    }
    
    public List<SearchResult> getSearchResults() {
        String searchKeyword = Keyword + '%';
        List<SearchResult> searchResults = new List<SearchResult>();
        List<Contact> searchContacts = [SELECT Id, Name, Counter__c FROM Contact WHERE Name LIKE :searchKeyword];
        List<Account> searchAccounts = [SELECT Id, Name, Counter__c FROM Account WHERE Name LIKE :searchKeyword];

        for(Contact contact: searchContacts) {
            SearchResult searchResult = new SearchResult();
            searchResult.RecordId = contact.Id;
            searchResult.RecordName = contact.Name;
            searchResult.RecordType = 'Contact';
            searchResult.Counter = contact.Counter__c == null ? 0 : contact.Counter__c;
            searchResults.add(searchResult);
        }

        for(Account account: searchAccounts) {
            SearchResult searchResult = new SearchResult();
            searchResult.RecordId = account.Id;
            searchResult.RecordName = account.Name;
            searchResult.RecordType = 'Account';
            searchResult.Counter = account.Counter__c == null ? 0 : account.Counter__c;
            searchResults.add(searchResult);
        }

        return searchResults;
    }

    @RemoteAction
    global static Double incrementCounter(Id id, String recordType) {
        switch on recordType {
            when 'Contact' {
                List<Contact> contacts = [SELECT Id, Counter__c FROM Contact WHERE Id = :id];
                Contact contactToUpdate = contacts[0];
                contactToUpdate.Counter__c = contactToUpdate.Counter__c == null ? 1 : contactToUpdate.Counter__c + 1;
                update contactToUpdate;
                return contactToUpdate.Counter__c;
            }
            when else {
                List<Account> accounts = [SELECT Id, Counter__c FROM Account WHERE Id = :id];
                if (accounts.size() == 0) {
                    return 0;
                }
                Account accountToUpdate = accounts[0];
                accountToUpdate.Counter__c = accountToUpdate.Counter__c == null ? 1 : accountToUpdate.Counter__c + 1;
                update accountToUpdate;
                return accountToUpdate.Counter__c;
            }
        }
    }
}
