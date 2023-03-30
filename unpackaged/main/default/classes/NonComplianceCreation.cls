public class NonComplianceCreation {
    public static void createNonCompliance(List<Assessments__c> newList) {
        Map<Id,Assessments__c> assessmentsComplete = new Map<Id,Assessments__c>();
        for(Assessments__c a : newList){
            if(a.Status__c == 'Completed' && a.Non_Compliances_Created__c == false){
                assessmentsComplete.put(a.Id, a);
            }
        }

        if(!assessmentsComplete.isEmpty()){
            Map<Id,List<Assessment_Checklist_Question__c>> assessmentQuestionMap = new Map<Id,List<Assessment_Checklist_Question__c>>();
            for(Assessment_Checklist_Question__c acq : [SELECT Id, Assessment_Checklist__c, Standard__c, Summary__c, Compliant__c, Comments_Action__c FROM Assessment_Checklist_Question__c WHERE Assessment_Checklist__c IN:assessmentsComplete.keySet() AND Compliant__c ='No']){
                if(assessmentQuestionMap.containsKey(acq.Assessment_Checklist__c)){
                    List<Assessment_Checklist_Question__c> questions = assessmentQuestionMap.get(acq.Assessment_Checklist__c);
                    questions.add(acq);
                    assessmentQuestionMap.put(acq.Assessment_Checklist__c, questions);
                }else{
                    assessmentQuestionMap.put(acq.Assessment_Checklist__c, new List<Assessment_Checklist_Question__c>{acq});
                }
            }

            //List<Assessments__c> assessmentsToUpdate = new List<Assessments__c>();
            Map<Id, Assessment_Report__c> assessmentToReportMap = new Map<Id, Assessment_Report__c>();
            for(Assessments__c a : assessmentsComplete.values()){
                Assessment_Report__c report = new Assessment_Report__c();
                report.Application__c = a.Application__c;
                report.Assessment__c = a.Id;
                report.Assessment_Date__c = Date.today();
                report.Assessor__c = a.Application_Assessor__c;
                assessmentToReportMap.put(a.Id, report);
            }

            if(!assessmentToReportMap.isEmpty()){
                insert assessmentToReportMap.values();

                // now create non compliance
                List<Non_Compliance__c> nonCompliancesToCreate = new  List<Non_Compliance__c>();
                for(Assessments__c a : assessmentsComplete.values()){
                    Assessment_Report__c assReport = assessmentToReportMap.get(a.Id);
                    if(assessmentQuestionMap.containsKey(a.Id)){
                        List<Assessment_Checklist_Question__c> questions = assessmentQuestionMap.get(a.Id);
                        for(Assessment_Checklist_Question__c q : questions){
                            Non_Compliance__c nonCompliance = new Non_Compliance__c();
                            nonCompliance.Assessment_Report__c = assReport.Id;
                            nonCompliance.Name = q.Standard__c;
                            nonCompliance.Standard__c = q.Summary__c;
                            nonCompliance.Non_compliance__c = q.Comments_Action__c;
                            nonCompliancesToCreate.add(nonCompliance);
                            a.Non_Compliances_Created__c = true;
                        }
                    }
                }
                if(!nonCompliancesToCreate.isEmpty()){
                    insert nonCompliancesToCreate;
                }
            }

            
        }
        

    }
}