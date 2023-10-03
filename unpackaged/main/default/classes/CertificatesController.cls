public class CertificatesController {
    public Account currentRecord{get;set;}
    public Checklist_Template__c chechlistTemplateRecord{get;set;}
    public Application_Unit__c ApplicationUnitRecord{get;set;}
    public String startDate{get;set;}
    public String endDate{get;set;}
    public String species{ get; set; }


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

    public CertificatesController() {
        currentRecord = [SELECT Id, Name, Parent.Name, Membership_Number__c, Membership_Expiry_Date__c, Certificate_Issue_Date__c, Previous_Assessment_Date__c, Certificate_Expiry_Date_Calculated__c, BillingStreet, BillingCity, County__c, BillingCountry, BillingPostalcode
                         FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
        species = ApexPages.currentPage().getParameters().get('species');
        System.debug('species '+species);
        // Getting Application records based on Account Records
        System.debug('App Unit '+[SELECT Id,Name,Application__c,Application__r.Name,Application__r.Stage__c,Application__r.Assessment_Approved_By_Assessor_Date__c,Application__r.Assessment_Date__c, Application__r.Previous_Assessment_Date__c,Application__r.Site__c, Application__r.Site__r.Name,Application__r.Status__c,Animals__c FROM Application_Unit__c]);
        ApplicationUnitRecord = [SELECT Id,Name,Application__c,Application__r.Name,Application__r.Stage__c,Application__r.Assessment_Approved_By_Assessor_Date__c,Application__r.Assessment_Date__c, Application__r.Previous_Assessment_Date__c,Application__r.Site__c, Application__r.Site__r.Name,Application__r.Status__c,Animals__c FROM Application_Unit__c WHERE Application__r.Site__c =:ApexPages.currentPage().getParameters().get('id') AND Application__r.Assessment_Approved_By_Certifier_Date__c != NULL AND Animals__c =:species ORDER BY Application__r.Name DESC LIMIT 1];
        
		
        // Getting Checklist Template Record based on Renewal Date and Species.
        List<Checklist_Template__c> chechlistTemplateList = [SELECT Id, Name, Type__c, Species__c, Status__c, Animals_List__c, Start_Date__c, End_Date__c, Scheme_Wording__c
                                                             FROM Checklist_Template__c WHERE Species__c = :species];

        System.debug('chechlistTemplateList '+chechlistTemplateList);
        for(Checklist_Template__c objCT: chechlistTemplateList){
            System.debug('objCT.Start_Date__c '+objCT.Start_Date__c);
            System.debug('objCT.End_Date__c '+objCT.End_Date__c);
            if(ApplicationUnitRecord.Application__r.Assessment_Date__c >= objCT.Start_Date__c && ApplicationUnitRecord.Application__r.Assessment_Date__c <= objCT.End_Date__c){
                chechlistTemplateRecord = objCT;
            }
        }                            

        if(currentRecord.Certificate_Issue_Date__c != null){
            startDate = currentRecord.Certificate_Issue_Date__c.day() + ' ' + monthsMap.get(currentRecord.Certificate_Issue_Date__c.month()) + ' ' + currentRecord.Certificate_Issue_Date__c.year();
        }
        if(currentRecord.Membership_Expiry_Date__c != null){
            endDate = currentRecord.Membership_Expiry_Date__c.day() + ' ' + monthsMap.get(currentRecord.Membership_Expiry_Date__c.month()) + ' ' + currentRecord.Membership_Expiry_Date__c.year();
        }
    }
    //method to get a list of supply chain units
    public List<Unit__c> getSupplyChainUnits(){
        List<Unit__c> unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c, Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c = 'Supply Chain'];
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
        List<Unit__c> unitList = [SELECT Id, Name, Account__c, Business__c, Description__c, Animals__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c,Vehicle_Type__c, Own_Transport__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSet];
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
    // Updated the logic based on Checklist Template record
    public String getSCISchemeTexts(){
        
        Set<String> checklistTextSet = new Set<String>();
        if(chechlistTemplateRecord != null){
            for (Unit__c u : getNSFUKASUnits()){
                if (u.Business__c == 'Producer'){
                    if (u.Animals__c == chechlistTemplateRecord.Species__c){
                        checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                    }
                }
                if (u.Business__c == 'Abattoir'){
                    if (u.Animals__c == 'Salmon'){
                        if (chechlistTemplateRecord.Species__c == 'Salmon'){
                            checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                        }
                    } else{
                        if (chechlistTemplateRecord.Species__c == 'Abattoir'){
                            checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                        }
                    }
                }
                if (u.Business__c == 'Catching'){
                    if (chechlistTemplateRecord.Species__c == 'Catching'){
                        checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                    }
                }
                if (u.Business__c == 'Hatchery'){
                    if (u.Animals__c == 'Salmon'){
                        if (chechlistTemplateRecord.Species__c == 'Salmon'){
                            checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                        }
                    } else{
                        if (chechlistTemplateRecord.Species__c == 'Hatchery'){
                            checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                        }
                    }
                }
                if (u.Business__c == 'Haulier'){
                    if (u.Animals__c == 'Salmon'){
                        if (u.Vehicle_Type__c == 'Wellboat'){
                            if (chechlistTemplateRecord.Species__c == 'Salmon'){
                                checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                            }
                        }
                        if (u.Vehicle_Type__c == 'Helicopter'){
                            if (chechlistTemplateRecord.Species__c == 'Salmon'){
                                checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                            }
                        }
                    } else{
                        if (u.Own_Transport__c){
                            if (chechlistTemplateRecord.Species__c == 'Own Transport'){
                                checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                            }
                        } else{
                            if (chechlistTemplateRecord.Species__c == 'Haulier'){
                                checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
                            }
                        }
                    }
                }
            }
            if(checklistTextSet.size() == 0 && chechlistTemplateRecord.Scheme_Wording__c != null){
                checklistTextSet.add(chechlistTemplateRecord.Scheme_Wording__c);
            }
        }
        String checklistTextString = '';
        
        // Converting set to list in order to the the initial value from 0
        List<String> checklistTextValuesFromSet = new List<String>(checklistTextSet);
        // place the first animal from the set
        if (checklistTextValuesFromSet.size() > 0){
            checklistTextString = checklistTextValuesFromSet[0];
        }
        
        // add additonal scheme to the string with concatanation
        if (checklistTextValuesFromSet.size() > 1){
            for (String scheme : checklistTextValuesFromSet){
                if (scheme != checklistTextString){
                    checklistTextString = checklistTextString + ' and ' + scheme;
                }
            }
        }
        return checklistTextString;
    }
    
    // get SCI Scheme Texts
    // Updated the logic based on Checklist Template record
    public String getSCISchemeTitle(){
        Set<String> checklistTitle = new Set<String>();
        if(chechlistTemplateRecord != null){
            for (Unit__c u : getNSFUKASUnits()){
                if (u.Business__c == 'Producer'){
                    if (u.Animals__c == chechlistTemplateRecord.Species__c){
                        checklistTitle.add(chechlistTemplateRecord.Name);
                    }
                }
                if (u.Business__c == 'Abattoir'){
                    if (u.Animals__c == 'Salmon'){
                        if (chechlistTemplateRecord.Species__c == 'Salmon'){
                            checklistTitle.add(chechlistTemplateRecord.Name);
                        }
                    } else{
                        if (chechlistTemplateRecord.Species__c == 'Abattoir'){
                            // do nothing as the Scheme title will be 'RSPCA Assured Scheme'
                        }
                    }
                }
                if (u.Business__c == 'Catching'){
                    if (chechlistTemplateRecord.Species__c == 'Catching'){
                        checklistTitle.add(chechlistTemplateRecord.Name);
                    }
                }
                if (u.Business__c == 'Hatchery'){
                    if (u.Animals__c == 'Salmon'){
                        if (chechlistTemplateRecord.Species__c == 'Salmon'){
                            checklistTitle.add(chechlistTemplateRecord.Name);
                        }
                    } else{
                        if (chechlistTemplateRecord.Species__c == 'Hatchery'){
                            checklistTitle.add(chechlistTemplateRecord.Name);
                        }
                    }
                }
                if (u.Business__c == 'Haulier'){
                    if (u.Animals__c == 'Salmon'){
                        if (u.Vehicle_Type__c == 'Wellboat'){
                            if (chechlistTemplateRecord.Species__c == 'Salmon'){
                                checklistTitle.add(chechlistTemplateRecord.Name);
                            }
                        }
                        if (u.Vehicle_Type__c == 'Helicopter'){
                            if (chechlistTemplateRecord.Species__c == 'Salmon'){
                                checklistTitle.add(chechlistTemplateRecord.Name);
                            }
                        }
                    } else{
                        if (u.Own_Transport__c){
                            if (chechlistTemplateRecord.Species__c == 'Own Transport'){
                                checklistTitle.add(chechlistTemplateRecord.Name);
                            }
                        } else{
                            if (chechlistTemplateRecord.Species__c == 'Haulier'){
                                // do nothing as the Scheme title will be 'RSPCA Assured Scheme'
                            }
                        }
                    }
                }
            }
            if(checklistTitle.size() == 0 && chechlistTemplateRecord.Name != null){
                checklistTitle.add(chechlistTemplateRecord.Name);   
            }
        }
        System.debug('checklistTitle ' + checklistTitle);
        String checklistTitleString = '';
        
        // Converting set to list in order to the the initial value from 0
        List<String> checklistTitleValuesFromSet = new List<String>(checklistTitle);
        System.debug('checklistTitleValuesFromSet ' + checklistTitleValuesFromSet);
        // place the first animal from the set
        if (checklistTitleValuesFromSet.size() > 0){
            checklistTitleString = checklistTitleValuesFromSet[0];
            
            // add additonal scheme to the string with concatanation
            if (checklistTitleValuesFromSet.size() > 1){
                for (String scheme : checklistTitleValuesFromSet){
                    if (scheme != checklistTitleString){
                        checklistTitleString = checklistTitleString + ' and ' + scheme;
                    }
                }
            }
        } else{
            checklistTitleString = 'Scheme';
        }
        return checklistTitleString;
    }
}