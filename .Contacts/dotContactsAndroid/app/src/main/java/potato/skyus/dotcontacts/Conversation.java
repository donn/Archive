package potato.skyus.dotcontacts;

import android.database.Cursor;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Conversation extends AppCompatActivity {
    private final static String MESSAGES_URL =
            "http://127.0.0.1//store_message.php";
    private RequestQueue requestQueue;

    private EditText mEditText;
    private ConversationsDB conversationsDB;
    private ListView listView;
    private List<Message> messages;
    private ListViewAdapter mListViewAdapter;

    private String phoneNo; //
    //private String myPhoneNumber = "0123456789"; // this phone's number

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_conversation);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        requestQueue = Volley.newRequestQueue(this);
        messages = new ArrayList<>();
        mListViewAdapter = new ListViewAdapter();
        listView = (ListView) findViewById(R.id.conversation_messages_list);
        listView.setAdapter(mListViewAdapter);

        conversationsDB = new ConversationsDB(this);
        phoneNo = getIntent().getStringExtra(ChatList.MY_PHONE_NUMBER);

        int index = phoneNo.indexOf('\n') ;
        if(index == -1){
            getSupportActionBar().setTitle(phoneNo);
        }else{
            getSupportActionBar().setTitle(phoneNo.substring(0,index));
            phoneNo = phoneNo.substring(index+1);
        }

        mEditText = (EditText) findViewById(R.id.conversations_user_text);

        loadMessages();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.conversation_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle item selection
        switch (item.getItemId()) {
            case R.id.refresh_conversation:
                updateMessages();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }



    public void sendMessage(View view){
        if (GlobalInfo.instance.messagingAllowed.equals("Y"))
        {
            String txt = mEditText.getText().toString();
            if (txt.length() == 0)
                return;

            mEditText.clearFocus();
            mEditText.setText("");

            Timestamp timestamp = new Timestamp(Calendar.getInstance().getTimeInMillis());
            Message message = new Message();
            message.text = txt;
            message.time = timestamp.toString();
            message.incoming = false;

            conversationsDB.insertMessage(GlobalInfo.instance.registrationPhoneNumber
                    , phoneNo, txt, message.time);
            messages.add(message);
            mListViewAdapter.notifyDataSetChanged();

            transferMsgToServer(message);
        }
        else
        {
            Toast.makeText(getApplicationContext(), "You have messaging disabled.", Toast.LENGTH_SHORT).show();
        }
    }

    private void updateMessages(){
        StringRequest request = new StringRequest(Request.Method.POST, ChatList.MESSAGES_URL,
                updateListener,errorListener){
            @Override
            protected Map<String, String> getParams() {
                Map<String, String> params = new HashMap<String, String>();
                params.put(ChatList.MY_PHONE_NUMBER, GlobalInfo.instance.registrationPhoneNumber);
                return params;
            }
        };
        requestQueue.add(request);
    }

    Response.Listener<String> updateListener = new Response.Listener<String>() {
        @Override
        public void onResponse(String response) {
            Log.v("Chat list",response);

            Gson gson = new Gson();
            ChatList.MessageWrapper messages = gson.fromJson(response,ChatList.MessageWrapper.class);

            for(int i = 0; i < messages.SenderNumber.length; i++)
            {
                conversationsDB.insertMessage(messages.SenderNumber[i],
                        GlobalInfo.instance.registrationPhoneNumber
                        ,messages.Message[i],messages.Time[i]);
            }

            Conversation.this.messages.clear();
            loadMessages();
        }
    };

    private void transferMsgToServer(Message msg){
        final MessagePacket mPacket = new MessagePacket();
        mPacket.Message = msg.text;
        mPacket.SenderNumber = GlobalInfo.instance.registrationPhoneNumber;
        mPacket.TargetNumber = phoneNo;

        StringRequest request = new StringRequest(Request.Method.POST, MESSAGES_URL,
                successListener,errorListener){
            @Override
            protected Map<String, String> getParams() {
                Map<String, String> params = new HashMap<String, String>();
                params.put("Data", (new Gson()).toJson(mPacket));
                return params;
            }
        };
        requestQueue.add(request);
    }


    Response.Listener<String> successListener = new Response.Listener<String>() {
        @Override
        public void onResponse(String response) {
            Log.v("Conversation response",response);
        }
    };

    Response.ErrorListener errorListener = new Response.ErrorListener(){
        @Override
        public void onErrorResponse(VolleyError error) {
            Log.e("Conversation error",error.toString());
        }
    };



    private void loadMessages(){
        Cursor cursor = conversationsDB.getConversationMsg(phoneNo);
        cursor.moveToFirst();

        while (!cursor.isAfterLast()){
            Message msg = new Message();
            msg.incoming = cursor.getString(cursor.getColumnIndex(
                    ConversationsDB.COLUMN_SENDER)).equals(phoneNo);
            msg.text = cursor.getString(cursor.getColumnIndex(
                    ConversationsDB.COLUMN_MESSAGE));
            msg.time = cursor.getString(cursor.getColumnIndex(
                    ConversationsDB.COLUMN_TIME));
            cursor.moveToNext();

            messages.add(msg);
        }

        mListViewAdapter.notifyDataSetChanged();
    }

    private class ListViewAdapter extends BaseAdapter {
        @Override
        public int getCount() {
            return messages.size();
        }

        @Override
        public Object getItem(int position) {
            return messages.get(position);
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder viewHolder;
            if(convertView == null){
                convertView = getLayoutInflater().
                        inflate(R.layout.two_text_list_view_item,
                                parent, false);
                viewHolder = new ViewHolder(convertView);
                convertView.setTag(viewHolder);
            }else{
                viewHolder = (ViewHolder) convertView.getTag();
            }

            Message message = messages.get(position);

            viewHolder.txtMessage.setText(message.text);
            viewHolder.txtInfo.setText(message.time);

            setLookAndAlignment(viewHolder, message.incoming);

            return convertView;
        }

        private void setLookAndAlignment(
                ViewHolder holder,boolean incoming){
            if(!incoming){
                holder.contentWithBG.setBackgroundResource(R.drawable.in_message_bg);

                LinearLayout.LayoutParams layoutParams =
                        (LinearLayout.LayoutParams) holder.contentWithBG.getLayoutParams();
                layoutParams.gravity = Gravity.RIGHT;
                holder.contentWithBG.setLayoutParams(layoutParams);

                RelativeLayout.LayoutParams lp =
                        (RelativeLayout.LayoutParams) holder.content.getLayoutParams();
                lp.addRule(RelativeLayout.ALIGN_PARENT_LEFT, 0);
                lp.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
                holder.content.setLayoutParams(lp);
                layoutParams = (LinearLayout.LayoutParams) holder.txtMessage.getLayoutParams();
                layoutParams.gravity = Gravity.RIGHT;
                holder.txtMessage.setLayoutParams(layoutParams);

                layoutParams = (LinearLayout.LayoutParams) holder.txtInfo.getLayoutParams();
                layoutParams.gravity = Gravity.RIGHT;
                holder.txtInfo.setLayoutParams(layoutParams);
            }else{
                holder.contentWithBG.setBackgroundResource(R.drawable.out_message_bg);

                LinearLayout.LayoutParams layoutParams =
                        (LinearLayout.LayoutParams) holder.contentWithBG.getLayoutParams();
                layoutParams.gravity = Gravity.LEFT;
                holder.contentWithBG.setLayoutParams(layoutParams);

                RelativeLayout.LayoutParams lp =
                        (RelativeLayout.LayoutParams) holder.content.getLayoutParams();
                lp.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, 0);
                lp.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
                holder.content.setLayoutParams(lp);
                layoutParams = (LinearLayout.LayoutParams) holder.txtMessage.getLayoutParams();
                layoutParams.gravity = Gravity.LEFT;
                holder.txtMessage.setLayoutParams(layoutParams);

                layoutParams = (LinearLayout.LayoutParams) holder.txtInfo.getLayoutParams();
                layoutParams.gravity = Gravity.LEFT;
                holder.txtInfo.setLayoutParams(layoutParams);
            }
        }

        private class ViewHolder{
            public TextView txtMessage;
            public TextView txtInfo;
            public LinearLayout content;
            public LinearLayout contentWithBG;

            public ViewHolder(View view){
                txtMessage = (TextView) view.findViewById(
                        R.id.txtMessage);
                txtInfo = (TextView) view.findViewById(
                        R.id.txtInfo);
                contentWithBG = (LinearLayout) view.findViewById(
                        R.id.bubble_container_layout);
                content = (LinearLayout) view.findViewById(R.id.content);
            }
        }
    }

    private class Message{
        public String text;
        public String time;
        public boolean incoming;
    }

    private class MessagePacket{
        public String SenderNumber,
                Message,
                TargetNumber;
    }

}