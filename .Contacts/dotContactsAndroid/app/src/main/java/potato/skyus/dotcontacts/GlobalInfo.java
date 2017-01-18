package potato.skyus.dotcontacts;

/**
 * Created by donn on 6/25/16.
 */
public class GlobalInfo
{
    public int appID;
    public int contactID;
    public String displayName;
    public String registrationPhoneNumber;
    public String cityCode;
    public String countryCode; //Database ID, not Phone code
    public String userInfoHidden;
    public String messagingAllowed;

    static GlobalInfo instance = new GlobalInfo();
}
