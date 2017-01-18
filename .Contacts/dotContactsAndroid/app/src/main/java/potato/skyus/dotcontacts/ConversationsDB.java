package potato.skyus.dotcontacts;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class ConversationsDB extends SQLiteOpenHelper {
    public static String DATABASE_NAME = "DATABASE",
            TABLE_MESSAGES = "Message",
            COLUMN_SENDER = "Sender",
            COLUMN_TARGET = "Target",
            COLUMN_MESSAGE = "Message",
            COLUMN_TIME = "Time";
    private static int VERSION = 1;

    public ConversationsDB(Context context) {
        super(context, DATABASE_NAME, null, VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String query = "CREATE TABLE "+TABLE_MESSAGES+"("+COLUMN_SENDER+
                " VARCHAR(16),"+COLUMN_TARGET+" VARCHAR(16),"+COLUMN_MESSAGE+" TEXT,"+COLUMN_TIME+" TIMESTAMP)";
        db.execSQL(query);
    }


    public void insertMessage(String sender,String target,
                              String message,String time){
        ContentValues contentValues = new ContentValues();

        contentValues.put(COLUMN_SENDER,sender);
        contentValues.put(COLUMN_TARGET,target);
        contentValues.put(COLUMN_MESSAGE,message);
        contentValues.put(COLUMN_TIME,time);

        getWritableDatabase().insert(TABLE_MESSAGES,null,contentValues);
    }

    /**
     *  gets messages that involve both sender and target
     * @param sender
     * @param target
     * @return
     */
    public Cursor getConversationMsg(String sender, String target){
        String query = String.format(("SELECT * FROM %s where (%s = %s AND %s = %s) OR" +
                        "(%s = %s AND %s = %s) ORDER BY datetime(%s) ASC  Limit 30"),
                TABLE_MESSAGES,COLUMN_SENDER,sender,COLUMN_TARGET,target,
                COLUMN_SENDER,target,COLUMN_TARGET,sender,COLUMN_TIME);
        return getReadableDatabase().rawQuery(query,new String[]{});
    }

    /**
     *  gets messages that involve both sender
     * @return
     */
    public Cursor getConversationMsg(String conversationParticipant){
        String query = String.format(("SELECT * FROM %s where %s = '%s' OR %s = '%s' " +
                        "ORDER BY datetime(%s) ASC  Limit 30"),
                TABLE_MESSAGES,COLUMN_SENDER,conversationParticipant,
                COLUMN_TARGET,conversationParticipant,COLUMN_TIME);
        Log.e("CONVERSATIONS DATABASE",query);
        return getReadableDatabase().rawQuery(query,new String[]{});
    }


    public Cursor listConversations(){
        String query = "SELECT DISTINCT TARGET,SENDER FROM "+TABLE_MESSAGES;
        return getReadableDatabase().rawQuery(query,new String[]{},null);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }
}
