public inherited sharing class PropertyManager {

    public class PropertyWrapper{
        public Id id {get; set;}
        public String address {get; set;}
        public Id propertyOwner {get; set;}
        public Decimal rentalPrice {get; set;}
        public Decimal sellingPrice {get; set;}
    }

    public static List<Property__c> getPropertiesByIds(List<Id> ids, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Property__c WHERE Id IN :ids');
    }

    public static List<Property__c> getPropertiesByAddresses(List<String> addresses, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Property__c WHERE Address__c IN :addresses');
    }

    public static List<Property__c> getPropertiesByOwners(List<Id> ownersIds, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Property__c WHERE Owner__c IN :ownersIds');
    }

    public static Property__c createProperty(PropertyWrapper wrapper, Boolean serialize) {
        Property__c property = new Property__c();

        property.Address__c = wrapper.address;
        property.Property_Owner__c = wrapper.propertyOwner;
        property.Rental_price_per_month__c = wrapper.rentalPrice;
        property.Selling_price__c = wrapper.sellingPrice;

        if (serialize) insert property;

        return property;
    }

    public static Property__c updatePropertyById(PropertyWrapper wrapper, Boolean serialize) {
        Property__c propertyToUpdate = [SELECT Address__c, Property_Owner__c, Rental_price_per_month__c,
                                            Selling_price__c FROM Property__c WHERE Id = :wrapper.id];
        
        propertyToUpdate.Address__c = wrapper.address;
        propertyToUpdate.Property_Owner__c = wrapper.propertyOwner;
        propertyToUpdate.Rental_price_per_month__c = wrapper.rentalPrice;
        propertyToUpdate.Selling_price__c = wrapper.sellingPrice;

        if (serialize) update propertyToUpdate;

        return propertyToUpdate;
    }
    
    public static void deletePropertiesByAddresses(List<String> addresses) {
        delete [SELECT Id FROM Property__c WHERE Address__c IN :addresses];
    }

    public static void deletePropertiesByOwnersIds(List<Id> ownersIds) {
        delete [SELECT Id FROM Property__c WHERE Property_Owner__c IN :ownersIds];
    }
}