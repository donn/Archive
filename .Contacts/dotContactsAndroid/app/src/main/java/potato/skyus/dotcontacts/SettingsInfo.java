package potato.skyus.dotcontacts;

/**
 * Created by auc on 6/26/16.
 */

public class SettingsInfo
{
    public int appID;
    public String userInfoHidden;
    public String messagingAllowed;

    public SettingsInfo()
    {
        appID = GlobalInfo.instance.appID;
        userInfoHidden = GlobalInfo.instance.userInfoHidden;
        messagingAllowed = GlobalInfo.instance.messagingAllowed;
    }
}
