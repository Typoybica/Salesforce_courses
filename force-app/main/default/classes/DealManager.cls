public inherited sharing class DealManager {
    
    public static final String DEFAULT_STATUS = 'Open';
    public static final Id DEAL_LEASE_TYPE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Lease').getRecordTypeId();

    public class DealWrapper{
        public Id id {get; set;}
        public Id buyer {get; set;}
        public Id propertyForSale {get; set;}
        public Id salesman {get; set;}
        public String status {get; set;}
        public Id recordTypeId {get; set;}
        public Date leaseStartDate {get; set;}
        public Date leaseEndDate {get; set;}
    }
    
    public static List<Deal__c> getDealsByIds(List<Id> ids, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Deal__c WHERE Id IN :ids');
    }
    
    public static List<Deal__c> getDealsBySalesmans(List<Id> salesmans, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Deal__c WHERE Salesman__c IN :salesmans');
    }
    
    public static List<Deal__c> getDealsByBuyers(List<Id> buyers, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Deal__c WHERE Buyer__c IN :buyers');
    }
    
    public static List<Deal__c> getDealsByStatuses(List<String> statuses, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Deal__c WHERE Status__c IN :statuses');
    }

    public static Deal__c createDeal(DealWrapper wrapper, Boolean serialize) {
        Deal__c deal = new Deal__c();

        deal.Buyer__c = wrapper.buyer;
        deal.Property_for_sale__c = wrapper.propertyForSale;
        deal.Salesman__c = wrapper.salesman;
        deal.Status__c = String.isBlank(wrapper.status) ? DEFAULT_STATUS : wrapper.status;
        deal.RecordTypeId = wrapper.recordTypeId;
        if (deal.RecordTypeId == DEAL_LEASE_TYPE) {
            deal.Rental_start_date__c = wrapper.leaseStartDate;
            deal.Rental_end_date__c = wrapper.leaseEndDate;
        }

        if (serialize) insert deal;

        return deal;
    }


    public static Deal__c updateDealsById(DealWrapper wrapper, Boolean serialize) {
        Deal__c dealToUpdate = [SELECT Buyer__c, Property_for_sale__c, Salesman__c,
                                            Status__c, RecordTypeId, Rental_start_date__c, 
                                            Rental_end_date__c FROM Deal__c WHERE Id = :wrapper.id];
        
        dealToUpdate.Buyer__c = wrapper.buyer;
        dealToUpdate.Property_for_sale__c = wrapper.propertyForSale;
        dealToUpdate.Salesman__c = wrapper.salesman;
        dealToUpdate.Status__c = String.isBlank(wrapper.status) ? DEFAULT_STATUS : wrapper.status;
        dealToUpdate.RecordTypeId = wrapper.recordTypeId;
        if (dealToUpdate.RecordTypeId == DEAL_LEASE_TYPE) {
            dealToUpdate.Rental_start_date__c = wrapper.leaseStartDate;
            dealToUpdate.Rental_end_date__c = wrapper.leaseEndDate;
        }

        if (serialize) update dealToUpdate;

        return dealToUpdate;
    }

    public static void deleteDealsByStatuses(List<String> statuses) {
        delete [SELECT Id FROM Deal__c WHERE Status__c IN :statuses];
    }
}