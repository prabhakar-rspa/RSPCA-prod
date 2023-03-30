public class ClearSuspensionCntrl {
    
    private ApexPages.StandardController standardController;
    
    public ClearSuspensionCntrl(ApexPages.StandardController standardController){
        this.standardController = standardController;
    }
    
    public PageReference createSuspensionHistory(){
        Id actId = standardController.getId();
        Account act = [SELECT Id, Name, Request_for_Suspension__c, Date_Requested_For_Suspension__c, 
                       Reason_For_Suspension_Picklist__c, Reason_for_Suspension__c, Administrator__c, 
                       Approval_Certifier__c, Approved__c, Outcome_Approved_By_Certifier__c, Further_Information__c, 
                       Date_Suspended__c, Outcome__c FROM Account WHERE Id =: actId];
        if(act.Request_for_Suspension__c){
            /** Create suspension history record **/
            Suspension_History__c ssh = new Suspension_History__c();
            ssh.Account__c = act.Id;
            ssh.Administrator__c = act.Administrator__c;
            ssh.Approved__c = act.Approved__c;
            ssh.Approval_Certifier__c = act.Approval_Certifier__c;
            ssh.Date_Requested_for_Suspension__c = act.Date_Requested_For_Suspension__c;
            ssh.Date_Suspended__c = act.Date_Suspended__c;
            ssh.Further_Information__c = act.Further_Information__c;
            if(act.Reason_For_Suspension_Picklist__c == 'Other'){
                ssh.Reason_For_Suspension__c = act.Reason_for_Suspension__c;
            }else{
                ssh.Reason_For_Suspension__c = act.Reason_For_Suspension_Picklist__c;
            }
            ssh.Outcome__c = act.Outcome__c;
            ssh.Outcome_Approved_By_Certifier__c = act.Outcome_Approved_By_Certifier__c;
			
            /** clear suspension fields on account record **/
            act.Request_for_Suspension__c = false;
            act.Reason_For_Suspension_Picklist__c = null;
            act.Reason_for_Suspension__c = null;
            act.Date_Requested_For_Suspension__c = null;
            act.Administrator__c = null;
            act.Approval_Certifier__c = null;
            act.Approved__c = null;
            act.Date_Suspended__c = null;
            act.Further_Information__c = null;
            act.Outcome__c = null;
            act.Outcome_Approved_By_Certifier__c = null;
            try{
                insert ssh;
                update act;
            }catch(DMLException e){
                System.debug('Error while clearing suspension '+e.getMessage());
            }
        }
        PageReference pg = new PageReference('/'+act.Id);
        pg.setRedirect(true);
        return pg;  
    }
}