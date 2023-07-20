global class BatchToUpdateLamenessPrevalenceScore implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID,Average_Percentage_Of_Score_2_cows__c,Average_Percentage_Of_Score_3_cows__c FROM WOADairy__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<WOADairy__c> scope){
        Map<String,Decimal> score2PercentageMap = new Map<String,Decimal>();
        Map<String,Decimal> score3PercentageMap = new Map<String,Decimal>();
        
        Map<String,Integer> score2CountMap = new Map<String,Integer>();
        Map<String,Integer> score3CountMap = new Map<String,Integer>();
        
        Set<Id> woaDairySet = new Set<Id>();
        List<WOADairy__c> woaDairyToUpdate = new List<WOADairy__c>();
        
        for(Lameness_Prevalence__c LamenessPrevalence:[SELECT ID,Percentage_Of_Score_2_cows__c,Percentage_Of_Score_3_cows__c,WOADairy__C FROM Lameness_Prevalence__c WHERE WOADairy__C IN:scope]){
            if(!score2PercentageMap.containsKey(LamenessPrevalence.WOADairy__c)){
                score2PercentageMap.put(LamenessPrevalence.WOADairy__c,0);
            }
            if(!score3PercentageMap.containsKey(LamenessPrevalence.WOADairy__c)){
                score3PercentageMap.put(LamenessPrevalence.WOADairy__c,0);
            }
            if(LamenessPrevalence.Percentage_Of_Score_2_cows__c != null){
                decimal score2 = score2PercentageMap.get(LamenessPrevalence.WOADairy__c);
            	score2PercentageMap.put(LamenessPrevalence.WOADairy__c,score2+LamenessPrevalence.Percentage_Of_Score_2_cows__c);
            }
            if(LamenessPrevalence.Percentage_Of_Score_3_cows__c != null){
                decimal score3 = score3PercentageMap.get(LamenessPrevalence.WOADairy__c);
            	score3PercentageMap.put(LamenessPrevalence.WOADairy__c,score3+LamenessPrevalence.Percentage_Of_Score_3_cows__c);
            }
            
            woaDairySet.add(LamenessPrevalence.WOADairy__c);
            
            if(LamenessPrevalence.Percentage_Of_Score_2_cows__c != null){
                if(!score2CountMap.containsKey(LamenessPrevalence.WOADairy__c)){
                    score2CountMap.put(LamenessPrevalence.WOADairy__c,1);
                }else{
                    score2CountMap.put(LamenessPrevalence.WOADairy__c,1+ score2CountMap.get(LamenessPrevalence.WOADairy__c));
                }
            }
            if(LamenessPrevalence.Percentage_Of_Score_3_cows__c != null){
                if(!score3CountMap.containsKey(LamenessPrevalence.WOADairy__c)){
                    score3CountMap.put(LamenessPrevalence.WOADairy__c,1);
                }else{
                    score3CountMap.put(LamenessPrevalence.WOADairy__c,1+ score3CountMap.get(LamenessPrevalence.WOADairy__c));
                }
            }
        }
        for(Id woaDairyId:woaDairySet){
            WOADairy__c woaDairy = new WOADairy__C(Id=woaDairyId);
            if(score2PercentageMap.containsKey(woaDairyId) && score2CountMap.containsKey(woaDairyId)){
                Decimal score2 = score2PercentageMap.get(woaDairyId);
                Integer totalCount = score2CountMap.get(woaDairyId);
                woaDairy.Average_Percentage_Of_Score_2_cows__c = score2/totalCount;
            }
            if(score3PercentageMap.containsKey(woaDairyId) && score3CountMap.containsKey(woaDairyId)){
                Decimal score3 = score3PercentageMap.get(woaDairyId);
                Integer totalCount = score3CountMap.get(woaDairyId);
                woaDairy.Average_Percentage_Of_Score_3_cows__c = score3/totalCount;
            }
            woaDairyToUpdate.add(woaDairy);
        }
        update woaDairyToUpdate;

    }
    public void finish(Database.BatchableContext BC){
        
    }
}