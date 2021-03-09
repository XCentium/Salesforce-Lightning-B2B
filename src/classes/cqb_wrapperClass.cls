public class cqb_wrapperClass{
    @auraenabled
    public Contact c;
    @auraenabled
    public User u;
   
    public cqb_wrapperClass(User myUser, Contact myContact){
        this.u = myUser;
        this.c = myContact;
    }
}