public with sharing class ContactJsonTriggerHandler {

    // When a contact is inserted
	// if DummyJSON_Id__c is null, generate a random number between 0 and 100 and set this as the contact's DummyJSON_Id__c value

    public static void handleContact(List<Contact> newContacts) {
       
        List<Contact> contactsToUpdate = new List<Contact>();

        If(Trigger.isBefore) {
            for (Contact cont : newContacts) {
                if (cont.DummyJSON_Id__c == null) {
                    cont.DummyJSON_Id__c = String.valueOf((Integer) Math.floor(Math.Random() * 101));
                }
            }
        }
        // if DummyJSON_Id__c is less than or equal to 100, call the getDummyJSONUserFromId API
         else if(Trigger.isAfter) {
            List<Id> contactIdsForCallout = new List<Id>();
            for(Contact cont : newContacts) {
                if(cont.DummyJSON_Id__c != null && Decimal.valueOf(cont.DummyJSON_id__c) <= 100) {
                    contactIdsForCallout.add(cont.Id);
                }
            }

            if(!contactIdsForCallout.isEmpty()) {
                makeCalloutForContacts(contactIdsForCallout);
            }
         }    
    } 

    @future(callout=true)
    private static void makeCalloutForContacts(List<Id> contactIds) {
        for(Id contactId : contactIds) {
            DummyJSONCallout.getDummyJSONUserFromId(contactId);
        }
    }

	//When a contact is updated
	// if DummyJSON_Id__c is greater than 100, call the postCreateDummyJSONUser API
    public static void handleContactUpdate(List<Contact> updatedContacts) {
        List<Id> contactIdsForPost = new List<Id>();

        for ( Contact cont : updatedContacts) {
            if (cont.DummyJSON_Id__c != null && Integer.valueOf(cont.DummyJSON_Id__c) > 100) {
                contactIdsForPost.add(cont.Id);
            }
        }

        if (!contactIdsForPost.isEmpty()) {
            makePostCalloutForContacts(contactIdsForPost);
        }
    }

    @future(callout=true)
    private static void makePostCalloutForContacts(List<Id> contactIds) {
        for(Id contactId : contactIds) {
            DummyJSONCallout.postCreateDummyJSONUser(contactId);
        }
    }
}