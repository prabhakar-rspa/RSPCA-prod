public class GenerateWOA {
    public static void generate(Map<Id,Application__c> newMap, Map<Id,Application__c> oldMap, Boolean skipStageChange){

        Set<Id> appsChangedToAssessment = new Set<Id>();
        for(Application__c app : newMap.values()){
            // for applications
            if(app.Stage__c == 'Assessment' && (oldMap.get(app.Id).Stage__c != 'Assessment' || skipStageChange)){
                appsChangedToAssessment.add(app.Id);
            }
            // for renewal applications
            if(app.Renewal_Stage__c == 'Assessment' && (oldMap.get(app.Id).Renewal_Stage__c != 'Assessment' || skipStageChange)){
                appsChangedToAssessment.add(app.Id);
            }
        }

        // if there are apps in assessment
        if(!appsChangedToAssessment.isEmpty()){
            // for the apps changed to assessmetn query application units and check existing WOA
            Map<Id, List<WOA__c>> appIdToWOAList = getWOAForApplicationsID(appsChangedToAssessment);
            Map<Id, List<Application_Unit__c>> appIdToAppUnits = getAppUnitForApplicationsID(appsChangedToAssessment);

            List<WOA__c> listOfWOAToCreate = new List<WOA__c>();

            for(Id appId : appsChangedToAssessment){
                Application__c app = newMap.get(appId);
                List<Application_Unit__c> appUnitList = appIdToAppUnits.get(appId);
                if(appUnitList != null){
                    List<WOA__c> woaList = appIdToWOAList.get(appId);
                    Map<String, WOA__c> speciesStringWoaMap = new Map<String, WOA__c>();
                    for(Application_Unit__c au : appUnitList){
                        Boolean alreadyExists = false;
                        WOA__c newWOA = new WOA__c();
                        newWOA.Application__c = app.Id;
                        // assign assessor
                        if(app.Assessor__c != null){
                            newWOA.Assessor__c = app.Assessor__c;
                        }
                        

                        // select species
                        if(au.Animals__c == 'Laying Hens'){
                            newWOA.Species_Type__c = 'Laying Hen';
                        }else if(au.Animals__c == 'Pigs'){
                            newWOA.Species_Type__c = 'Pigs';
                        }
                        else if(au.Animals__c == 'Dairy Cattle'){
                            newWOA.Species_Type__c = 'Dairy Cattle';
                        }
                        
                        if(woaList != null){
                            for(WOA__c existingWoa : woaList){
                                if(existingWoa.Species_Type__c == newWOA.Species_Type__c){
                                    alreadyExists = true;
                                }
                            }
                        }
                        

                        if(!alreadyExists && !speciesStringWoaMap.containsKey(newWOA.Species_Type__c)){
                            speciesStringWoaMap.put(newWOA.Species_Type__c, newWOA);
                        }
                    }

                     // add list to create
                    for(WOA__c woa : speciesStringWoaMap.values()){
                        listOfWOAToCreate.add(woa);
                    }
                }
                

               
            }

            if(!listOfWOAToCreate.isEmpty()){
                insert listOfWOAToCreate;
            }
        }
        
    }

    private static Map<Id, List<WOA__c>> getWOAForApplicationsID(Set<Id> appIdSet){
        Map<Id, List<WOA__c>> appIdToWOAList = new  Map<Id, List<WOA__c>>();
        for(WOA__c woa : [SELECT Id, Application__c, Species_Type__c FROM WOA__c WHERE Application__c IN: appIdSet]){
            if(appIdToWOAList.containsKey(woa.Application__c)){
                List<WOA__c> woaList = appIdToWOAList.get(woa.Application__c);
                woaList.add(woa);
                appIdToWOAList.put(woa.Application__c, woaList);
            }else{
                appIdToWOAList.put(woa.Application__c, new List<WOA__c>{ woa });
            }
        }
        return appIdToWOAList;
    }

    private static Map<Id, List<Application_Unit__c>> getAppUnitForApplicationsID(Set<Id> appIdSet){
        //List<String> woaAnimals = new list<String> { 'Laying Hens' , 'Pigs' , 'Dairy Cattle' };
        List<String> woaAnimals = new list<String> { 'Laying Hens' , 'Pigs'};
        Map<Id, List<Application_Unit__c>> appIdToAppUnits = new  Map<Id, List<Application_Unit__c>>();
        for(Application_Unit__c au : [SELECT Id, Business__c, Animals__c, Application__c FROM Application_Unit__c WHERE Application__c IN: appIdSet AND Animals__c IN:woaAnimals AND Business__c = 'Producer']){
            if(appIdToAppUnits.containsKey(au.Application__c)){
                List<Application_Unit__c> auList = appIdToAppUnits.get(au.Application__c);
                auList.add(au);
                appIdToAppUnits.put(au.Application__c, auList);
            }else{
                appIdToAppUnits.put(au.Application__c, new List<Application_Unit__c>{ au });
            }
        }
        return appIdToAppUnits;
    }
}