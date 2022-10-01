public with sharing class DealTriggerHandler extends TriggerHandler {

    static final String RECORD_TYPE_SALE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Sale').getRecordTypeId();
    static final String STATUS_CW = 'Closed Won';
    static final String STATUS_CL = 'Closed Lost';
    static final String STATUS_OPEN = 'Open';
    static final String STATUS_AA = 'Awaiting Approval';

    List<Id> propertiesIdList= new List<Id>();
    List<Deal__c> dealToUpdateList = new List<Deal__c>();
    
    public override void afterUpdate() {
        List<Deal__c> opps = [SELECT Id, Status__c, RecordTypeId, Property_for_sale__c
                                FROM Deal__c WHERE Id IN :Trigger.newMap.keySet()];
    
        for(Deal__c deal : opps) {
            if(deal.Status__c == STATUS_CW && deal.RecordTypeId == RECORD_TYPE_SALE) {
                propertiesIdList.add(deal.Property_for_sale__c);
            }
        }

        List<Deal__c> relatedDeals = [SELECT Id, RecordTypeId, Status__c FROM Deal__c WHERE Property_for_sale__c IN :propertiesIdList];

        for (Deal__c deal : relatedDeals)
        {
            if(deal.RecordTypeId == RECORD_TYPE_SALE && 
                           (deal.Status__c == STATUS_OPEN || deal.Status__c == STATUS_AA)) {
                deal.Status__c = STATUS_CL;
                dealToUpdateList.add(deal);
            }
        }

        update dealToUpdateList;
    }
}
