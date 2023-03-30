global class AutocreatedRegHandler1612254511958 implements Auth.RegistrationHandler{
    global User createUser(Id portalId, Auth.UserData data){
        User u = [SELECT Id FROM User WHERE Email =:data.email];
        return u;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
    }
}