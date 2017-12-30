package potato.skyus.remotemediaplayer;

public class SKGenre //Java object equivalent to incoming JSON objects
{
    public class Episode
    {
        String video;
        String url;
    }

    public class Show
    {
        String show;
        String image; //URL
        Episode episodes[];
        String description;
    }

    String list;
    String image; //URL
    int no_of_shows; //Unused
    public Show shows[];

    static String mainURL = "";
    static String dateURL = "";
    static SKDate lastUpdated = SKDate.epoch();
    static SKGenre genres[];

}
