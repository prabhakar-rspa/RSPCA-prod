public with sharing class BatchToUpdateMultipleAnimals implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> businessList = new List<String>{
            'Hatchery','Abattoir','Haulier','Catching'
        };
        String query = 'SELECT ID,Animals__c,Animals_List__c,Business__c,Description__c FROM Unit__c where Business__c IN :businessList';
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext BC, List<Unit__c> scope){
        Map<String,String> animalsMap = new Map<String,String>{
            'Beef'=>'Beef Cattle','Cattle'=>'Beef Cattle','Calves'=>'Veal Calves','Chickens'=>'Chickens','Chicks'=>'Meat Chicken Chicks',
            'Pigs'=>'Pigs','Poults'=>'Turkey Poults','Sheep'=>'Sheep','Spent Hens'=>'Laying Hens','Turkeys'=>'Turkeys'
        };
       for(Unit__c unit : scope){
           system.debug('unit.Animals_List__c'+unit.Animals_List__c);
           if(unit.Animals_List__c != null && unit.Animals_List__c.contains('List')){
               unit.Animals_List__c = unit.Animals_List__c.replace('List','');
           }
           if((unit.Business__c == 'Catching' || unit.Business__c == 'Hatchery') || unit.Description__c == null){
               if(unit.Animals__c != 'List'){
                   if(unit.Animals_List__c == NULL){
                       unit.Animals_List__c = unit.Animals__c;
                   }else if(!unit.Animals_List__c.contains(unit.Animals__c)){
                       unit.Animals_List__c = unit.Animals_List__c +';'+unit.Animals__c;
                   }  
               }
                
               unit.Animals__c = 'List';
           }else if(unit.Description__c != null){               
               String description = unit.Description__c;
               system.debug('description:::'+description);
               //String animals = description.substringBetween('(',')');
               Integer firstIndex = description.indexOf('(');
               Integer lastIndex = description.lastIndexOf(')');
               system.debug('first index'+firstIndex);
               system.debug('last index'+lastIndex);
               if(description.contains('(') && description.contains(')')){
                   String animals = description.substring(firstIndex-1,lastIndex);
                   animals = animals.replace(')',',');
                   animals = animals.replace('(','');
                   system.debug('animals:::'+animals);
                   if(String.isNotBlank(animals)){
                       List<String> animalsList = animals.split(',');
                       List<String> newAnimalsList = new List<String>();
                       system.debug('animalsList:::'+animalsList);
                       for(String animal:animalsList){
                           animal = animal.trim();
                           if(animalsMap.containsKey(animal) && newAnimalsList.indexOf(animal) == -1){
                               newAnimalsList.add(animalsMap.get(animal));
                           }/*else if(animal != 'Cattle'){
                            newAnimalsList.add(animal);
                            }*/
                       }
                       system.debug('newAnimalsList:::'+newAnimalsList);
                       unit.Animals_List__c = String.join(newAnimalsList,';');
                       if(!unit.Animals_List__c.contains(unit.Animals__c) && unit.Animals__c != 'List'){
                           unit.Animals_List__c += ';'+unit.Animals__c;
                       }  
                       unit.Animals__c ='List';
                       unit.Description__c = description.substringBefore('(');    
                   }
                   
               }else if(unit.Animals__c != null && unit.Animals__c != 'List'){
                   if(unit.Animals_List__c == NULL){
                       unit.Animals_List__c = unit.Animals__c;
                   }else if(!unit.Animals_List__c.contains(unit.Animals__c)){
                       unit.Animals_List__c = unit.Animals_List__c +';'+unit.Animals__c;
                   }   
                   unit.Animals__c = 'List';
               }
           }
       }
       system.debug('scope::::'+scope);
       update scope;
    }
  
    public void finish(Database.BatchableContext BC){
        
    }
}