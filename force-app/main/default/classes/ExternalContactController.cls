@RestResource(urlMapping='/ContactManagement/*')
global with sharing class ExternalContactController {
    @HttpPut
    global static void updateContacts() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String jsonBody = req.requestBody.toString();
            List<UpdateContactRequest> updateContactRequests = (List<UpdateContactRequest>)JSON.deserialize(jsonBody, List<UpdateContactRequest>.class);
            Map<Id, UpdateContactRequest> updateContactIdMap = new Map<Id, UpdateContactRequest>();
            for(UpdateContactRequest updateContactRequest : updateContactRequests) {
                if (updateContactRequest.Id == null) {
                    throw new BusinessException('Update contact must have Id');
                }
    
                updateContactIdMap.put(updateContactRequest.Id, updateContactRequest);
            }
    
            Map<Id, Contact> contactIdMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :updateContactIdMap.keySet()]);
            
            if (contactIdMap.keySet().size() < updateContactIdMap.keySet().size()) {
                List<Id> notFoundIds = new List<Id>();
                
                for(Id updateContactId: updateContactIdMap.keySet()) {
                    if (!contactIdMap.containsKey(updateContactId)) {
                        notFoundIds.add(updateContactId);
                    }
                }
    
                throw new BusinessException('There are some contacts not existing with Ids: ' + String.join(notFoundIds, ','));
            }

            List<Contact> contactToUpdates = new List<Contact>();
            for(Id updateContactId: updateContactIdMap.keySet()) {
                Contact contactToUpdate = contactIdMap.get(updateContactId);
                UpdateContactRequest updateContactRequest = updateContactIdMap.get(updateContactId);
                contactToUpdate.FirstName = updateContactRequest.FirstName;
                contactToUpdate.LastName = updateContactRequest.LastName;
                contactToUpdates.add(contactToUpdate);
            }

            update contactToUpdates;
        } catch (BusinessException businessEx) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(businessEx.getMessage());
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Internal Server Error');
        }
        
    }
}
