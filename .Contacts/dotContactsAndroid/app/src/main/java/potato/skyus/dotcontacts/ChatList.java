package potato.skyus.dotcontacts;


import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.text.InputType;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * A simple {@link Fragment} subclass.
 */
public class ChatList extends Fragment implements AdapterView.OnItemClickListener {
    public final static String MESSAGES_URL =
            "http://127.0.0.1//get_message.php";
    public static final String MY_PHONE_NUMBER = "PhoneNo";

    private ArrayAdapter<String> mArrayAdapter;
    private ConversationsDB conversationsDB;
    private RequestQueue mRequestQueue;
    private List<String> conversations;
    private ListView mListView;

    private FloatingActionButton addConversation;

    public ChatList(){
        conversations = new ArrayList<>();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment

        View view =  inflater.inflate(R.layout.fragment_chat_list, container, false);
        mListView = (ListView) view.findViewById(R.id.list_view_chat);
        mListView.setOnItemClickListener(this);
        addConversation = (FloatingActionButton) view.findViewById(R.id.add_conversation);
        addConversation.setOnClickListener(addNewConversation);

        mArrayAdapter = new ArrayAdapter<String>(getContext(),
                android.R.layout.simple_list_item_1,conversations);
        mListView.setAdapter(mArrayAdapter);
        return view;
    }

    View.OnClickListener addNewConversation = new View.OnClickListener(){

        @Override
        public void onClick(View v) {
            AlertDialog.Builder builder =
                    new AlertDialog.Builder(ChatList.this.getContext());
            builder.setTitle("Phone number of other party");
// Set up the input
            final EditText input = new EditText(ChatList.this.getContext());
// Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
            input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_CLASS_PHONE);
            builder.setView(input);

// Set up the buttons
            builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    String phoneNumber = input.getText().toString();
                    Intent intent = new Intent(getActivity(),Conversation.class);
                    intent.putExtra(MY_PHONE_NUMBER,phoneNumber);
                    startActivity(intent);
                }
            });
            builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.cancel();
                }
            });

            builder.show();
        }
    };


    @Override
    public void onAttach(Context context){
        super.onAttach(context);
        mRequestQueue = Volley.newRequestQueue(context);

    }

    @Override
    public void onStart(){
        super.onStart();
        conversationsDB = new ConversationsDB(getContext());

        Log.v("Chat List",GlobalInfo.instance.registrationPhoneNumber);
        conversations.clear();
        getChatMessages();
    }

    private void getChatMessages(){
        StringRequest request = new StringRequest(Request.Method.POST, MESSAGES_URL,
                successListener,errorListener){
            @Override
            protected Map<String, String> getParams() {
                Map<String, String> params = new HashMap<String, String>();
                params.put(MY_PHONE_NUMBER, GlobalInfo.instance.registrationPhoneNumber);
                return params;
            }
        };
        mRequestQueue.add(request);
    }

    Response.Listener<String> successListener = new Response.Listener<String>() {
        @Override
        public void onResponse(String response) {
            Log.v("Chat list",response);

            Gson gson = new Gson();
            MessageWrapper messages = gson.fromJson(response,MessageWrapper.class);

            for(int i = 0; i < messages.SenderNumber.length; i++)
            {
                conversationsDB.insertMessage(messages.SenderNumber[i],
                        GlobalInfo.instance.registrationPhoneNumber
                        ,messages.Message[i],messages.Time[i]);
            }

            Cursor cursor = conversationsDB.listConversations();
            cursor.moveToFirst();

            Map<String,String> currentList = new HashMap<>();

            while (!cursor.isAfterLast()){
                String partyOne = cursor.getString(cursor.getColumnIndex(
                        ConversationsDB.COLUMN_SENDER));
                String partyTwo = cursor.getString(cursor.getColumnIndex(
                        ConversationsDB.COLUMN_TARGET));
                String partyNumber = GlobalInfo.instance.
                        registrationPhoneNumber.equals(partyOne) ? partyTwo : partyOne;

                if(!currentList.containsKey(partyNumber)){
                    currentList.put(partyNumber,partyNumber);
                    conversations.add(partyNumber);
                }

                cursor.moveToNext();
            }
            mArrayAdapter.notifyDataSetChanged();
            loadNames();
        }
    };

    Response.ErrorListener errorListener = new Response.ErrorListener(){
        @Override
        public void onErrorResponse(VolleyError error) {
            Log.v("Chat list",error.toString());
        }
    };


    private void loadNames(){
        int size = conversations.size();
        for(int i = 0;i < size;i++){
            final int position = i;
            StringRequest request = new StringRequest(Request.Method.POST, ContactLookup.URL_PERSON, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    ContactLookup.USER_INFO user_info;
                    Gson gson = new Gson();
                    user_info = gson.fromJson(response,ContactLookup.USER_INFO.class);

                    if(user_info.DisplayName != null && user_info.DisplayName.length() > 0) {
                        conversations.set(position, user_info.DisplayName + "\n" + conversations.get(position));
                        mArrayAdapter.notifyDataSetChanged();
                    }
                }
            }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {

                }
            }){
                @Override
                protected Map<String, String> getParams() {
                    Map<String, String> params = new HashMap<String, String>();
                    params.put("PhoneNo",conversations.get(position));
                    return params;
                }
            };
            mRequestQueue.add(request);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Intent intent = new Intent(getActivity(),Conversation.class);
        intent.putExtra(MY_PHONE_NUMBER,conversations.get(position));
        startActivity(intent);
    }

    public class MessageWrapper{
        public String[] SenderNumber;
        public String[] Message;
        public String[] Time;
    }
}
