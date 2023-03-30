public class ContactTriggerHelper {
    
    public static boolean isUserNameTaken(String email){
        boolean usernameTaken;
        List<User> existingUsernameUsers = [SELECT Id, Username, Email FROM User WHERE Username=:email];
        if(existingUsernameUsers.size() > 0) {
            usernameTaken = true;
        }else{
            usernameTaken = false;
        }
            
        return usernameTaken;
    }
    
    public static boolean isNickNameTaken(String nickName){
        boolean nickNameTaken;
        List<User> existingUsernameUsers = [SELECT Id, CommunityNickname FROM User WHERE CommunityNickname=:nickName];
        if(existingUsernameUsers.size() > 0) {
            nickNameTaken = true;
        }else{
            nickNameTaken = false;
        }
            
        return nickNameTaken;
    }

}