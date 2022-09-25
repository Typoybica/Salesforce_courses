public inherited sharing class ContactManager {
    
    public static final Id DEFAULT_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName()
                                                .get('Broker').getRecordTypeId();
    
    public class ContactWrapper{
        public Id id {get; set;}
        public Id recordTypeId {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String phone {get; set;}
        public String email {get; set;}
    }

    public static List<Contact> getContactsByIds(List<Id> ids, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Contact WHERE Id IN :ids');
    }
    
    public static List<Contact> getContactsByRecordTypes(List<String> recordTypes, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Contact WHERE RecordType.name IN :recordTypes');
    }    

    public static Contact createContact(ContactWrapper wrapper, Boolean serialize) {
        Contact contact = new Contact();

        contact.RecordTypeId = String.isBlank(wrapper.recordTypeId) ? DEFAULT_TYPE : wrapper.recordTypeId;
        contact.FirstName = wrapper.firstName;
        contact.LastName = wrapper.lastName;
        contact.Phone = wrapper.phone;
        contact.Email = wrapper.email;

        if (serialize) insert contact;

        return contact;
    }

    public static Contact updateContactById(ContactWrapper wrapper, Boolean serialize) {
        Contact contactToUpdate = [SELECT FirstName, LastName, Phone, Email FROM Contact WHERE Id = :wrapper.id];

        contactToUpdate.FirstName = wrapper.firstName;
        contactToUpdate.LastName = wrapper.lastName;
        contactToUpdate.Phone = wrapper.phone;
        contactToUpdate.Email = wrapper.email;

        if (serialize) update contactToUpdate;

        return contactToUpdate;
    }

    public static void deleteContactsByEmails(List<String> emails) {
        delete [SELECT Id FROM Contact WHERE Email IN :emails];
    }
}