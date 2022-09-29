@isTest
public with sharing class TestLogManager {
    
    static final String FIELDS = 'Id, Type__c, Message__c';

    @testSetup 
    static void setup() 
    {       
        Log__c log1 = new Log__c();
        log1.Type__c = 'Undefined';
        log1.Message__c = 'Undefined event in undefined action';
        insert log1;

        Log__c log2 = new Log__c();
        log2.Type__c = 'Error';
        log2.Message__c = 'Error in action';
        insert log2;  
        
        Log__c log3 = new Log__c();
        log3.Type__c = 'Info';
        log3.Message__c = 'Something happend';
        insert log3;  
    }

    @isTest static void testGetLogsByIds(){
        List<Id> logsIds = new List<Id>();
        for (Log__c prop : [SELECT Id FROM Log__c]) {
            logsIds.add(prop.Id);
        }
        List<Log__c> resultList = LogManager.getLogsByIds(logsIds, FIELDS);
        System.assertEquals(logsIds.size(), resultList.size());
    }

    @isTest static void testGetLogsByTypes(){
        List<Log__c> propertiesIds = [SELECT Id FROM Log__c WHERE Type__c = 'Info'];
        List<String> typesList = new List<String>();
        typesList.add('Info');

        List<Log__c> resultList = LogManager.getLogsByTypes(typesList, FIELDS);
        System.assertEquals(propertiesIds.size(), resultList.size());
    }

    @isTest static void testCreateLog(){
        Log__c resultLog = LogManager.createLog('Event', 'Somewhere the event happened', true);
        Log__c resultDBLog = [SELECT Type__c FROM Log__c WHERE Id = :resultLog.Id];
        System.assertEquals('Event', resultLog.Type__c);
        System.assertEquals('Event', resultDBLog.Type__c);
    }

    @isTest static void testUpdateLogById(){
        Log__c logForUpdate = Database.query('SELECT ' + FIELDS + ' FROM Log__c WHERE Type__c = \'Undefined\'');
        Log__c resultLog = LogManager.updateLogById(logForUpdate.Id, 'Event', logForUpdate.Message__c, true);
        Log__c resultDBLog = [SELECT Type__c FROM Log__c WHERE Id = :resultLog.Id];
        System.assertEquals('Event', resultLog.Type__c);
        System.assertEquals('Event', resultDBLog.Type__c);
    }

    @isTest static void testDeleteLogsByTypes(){
        List<String> typesList = new List<String>();
        typesList.add('Error');

        LogManager.deleteLogsByTypes(typesList);
        List<Log__c> resultDBLogs = [SELECT Id FROM Log__c WHERE Type__c = 'Error'];
        System.assertEquals(0, resultDBLogs.size());
    }
}
