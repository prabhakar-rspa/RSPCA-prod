/*
 * Name :Prabhakar
 * Description : Used in New Assessment Checklist quick action of application object
 * Update history : Updated for SPRINT 6, Prepopulated the answers from the previous checklist
*/
public class NewAssessmentChecklistController {
   	
    @AuraEnabled
    public static List<Checklist_Template__c> getChecklistTemplates(String appId){
        // Query Application Units on this application
        Application__c application = [SELECT Id,Name,Assessment_Date__c FROM Application__c WHERE Id=:appId];
        List<Application_Unit__c> appUnitList = [SELECT Id, Application__c, Animals__c,Unit__r.Animals_List__c FROM Application_Unit__c WHERE Application__c =:appId AND (Animals__c != null OR Unit__r.Animals_List__c != null)];
        Date assessmentDate = application.Assessment_Date__c;
        // Use a set to store the animals in a unique list
        Set<String> animalSet = new Set<String>();
        List<String> animalsList = new List<String>();
        for(Application_Unit__c au : appUnitList ){
            if(au.Animals__c != null && au.Animals__c != 'List'){
                animalSet.add(au.Animals__c);
            }
            if(au.Unit__r.Animals_List__c != null){
                List<String> animals = au.Unit__r.Animals_List__c.split(';');
                animalsList.addAll(animals);
            }
        }
        String animals = '\''+String.join(animalsList, '\',\'')+'\'';
        SYSTEM.DEBUG('animals:::'+animals);
        SYSTEM.DEBUG('animalSet:::'+animalSet);
        String query = 'SELECT Id, Name, Species__c,Animals_List__c FROM Checklist_Template__c WHERE Status__c = \'Active\' AND (Species__c IN :animalSet OR (Animals_List__c INCLUDES ('+animals+') AND Animals_List__c != NULL))';
        query += ' AND Start_Date__c <= :assessmentDate AND End_Date__c >=:assessmentDate';
        List<Checklist_Template__c> templates = database.query(query);
        system.debug('query::'+query);
        //templates = database.query(query);
        if(templates.size() > 0){
            return templates;
        }else{
            return null;
        }
        
    }
    public class ChecklistDetail{
        @AuraEnabled public string status;
        @AuraEnabled public List<AssessmentChecklistDetail> AssessmentChecklistDetails;
    }
    public class AssessmentChecklistDetail{
        @AuraEnabled public Checklist_Template__c checklistTemplate;
        @AuraEnabled public Assessments__c sourceAssessment;
        @AuraEnabled public string species;
        @AuraEnabled public string animalsList;
        @AuraEnabled public List<Assessments__c> OtherAssessments;
        @AuraEnabled public boolean otherAssessmentsAvailable;
    }
    @AuraEnabled
    public static ChecklistDetail checkPreviousAssessmentChecklist(String appId, List<String> checklistIds){
        Map<String,AssessmentChecklistDetail> AssessmentChecklistDetailMap = new Map<String,AssessmentChecklistDetail>();
        Application__c application = [SELECT Id,Name,Assessment_Date__c,Application_Type__c,MemberShip_number__c,Site__r.Previous_Membership__r.Membership_Number__c FROM Application__c WHERE Id=:appId];
        String membershipNumber = (application.Application_Type__c == 'Transfer'? application.Site__r.Previous_Membership__r.Membership_Number__c:application.MemberShip_number__c);
        Map<Id, Checklist_Template__c> checklistTemplateMap = new Map<Id, Checklist_Template__c>([SELECT Id, Name, Species__c, Type__c,Animals_List__c FROM Checklist_Template__c WHERE Id IN:checklistIds]);
        Integer availableSourceAssessmentsCount = 0;
        List<String> animalsList = new List<String>();
        List<String> animals = new List<String>();
        ChecklistDetail checklistDetail = new ChecklistDetail();

        AssessmentChecklistDetail detail = new AssessmentChecklistDetail();
        for(Checklist_Template__c template : checklistTemplateMap.values()){
            String key = '';
            if(String.isNotBlank(template.Species__c)){
                animals.add(template.Species__c);
                key = template.Species__c;
            }
            if(String.isNotBlank(template.Animals_List__c)){
                animalsList.add(template.Animals_List__c);
                if(key == 'List' || key != template.Animals_List__c){
                    key = template.Animals_List__c;
                }
            }
            detail.OtherAssessments = new List<Assessments__c>();
            detail.otherAssessmentsAvailable = false;
            detail.species = template.Species__c;
            detail.animalsList = template.Animals_List__c;
            detail.checklistTemplate = template;
            //AssessmentChecklistDetailMap.put(key,detail);
        }
        //Map<String,Assessments__c> assessmentsMap = new Map<String,Assessments__c>();
        system.debug('animals::::'+animals);
        List<Assessments__c> sourceAssessments = [
            SELECT Id,Name,Animals_List__c,Animals__c FROM Assessments__c 
            WHERE (Animals_List__c IN:animalsList OR Animals__c IN:animals) 
            AND Application__r.MemberShip_number__c =:membershipNumber AND Status__c = 'Completed' 
            ORDER BY Application__r.Assessment_Date__c DESC NULLS LAST
        ];
        List<Assessments__c> otherMembersAssessments = [
            SELECT Id,Name,Animals_List__c,Animals__c,Application__c,Application__r.Assessment_Date__c,Application__r.Membership_Number__c,
            Application__r.Assessor__c,Application__r.Assessor__r.Name,Application__r.Site__r.Name,Application__r.Application_Type__c
            FROM Assessments__c 
            WHERE (Animals_List__c IN:animalsList OR Animals__c IN:animals) AND Status__c = 'Completed' 
            AND (Application__r.RecordType.DeveloperName = 'Applications' or Application__r.RecordType.DeveloperName = 'Renewal')
            ORDER BY Application__r.Assessment_Date__c DESC NULLS LAST
        ];
        if(sourceAssessments != null && sourceAssessments.size() >0){
            detail.sourceAssessment = sourceAssessments[0];
            checklistDetail.status = 'success';
        }else{
            detail.otherAssessmentsAvailable = true;
            detail.OtherAssessments = otherMembersAssessments;
            checklistDetail.status = 'error';
        }
        
        
        /*for(Assessments__c assessment:sourceAssessments){
            
            String key = '';
            if(String.isNotBlank(assessment.Animals__c)){
                key = assessment.Animals__c;
            }
            if(String.isNotBlank(assessment.Animals_List__c)){
                if(key == 'List' || key != assessment.Animals_List__c){
                    key = assessment.Animals_List__c;
                }
            }
            if(AssessmentChecklistDetailMap.containsKey(key)){
                AssessmentChecklistDetail detail = AssessmentChecklistDetailMap.get(key);
                if(detail.sourceAssessment == null){
                    detail.sourceAssessment = assessment;
                    availableSourceAssessmentsCount++;
                    AssessmentChecklistDetailMap.put(key,detail);
                }
            }
        }
        ChecklistDetail checklistDetail = new ChecklistDetail();
        if(availableSourceAssessmentsCount == checklistIds.size()){
            checklistDetail.status = 'success';
        }else{
            for(Assessments__c assessment:otherMembersAssessments){
                String key = '';
                if(String.isNotBlank(assessment.Animals__c)){
                    key = assessment.Animals__c;
                }
                if(String.isNotBlank(assessment.Animals_List__c)){
                    if(key == 'List' || key != assessment.Animals_List__c){
                        key = assessment.Animals_List__c;
                    }
                }
                if(AssessmentChecklistDetailMap.containsKey(key)){
                    AssessmentChecklistDetail detail = AssessmentChecklistDetailMap.get(key);
                    if(detail.sourceAssessment == null){
                        detail.otherAssessmentsAvailable = true;
                        detail.OtherAssessments.add(assessment);
                        AssessmentChecklistDetailMap.put(key,detail);
                    }
                }
            }
            checklistDetail.status = 'error';
        }*/
        checklistDetail.AssessmentChecklistDetails = new List<AssessmentChecklistDetail>{detail};//AssessmentChecklistDetailMap.values();
        return checklistDetail;
    }
    @AuraEnabled
    public static void createAssessmentChecklist(String appId, List<String> checklistIds,String assessmentChecklistDetailStr){
        try{
            system.debug('assessmentChecklistDetailStr:::'+assessmentChecklistDetailStr);

            if(checklistIds != null & checklistIds.size() > 0 && appId != null){
                List<AssessmentChecklistDetail> AssessmentChecklistDetails = new List<AssessmentChecklistDetail>();
                if(String.isNotBlank(assessmentChecklistDetailStr)){
                	AssessmentChecklistDetails = (List<AssessmentChecklistDetail>)JSON.deserialize(assessmentChecklistDetailStr,List<AssessmentChecklistDetail>.class);
                }
                system.debug('AssessmentChecklistDetails:::'+AssessmentChecklistDetails);

                Application__c application = [SELECT Id,Name,Assessment_Date__c,MemberShip_number__c FROM Application__c WHERE Id=:appId];
                // Query the Checklist Template
                Map<Id, Checklist_Template__c> checklistTemplateMap = new Map<Id, Checklist_Template__c>([SELECT Id, Name, Species__c, Type__c,Animals_List__c FROM Checklist_Template__c WHERE Id IN:checklistIds]);
                system.debug('checklistIds::::'+checklistIds);
                // Query the checklist template standards            
                List<Checklist_Template_Standard__c> templateStandards = [SELECT Id,Name , Previous_standard__c,Checklist_Template__c, Checklist_Template_Section__c ,Checklist_Template_Section__r.Name, Checklist_Template_Section__r.Order__c, Checklist_Template_Subsection__c, Checklist_Template_Subsection__r.Name, Checklist_Template_Subsection__r.Order__c, Standard_Order__c, ContentVersion_URL__c , Default_Compliant_Value__c ,Default_Comments_Action__c , Guidance_Notes__c , Summary__c   FROM Checklist_Template_Standard__c WHERE Checklist_Template__c IN:checklistTemplateMap.keySet()];
                Map<Id, List<Checklist_Template_Standard__c>> templateIdToStandards = new Map<Id, List<Checklist_Template_Standard__c>>();
                Map<Id,Set<String>> previousStandards = new Map<Id,Set<String>>();

                // Map the checklist template standards to its template parent object id
                for(Checklist_Template_Standard__c cts : templateStandards){
                    if(templateIdToStandards.containsKey(cts.Checklist_Template__c)){
                        List<Checklist_Template_Standard__c> lst = templateIdToStandards.get(cts.Checklist_Template__c);
                        lst.add(cts);
                        templateIdToStandards.put(cts.Checklist_Template__c, lst);
                    }else{
                        templateIdToStandards.put(cts.Checklist_Template__c,  new List<Checklist_Template_Standard__c>{cts} ) ;
                    } 
                    if(String.isNotBlank(cts.Previous_standard__c) && cts.Previous_standard__c != cts.Name){
                        if(previousStandards.containsKey(cts.Checklist_Template__c)){
                            previousStandards.get(cts.Checklist_Template__c).add(cts.Previous_standard__c);
                        }else{
                            previousStandards.put(cts.Checklist_Template__c,  new Set<String>{cts.Previous_standard__c} ) ;
                        }
                    }
                }
                system.debug('previousStandards::::'+previousStandards);
                List<String> animalsList = new List<String>();
                List<String> animals = new List<String>();
                // Map of Assessments to create
                Map<Id, Assessments__c> checklistIdToAssessmentList = new Map<Id, Assessments__c>();
                 // Iterate through all checklist ids
                for(String checkId : checklistIds){
                    if(templateIdToStandards.containsKey(checkId) && checklistTemplateMap.containsKey(checkId)){
                        // Get the checklist template to populate values in the assessment
                        Checklist_Template__c template = checklistTemplateMap.get(checkId);
                        Assessments__c  ass = new Assessments__c();
                        ass.Application__c = appId;
                        if(template.Type__c == 'Standard Checklist'){
                            ass.Checklist_Type__c = 'Welfare Standard Checklist';
                        }else if(template.Type__c == 'Welfare Outcome Checklist'){
                            ass.Checklist_Type__c = 'Welfare Outcome Assessment Checklist';
                        }
                        if(template.Animals_List__c != null){
                            ass.Animals_List__c = template.Animals_List__c;
                        }
                        //--animalsList.add(template.Animals_List__c);
                        ass.Animals__c = template.Species__c;
                        //--animals.add(template.Species__c);
                        checklistIdToAssessmentList.put(checkId, ass);
                    }
                }
                system.debug('checklistIdToAssessmentList:::'+checklistIdToAssessmentList);
                /*Map<String,Assessments__c> assessmentsMap = new Map<String,Assessments__c>();
                List<Assessments__c> sourceAssessments = [SELECT Id,Name,Animals_List__c,Animals__c FROM Assessments__c WHERE Animals_List__c IN:animalsList AND Animals__c IN:animals AND Application__r.MemberShip_number__c =:application.MemberShip_number__c ORDER BY CreatedDate DESC];// AND Id != 'a0T0Q000003JP9jUAG' 
                for(Assessments__c assessment:sourceAssessments){
                    String key = assessment.Animals__c +'-'+assessment.Animals_List__c;
                    if(!assessmentsMap.containsKey(key)){
                   		 assessmentsMap.put(key,assessment);
                    }
                }*/
                // Insert Assessments
                if(!checklistIdToAssessmentList.values().isEmpty()){
                    insert checklistIdToAssessmentList.values();
                }
                Map<String,Assessments__c> assessmentsMap = new Map<String,Assessments__c>();
                for(AssessmentChecklistDetail checklistDetail:AssessmentChecklistDetails){
                    String key = checklistDetail.species +'-'+checklistDetail.animalsList;
                    if(!assessmentsMap.containsKey(key)){
                   		 assessmentsMap.put(key,checklistDetail.sourceAssessment);
                    }
                }
                system.debug('assessmentsMap::::'+assessmentsMap);
                Map<String,Map<String,Assessment_Checklist_Question__c>> checklistQuestions = new Map<String,Map<String,Assessment_Checklist_Question__c>>();
                for(Assessment_Checklist_Question__c question:[SELECT Id,Assessment_Checklist__c,Standard__c,Compliant__c,Comments_Action__c FROM Assessment_Checklist_Question__c WHERE Assessment_Checklist__c IN:assessmentsMap.values()]){
                    if(!checklistQuestions.containsKey(question.Assessment_Checklist__c)){
                        checklistQuestions.put(question.Assessment_Checklist__c,new Map<String,Assessment_Checklist_Question__c>());
                    }
                    Map<String,Assessment_Checklist_Question__c> questionMap = checklistQuestions.get(question.Assessment_Checklist__c);
                    questionMap.put(question.Standard__c,question);
                    checklistQuestions.put(question.Assessment_Checklist__c,questionMap);
                }
                system.debug('checklistQuestions::::'+checklistQuestions);
                // Map of Checklist Section Id to Assessment Section 
                Map<Id, Assessment_Checklist_Section__c> templateSectionIdToAssessmentSection = new Map<Id, Assessment_Checklist_Section__c>();
                // Iterate through all checklist ids
                for(String checkId : checklistIds){
                    if(checklistIdToAssessmentList.containsKey(checkId)){
                        Assessments__c  ass = checklistIdToAssessmentList.get(checkId);
                         // Get the checklist template standard from the checklist template using the id to iterate over and create the assessment sections 
                        List<Checklist_Template_Standard__c> lst = templateIdToStandards.get(checkId);
                        for(Checklist_Template_Standard__c cts : lst){
                            if(!templateSectionIdToAssessmentSection.containsKey(cts.Checklist_Template_Section__c)){
                                templateSectionIdToAssessmentSection.put(
                                    cts.Checklist_Template_Section__c,
                                    new Assessment_Checklist_Section__c(
                                        Assessment__c = ass.Id, 
                                        Checklist_Section_Name__c = cts.Checklist_Template_Section__r.Name, 
                                        Checklist_Section_Order__c = cts.Checklist_Template_Section__r.Order__c
                                    )
                                );
                            }
                        }
                    }
                }
                // Insert Assessment Sections
                if(!templateSectionIdToAssessmentSection.values().isEmpty()){
                    insert templateSectionIdToAssessmentSection.values();
                }
                
                // List of Assessment Checklist Questions to create            
                List<Assessment_Checklist_Question__c> acqList = new List<Assessment_Checklist_Question__c>();
                // Iterate through all checklist ids
                for(String checkId : checklistIds){
                    if(checklistIdToAssessmentList.containsKey(checkId)){
                        Assessments__c  ass = checklistIdToAssessmentList.get(checkId);
                        String key = ass.Animals__c +'-'+ass.Animals_List__c;
                        Map<String,Assessment_Checklist_Question__c> questions = new Map<String,Assessment_Checklist_Question__c>();
                        if(assessmentsMap.containsKey(key) && assessmentsMap.get(key) != null){
                            Assessments__c sourceAssessment = assessmentsMap.get(key);
                            system.debug('sourceAssessment::::'+sourceAssessment);
                            questions = checklistQuestions.get(sourceAssessment.Id);
                            system.debug('questions::::'+questions);
                        }
                        
                        // Get the checklist template standard from the checklist template using the id to iterate over and create the assessment questions 
                        List<Checklist_Template_Standard__c> lst = templateIdToStandards.get(checkId);
                        Set<String> previousStandardsSet = new Set<String>();
                        if(previousStandards.containsKey(checkId)){
                            previousStandardsSet = previousStandards.get(checkId);
                        }
                        system.debug('previousStandardsSet:::'+previousStandardsSet);
                        for(Checklist_Template_Standard__c cts : lst){                        
                            Assessment_Checklist_Question__c acq = new Assessment_Checklist_Question__c();
                            Assessment_Checklist_Question__c source;
                            if(questions != null){
                                system.debug('cts.Name:::'+cts.Name);
                                system.debug('cts.Previous_standard__c:::'+cts.Previous_standard__c);
                                if(questions.containsKey(cts.Name) && (!previousStandardsSet.contains(cts.Name))){
                                    source = questions.get(cts.Name);
                                }else if(String.isNotBlank(cts.Previous_standard__c) && questions.containsKey(cts.Previous_standard__c)){
                                    source = questions.get(cts.Previous_standard__c);
                                }
                            }
                            
                            if(source != null && (source.Compliant__c == 'N/A' || source.Compliant__c == 'Yes')){
                                acq.Compliant__c = source.Compliant__c;
                                acq.Comments_Action__c = source.Comments_Action__c;
                            }else{
                                acq.Compliant__c = cts.Default_Compliant_Value__c;
                                acq.Comments_Action__c = cts.Default_Comments_Action__c;
                            }
                            acq.Assessment_Checklist__c = ass.Id;
                            
                            acq.ContentVersion_URL__c  = cts.ContentVersion_URL__c;
                            acq.Guidance_Notes__c = cts.Guidance_Notes__c;
                            acq.Standard__c  = cts.Name;
                            
                            if(templateSectionIdToAssessmentSection.containsKey(cts.Checklist_Template_Section__c)){
                                // If Asessment Checklist Section already exists, then link the Asessment Checklist Question to the section and populate the values
                                Assessment_Checklist_Section__c acs = templateSectionIdToAssessmentSection.get(cts.Checklist_Template_Section__c);
                                acq.Assessment_Checklist_Section__c = acs.Id;
                                acq.Section__c = acs.Checklist_Section_Name__c;
                                acq.Section_Order__c = acs.Checklist_Section_Order__c;
                            }
                            acq.Subsection__c = cts.Checklist_Template_Subsection__r.Name;
                            acq.Subsection_Order__c = cts.Checklist_Template_Subsection__r.Order__c;
                            acq.Summary__c = cts.Summary__c;
                            acq.Standard_Order__c = cts.Standard_Order__c;
                            
                            acqList.add(acq);
                        }
                    }
                }
                
                if(!acqList.isEmpty()){
                    insert acqList;
                }
            }
        }catch(Exception ex){
            throw new auraHandledException(ex.getMessage());
        }
    }
    
}