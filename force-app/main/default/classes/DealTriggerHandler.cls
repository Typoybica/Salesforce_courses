public with sharing class DealTriggerHandler extends TriggerHandler {

    static final String RECORD_TYPE_SALE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Sale').getRecordTypeId();
    static final String STATUS_CW = 'Closed Won';
    static final String STATUS_CL = 'Closed Lost';
    static final String STATUS_OPEN = 'Open';
    static final String STATUS_AA = 'Awaiting Approval';

    List<Property__c> propertiesIdList= new List<Property__c>();
    List<Deal__c> dealToUpdateList = new List<Deal__c>();

    public override void afterUpdate() {
        for(Deal__c deal : (List<Deal__c>)Trigger.new) {
            if(deal.Status__c == STATUS_CW && deal.RecordTypeId == RECORD_TYPE_SALE) {
                propertiesIdList.add(deal.Property_for_sale__r);
            }
        }

        List<Property__c> props = [SELECT Id FROM Property__c WHERE Id IN :propertiesIdList];
        for(Property__c prop : props) {
            for (Deal__c deal : prop.Deals__r)
            {
                if(deal.RecordTypeId == RECORD_TYPE_SALE && 
                                (deal.Status__c == STATUS_OPEN || deal.Status__c == STATUS_AA)) {
                    deal.Status__c = STATUS_CL;
                    dealToUpdateList.add(deal);
                }
            }
        }
        update dealToUpdateList;
    }
}
