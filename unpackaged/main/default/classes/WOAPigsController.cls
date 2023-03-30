public class WOAPigsController {
    @AuraEnabled
    public static WOAPigs__c getWOAPigs(String recordId){
        // Get the Map of Schema of WOAPigs__c SObject
        Map<String, Schema.SObjectField> fieldMap = WOAPigs__c.sObjectType.getDescribe().fields.getMap();
                
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<WOAPigs__c> pigList = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM WOAPigs__c WHERE WOA__c =:recordId');

        WOAPigs__c pigWoa = new WOAPigs__c(WOA__c = recordId);
        if(!pigList.isEmpty()){
            pigWoa = pigList[0];
        }
        return pigWoa;

    }

    @AuraEnabled
    public static void saveWOAPigs(WOAPigs__c woaPigs){        
        if(woaPigs != null){
            WOAPigs__c woaPigRecord = woaPigs;
            if(woaPigRecord.Id == null){
                insert woaPigRecord;
            }else{
                update woaPigRecord;
            }
        }
    }
}