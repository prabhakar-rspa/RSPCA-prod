trigger PaymentTrigger on asp04__Payment__c (after update) {
    
    if(trigger.isAfter && trigger.isUpdate){
        Map<Id, Application__c> appToUpdate = new Map<Id, Application__c>();
        
        for(asp04__Payment__c pay : Trigger.new){
            if(pay.Application__c != null && pay.asp04__Amount__c > 0 && pay.asp04__Payment_Route_Selected__c == 'Card' && pay.asp04__Payment_Stage__c == 'Collected from customer'){
                System.debug('Application => ' + pay.Application__c);
                System.debug('Amount => ' + pay.asp04__Amount__c);
                System.debug('Payment Route => ' + pay.asp04__Payment_Route_Selected__c);
                System.debug('Payment Stage => ' + pay.asp04__Payment_Stage__c);
                if(!appToUpdate.containsKey(pay.Application__c)){
                    appToUpdate.put(pay.Application__c, new Application__c(Id=pay.Application__c));
                }
            }
        }
        
        List<AggregateResult> aggResult = new List<AggregateResult>();
        
        aggResult = [SELECT Application__c, SUM(asp04__Amount__c)total FROM asp04__Payment__c WHERE Application__c IN :appToUpdate.keySet() GROUP BY Application__c];
        
        for(AggregateResult ar : aggResult){
            Id appId = (ID)ar.get('Application__c');
            if(appToUpdate.containsKey(appId)){
                Application__c a = appToUpdate.get(appId);
                decimal totalPaid = (decimal)ar.get('total');
                a.Payment_Amount_Received_Card__c  = totalPaid;
                appToUpdate.put(appId , a);
            }
        }
        
        /* Update the value in the Map. values() method returns the list of records */
    
        update appToUpdate.values();
        
    }

}