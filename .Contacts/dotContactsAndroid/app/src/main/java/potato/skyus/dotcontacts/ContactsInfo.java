package potato.skyus.dotcontacts;

/**
 * Created by donn on 6/25/16.
 */
public class ContactsInfo
{
    public int appID; //For json purposes and only for json purposes
    public Contact[] contacts;
    public ContactsInfo()
    {
        appID = GlobalInfo.instance.appID;
    }

    static ContactsInfo instance;
}
