public with sharing class CertificatesPerSpeciesController {
    public Account currentRecord{get;set;}

    public String startDate{get;set;}
    public String endDate{get;set;}
    public String species{get;set;}
    public Map<Integer, String> monthsMap = new Map<Integer, String>{
        1  => 'January',
        2  => 'February',
        3  => 'March',
        4  => 'April',
        5  => 'May',
        6  => 'June',
        7  => 'July',
        8  => 'August',
        9  => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'
    };

    public CertificatesPerSpeciesController() {
        currentRecord = [SELECT Id, Name, Parent.Name, Membership_Number__c, Membership_Expiry_Date__c, Certificate_Issue_Date__c, Certificate_Expiry_Date_Calculated__c, BillingStreet, BillingCity, County__c, BillingCountry, BillingPostalcode FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        species = ApexPages.currentPage().getParameters().get('species');
        if(currentRecord.Certificate_Issue_Date__c != null){
            startDate = currentRecord.Certificate_Issue_Date__c.day() + ' ' + monthsMap.get(currentRecord.Certificate_Issue_Date__c.month()) + ' ' + currentRecord.Certificate_Issue_Date__c.year();
        }
        if(currentRecord.Membership_Expiry_Date__c != null){
            endDate = currentRecord.Membership_Expiry_Date__c.day() + ' ' + monthsMap.get(currentRecord.Membership_Expiry_Date__c.month()) + ' ' + currentRecord.Membership_Expiry_Date__c.year();

        }
    }
    //method to get a list of supply chain units
    public List<Unit__c> getSupplyChainUnits(){
        List<Unit__c> unitList = new List<Unit__c>();
        if(String.isNotBlank(species)){
            unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c, Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c = 'Supply Chain' AND Animals__c =:species];
        }else{
            unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c, Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c = 'Supply Chain'];
        }
        return unitList;
    }

    // Method to get a list of trout units
    public List<Unit__c> getTrouts(){
        Set<String> businessSet = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer'
        };
        List<Unit__c> troutList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c, Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSet AND Animals__c = 'Trout'];
        return troutList;
    } 

    //method to get a list of Animals Units exluding trout
    public List<Unit__c> getNSFUKASUnits(){
        Set<String> businessSet = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer',
            'Cleaner Fish',
            'Catching'
        };
        // Old query has trout and new query does not
        //List<Unit__c> unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSet AND Animals__c != 'Trout'];
        List<Unit__c> unitList = new List<Unit__c>();
        if(String.isNotBlank(species)){
            unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c,Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSet AND Animals__c =:species];
        }else{
            unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c,Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSet];
        }
        return unitList;
    }

    // This method gets the animals list for the trout certification with the word "Scheme" or "Schemes" appended to it
    public String getTroutAnimalScheme() {
        String animalsString = '';
        Set<String> animalsSet = new Set<String>();
        for(Unit__c u : getTrouts()){
            animalsSet.add(u.Animals__c);
        }
        // Converting set to list in order to the the initial value from 0
        List<String> animalsList = new List<String>(animalsSet);
        // place the first animal from the set
        if(animalsSet.size() > 0){
            animalsString = animalsList[0];
        }
        // add additonal animals to the string with concatanation
        if(animalsSet.size() > 1){
            //Commented out as the query inside geTrouts() methods is filtering animals by trout so there will only be 1 animal inside the set
            /*
            for(String animal: animalsSet){
                if(animal != animalsString){
                    animalsString = animalsString + ' and ' + animal; 
                }
            }
            // adding "Schemes" for plural animals
            animalsString = animalsString + ' Schemes';
			*/
        }else{
            // adding "Scheme" for singulr animal
            animalsString = animalsString + ' Scheme';
        }
        return animalsString;
    }

    // This method gets the animals list for the trout certification
    public String getTroutAnimals() {
        String animalsString = '';
        Set<String> animalsSet = new Set<String>();
        for(Unit__c u : getTrouts()){
            animalsSet.add(u.Animals__c);
        }
        // Converting set to list in order to the the initial value from 0
        List<String> animalsList = new List<String>(animalsSet);
        // place the first animal from the list
        if(animalsList.size() > 0){
            animalsString = animalsList[0];
        }
        // add additonal animals to the string with concatanation
        if(animalsList.size() > 1){
            //Commented out as the query inside geTrouts() methods is filtering animals by trout so there will only be 1 animal inside the set
            /*
            for(String animal: animalsList){
                if(animal != animalsString){
                    animalsString = animalsString + ' and ' + animal; 
                }
            }
			*/
        }
        return animalsString;
    }

    public String getTroutRearingSystems(){
        String rearingSystemAnimalString = '';
        Set<String> rearingSystemAnimalSet = new Set<String>();
        for(Unit__c u : getTrouts()){
            rearingSystemAnimalSet.add(u.Rearing_System__c + ' ' + u.Animals__c);
        }
        // Converting set to list in order to the the initial value from 0
        List<String> rearingSystemAnimalList = new List<String>(rearingSystemAnimalSet);
        // Place the first Rearing System Animal from the list
        if(rearingSystemAnimalList.size() > 0){
            rearingSystemAnimalString = rearingSystemAnimalList[0];
        }
        // add additional rearing system animals to the string with concatenation
        if(rearingSystemAnimalList.size() > 1){
            //Commented out as the query inside geTrouts() methods is filtering animals by trout so there will only be 1 animal inside the set
            /*
            for(String rearingAnimal : rearingSystemAnimalList){
                if(rearingAnimal != rearingSystemAnimalString){
                    rearingSystemAnimalString = rearingSystemAnimalString + ' and ' + rearingAnimal;
                }
            }
            // adding "Units" for plural animals
            rearingSystemAnimalString = rearingSystemAnimalString + ' Units';
			*/
        }else {
            // adding "Scheme" for singulr animal
            rearingSystemAnimalString = rearingSystemAnimalString + ' Unit';
        }

        return rearingSystemAnimalString;
    }
    
    // This method gets the animals list for the NSF UKAS certification with the word "Scheme" or "Schemes" appended to it
    public String getAllAnimalScheme() {
        String animalsString = '';
        Set<String> animalsSet = new Set<String>();
        for(Unit__c u : getNSFUKASUnits()){
            animalsSet.add(u.Animals__c);
        }
        // Converting set to list in order to the the initial value from 0
        List<String> animalsList = new List<String>(animalsSet);
        // place the first animal from the set
        if(animalsSet.size() > 0){
            animalsString = animalsList[0];
        }
        // add additonal animals to the string with concatanation
        if(animalsSet.size() > 1){
            for(String animal: animalsSet){
                if(animal != animalsString){
                    animalsString = animalsString + ' and ' + animal; 
                }
            }
            // adding "Schemes" for plural animals
            animalsString = animalsString + ' Schemes';
        }else{
            // adding "Scheme" for singulr animal
            animalsString = animalsString + ' Scheme';
        }
        return animalsString;
    }

    // This method gets the animals list for the NSF UKAS certification. Get's all except trouts.
    public String getAllAnimals() {
        String animalsString = '';
        Set<String> animalsSet = new Set<String>();
        for(Unit__c u : getNSFUKASUnits()){
            animalsSet.add(u.Animals__c);
        }
        // Converting set to list in order to the the initial value from 0
        List<String> animalsList = new List<String>(animalsSet);
        // place the first animal from the list
        if(animalsList.size() > 0){
            animalsString = animalsList[0];
        }
        // add additonal animals to the string with concatanation
        if(animalsList.size() > 1){
            for(String animal: animalsList){
                if(animal != animalsString){
                    animalsString = animalsString + ' and ' + animal; 
                }
            }
        }
        return animalsString;
    }

    // This method gets the rearing system for all amimals except for trout
    public String getAllAnimalRearingSystems(){
        String rearingSystemAnimalString = '';
        Set<String> rearingSystemAnimalSet = new Set<String>();
        for(Unit__c u : getNSFUKASUnits()){
            rearingSystemAnimalSet.add(u.Rearing_System__c + ' ' + u.Animals__c);
        }
        // Converting set to list in order to the the initial value from 0
        List<String> rearingSystemAnimalList = new List<String>(rearingSystemAnimalSet);
        // Place the first Rearing System Animal from the list
        if(rearingSystemAnimalList.size() > 0){
            rearingSystemAnimalString = rearingSystemAnimalList[0];
        }
        // add additional rearing system animals to the string with concatenation
        if(rearingSystemAnimalList.size() > 1){
            for(String rearingAnimal : rearingSystemAnimalList){
                if(rearingAnimal != rearingSystemAnimalString){
                    rearingSystemAnimalString = rearingSystemAnimalString + ' and ' + rearingAnimal;
                }
            }
            // adding "Units" for plural animals
            rearingSystemAnimalString = rearingSystemAnimalString + ' Units';
        }else {
            // adding "Scheme" for singulr animal
            rearingSystemAnimalString = rearingSystemAnimalString + ' Unit';
        }

        return rearingSystemAnimalString;
    }

    // get SCI Scheme Texts
    public String getSCISchemeTexts(){
        List<SchemeCertificateText__mdt> schemeTextList = SchemeCertificateText__mdt.getAll().values();
        Set<String> schemeTextSet = new Set<String>();
        for(Unit__c u : getNSFUKASUnits()){
            for(SchemeCertificateText__mdt scheme : schemeTextList){
                if(u.Business__c == 'Producer'){
                    if(u.Animals__c == scheme.Species_Type__c){
                        schemeTextSet.add(scheme.Scheme_Wording__c);
                    }
                }
                if(u.Business__c == 'Abattoir'){
                    if(u.Animals__c == 'Salmon'){
                        if(scheme.Species_Type__c == 'Salmon Abattoir'){
                            schemeTextSet.add(scheme.Scheme_Wording__c);
                        }
                    }else{
                        if(scheme.Species_Type__c == 'Abattoir'){
                            schemeTextSet.add(scheme.Scheme_Wording__c);
                        }
                    }
                }
                if(u.Business__c == 'Catching'){
                    if(scheme.Species_Type__c == 'Catching'){
                        schemeTextSet.add(scheme.Scheme_Wording__c);
                    }
                }
                if(u.Business__c == 'Hatchery'){
                    if(u.Animals__c == 'Salmon'){
                        if(scheme.Species_Type__c == 'Salmon Hatchery'){
                            schemeTextSet.add(scheme.Scheme_Wording__c);
                        }
                    }else{
                        if(scheme.Species_Type__c == 'Hatchery'){
                            schemeTextSet.add(scheme.Scheme_Wording__c);
                        }
                    }
                }
                if(u.Business__c == 'Haulier'){
                    if(u.Animals__c == 'Salmon'){
                        if(u.Vehicle_Type__c == 'Wellboat'){
                            if(scheme.Species_Type__c == 'Salmon Wellboat'){
                                schemeTextSet.add(scheme.Scheme_Wording__c);
                            }
                        }
                        if(u.Vehicle_Type__c == 'Helicopter'){
                            if(scheme.Species_Type__c == 'Salmon Helicopter'){
                                schemeTextSet.add(scheme.Scheme_Wording__c);
                            }
                        }
                    }else{
                        if(u.Own_Transport__c){
                            if(scheme.Species_Type__c == 'Own Transport'){
                                schemeTextSet.add(scheme.Scheme_Wording__c);
                            }
                        }else{
                            if(scheme.Species_Type__c == 'Haulier'){
                                schemeTextSet.add(scheme.Scheme_Wording__c);
                            }
                        }
                    }
                }
                
            }
        }

        String schemeTextString = '';

        // Converting set to list in order to the the initial value from 0
        List<String> schemeTextValuesFromSet = new List<String>(schemeTextSet);
        // place the first animal from the set
        if(schemeTextValuesFromSet.size() > 0){
            schemeTextString = schemeTextValuesFromSet[0];
        }
        
        // add additonal scheme to the string with concatanation
        if(schemeTextValuesFromSet.size() > 1){
            for(String scheme: schemeTextValuesFromSet){
                if(scheme != schemeTextString){
                    schemeTextString = schemeTextString + ' and ' + scheme; 
                }
            }
        }
        return schemeTextString;

    }

    // get SCI Scheme Texts
    public String getSCISchemeTitle(){
        List<SchemeCertificateText__mdt> schemeTextList = SchemeCertificateText__mdt.getAll().values();
        Set<String> schemeTitle = new Set<String>();
        for(Unit__c u : getNSFUKASUnits()){
            for(SchemeCertificateText__mdt scheme : schemeTextList){
                if(u.Business__c == 'Producer'){
                    if(u.Animals__c == scheme.Species_Type__c){
                        schemeTitle.add(scheme.MasterLabel);
                    }
                }
                if(u.Business__c == 'Abattoir'){
                    if(u.Animals__c == 'Salmon'){
                        if(scheme.Species_Type__c == 'Salmon Abattoir'){
                            schemeTitle.add(scheme.MasterLabel);
                        }
                    }else{
                        if(scheme.Species_Type__c == 'Abattoir'){
                            // do nothing as the Scheme title will be 'RSPCA Assured Scheme'
                        }
                    }
                }
                if(u.Business__c == 'Catching'){
                    if(scheme.Species_Type__c == 'Catching'){
                        schemeTitle.add(scheme.MasterLabel);
                    }
                }
                if(u.Business__c == 'Hatchery'){
                    if(u.Animals__c == 'Salmon'){
                        if(scheme.Species_Type__c == 'Salmon Hatchery'){
                            schemeTitle.add(scheme.MasterLabel);
                        }
                    }else{
                        if(scheme.Species_Type__c == 'Hatchery'){
                            schemeTitle.add(scheme.MasterLabel);
                        }
                    }
                }
                if(u.Business__c == 'Haulier'){
                    if(u.Animals__c == 'Salmon'){
                        if(u.Vehicle_Type__c == 'Wellboat'){
                            if(scheme.Species_Type__c == 'Salmon Wellboat'){
                                schemeTitle.add(scheme.MasterLabel);
                            }
                        }
                        if(u.Vehicle_Type__c == 'Helicopter'){
                            if(scheme.Species_Type__c == 'Salmon Helicopter'){
                                schemeTitle.add(scheme.MasterLabel);
                            }
                        }
                    }else{
                        if(u.Own_Transport__c){
                            if(scheme.Species_Type__c == 'Own Transport'){
                                schemeTitle.add(scheme.MasterLabel);
                            }
                        }else{
                            if(scheme.Species_Type__c == 'Haulier'){
                                // do nothing as the Scheme title will be 'RSPCA Assured Scheme'
                            }
                        }
                    }
                }
                
            }
        }

        String schemeTitleString = '';

        // Converting set to list in order to the the initial value from 0
        List<String> schemeTitleValuesFromSet = new List<String>(schemeTitle);
        // place the first animal from the set
        if(schemeTitleValuesFromSet.size() > 0){
            schemeTitleString = schemeTitleValuesFromSet[0];

             // add additonal scheme to the string with concatanation
            if(schemeTitleValuesFromSet.size() > 1){
                for(String scheme: schemeTitleValuesFromSet){
                    if(scheme != schemeTitleString){
                        schemeTitleString = schemeTitleString + ' and ' + scheme; 
                    }
                }
            }
        }else {
            schemeTitleString = 'Scheme';
        }
        
       
        return schemeTitleString;

    }
}