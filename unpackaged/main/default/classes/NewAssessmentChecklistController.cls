public class NewAssessmentChecklistController {
   	
    @AuraEnabled
    public static List<Checklist_Template__c> getChecklistTemplates(String appId){
        // Query Application Units on this application
        List<Application_Unit__c> appUnitList = [SELECT Id, Application__c, Animals__c FROM Application_Unit__c WHERE Application__c =:appId AND Animals__c != null];
        
        // Use a set to store the animals in a unique list
        Set<String> animalSet = new Set<String>();
        for(Application_Unit__c au : appUnitList ){
            animalSet.add(au.Animals__c);
        }
        
        List<Checklist_Template__c> templates = [SELECT Id, Name, Species__c FROM Checklist_Template__c WHERE Status__c = 'Active' AND Species__c IN :animalSet ];
        
        if(templates.size() > 0){
            return templates;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static void createAssessmentChecklist(String appId, List<String> checklistIds){
        if(checklistIds != null & checklistIds.size() > 0 && appId != null){
            // Query the Checklist Template
            Map<Id, Checklist_Template__c> checklistTemplateMap = new Map<Id, Checklist_Template__c>([SELECT Id, Name, Species__c, Type__c FROM Checklist_Template__c WHERE Id IN:checklistIds]);
            
			// Query the checklist template standards            
            List<Checklist_Template_Standard__c> templateStandards = [SELECT Id,Name , Checklist_Template__c, Checklist_Template_Section__c ,Checklist_Template_Section__r.Name, Checklist_Template_Section__r.Order__c, Checklist_Template_Subsection__c, Checklist_Template_Subsection__r.Name, Checklist_Template_Subsection__r.Order__c, Standard_Order__c, ContentVersion_URL__c , Default_Compliant_Value__c ,Default_Comments_Action__c , Guidance_Notes__c , Summary__c   FROM Checklist_Template_Standard__c WHERE Checklist_Template__c IN:checklistIds];
            Map<Id, List<Checklist_Template_Standard__c>> templateIdToStandards = new Map<Id, List<Checklist_Template_Standard__c>>();
            
            // Map the checklist template standards to its template parent object id
            for(Checklist_Template_Standard__c cts : templateStandards){
                if(templateIdToStandards.containsKey(cts.Checklist_Template__c)){
                    List<Checklist_Template_Standard__c> lst = templateIdToStandards.get(cts.Checklist_Template__c);
                    lst.add(cts);
                    templateIdToStandards.put(cts.Checklist_Template__c, lst);
                }else{
                    templateIdToStandards.put(cts.Checklist_Template__c,  new List<Checklist_Template_Standard__c>{cts} ) ;
                }                    
            }
            
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
                    ass.Animals__c = template.Species__c;
                    checklistIdToAssessmentList.put(checkId, ass);
                }
            }
            // Insert Assessments
            if(!checklistIdToAssessmentList.values().isEmpty()){
                insert checklistIdToAssessmentList.values();
            }
            
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
                    // Get the checklist template standard from the checklist template using the id to iterate over and create the assessment questions 
                    List<Checklist_Template_Standard__c> lst = templateIdToStandards.get(checkId);
                    for(Checklist_Template_Standard__c cts : lst){                        
                        Assessment_Checklist_Question__c acq = new Assessment_Checklist_Question__c();
                        acq.Assessment_Checklist__c = ass.Id;
                        acq.Compliant__c = cts.Default_Compliant_Value__c;
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
                        acq.Comments_Action__c = cts.Default_Comments_Action__c;
                        acqList.add(acq);
                    }
                }
            }
            
            if(!acqList.isEmpty()){
                insert acqList;
            }
        }
    }
    
}