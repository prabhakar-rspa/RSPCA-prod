public without sharing class CommunitiesAccountPageRedirect {
    public Pagereference urlRedirection() {
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='RSPCA Assured Community'];
        String communitiesUrl = Network.getLoginUrl(myNetwork.id);
        communitiesUrl = communitiesUrl.remove('/login');
        User u = [SELECT Id, AccountId FROM User WHERE Id =:UserInfo.getUserId()];
        if(u.AccountId != null){
            communitiesUrl = communitiesUrl +'/account/' + u.AccountId;
        }else{
             communitiesUrl = communitiesUrl +'/profile/' + u.Id; 
        }
        PageReference retURL = new PageReference(communitiesUrl);
        retURL.setRedirect(true);
        return retURL;
    }
}