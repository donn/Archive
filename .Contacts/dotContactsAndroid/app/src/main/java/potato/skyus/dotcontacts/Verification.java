package potato.skyus.dotcontacts;

//DO NOT USE OUTSIDE REGISTRATION ACTIVITY!! IT'S ONLY STATIC BECAUSE OF GSON
class Verification
{
    int appID;
    int verification;
    public Verification(int id, int v)
    {
        appID = id;
        verification = v;
    }
}