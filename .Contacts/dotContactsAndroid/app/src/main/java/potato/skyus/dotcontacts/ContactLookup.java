package potato.skyus.dotcontacts;


import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

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

import de.hdodenhof.circleimageview.CircleImageView;


/**
 * A simple {@link Fragment} subclass.
 */
public class ContactLookup extends Fragment implements TextWatcher, View.OnClickListener {
    public final static String URL_SEARCH =
            "http://127.0.0.1//contact_search.php";
    public final static String URL_PERSON =
            "http://127.0.0.1//contact_info.php";
    private ImageButton search;
    private RequestQueue queue;
    private AutoCompleteTextView mEditText;
    private ArrayAdapter<String> autoCompleteAdapter;
    private List<String> phoneNumbersAvailable;

    private CircleImageView callBtn,smsBtn,emailBtn,chatBtn;
    private LinearLayout contactOptions;


    private USER_INFO userInfo;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        queue = Volley.newRequestQueue(context);

        phoneNumbersAvailable = new ArrayList<>();
        autoCompleteAdapter = new ArrayAdapter<String>(context,
                android.R.layout.simple_dropdown_item_1line,phoneNumbersAvailable);
        autoCompleteAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_contact_lookup, container, false);

        mEditText = (AutoCompleteTextView) view.findViewById(R.id.contact_look_number);
        mEditText.setAdapter(autoCompleteAdapter);
        mEditText.addTextChangedListener(this);
        mEditText.setThreshold(3);

        search = (ImageButton) view.findViewById(R.id.look_up_contact_btn);
        search.setOnClickListener(searchBtnListener);

        callBtn  = (CircleImageView) view.findViewById(R.id.call);
        smsBtn   = (CircleImageView) view.findViewById(R.id.sms);
        emailBtn = (CircleImageView) view.findViewById(R.id.email);
        chatBtn  = (CircleImageView) view.findViewById(R.id.chat);

        contactOptions = (LinearLayout) view.findViewById(R.id.contact_options);

        callBtn.setOnClickListener(this);
        smsBtn.setOnClickListener(this);
        emailBtn.setOnClickListener(this);
        chatBtn.setOnClickListener(this);

        return view;
    }


    @Override
    public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

    }

    @Override
    public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        contactOptions.setVisibility(View.INVISIBLE);
        displayUserInfo(new USER_INFO("","","",""));

        if(charSequence.length() > 3)
            queryServer(charSequence.toString());
    }

    @Override
    public void afterTextChanged(Editable editable) {

    }

    private View.OnClickListener searchBtnListener = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            final String phoneNumber = mEditText.getText().toString();
            mEditText.clearFocus();
            getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
            StringRequest request = new StringRequest(Request.Method.POST, URL_PERSON, new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    USER_INFO user_info;
                    Gson gson = new Gson();
                    user_info = gson.fromJson(response,USER_INFO.class);
                    displayUserInfo(user_info);

                    if(user_info.DisplayName.length() == 0)
                        return;

                    contactOptions.setVisibility(View.VISIBLE);
                }
            }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {

                }
            }){
                @Override
                protected Map<String, String> getParams() {
                    Map<String, String> params = new HashMap<String, String>();
                    params.put("PhoneNo", phoneNumber);
                    return params;
                }
            };
            queue.add(request);
        }
    };



    private void queryServer(String phoneNumber){
        NumberRequest request = new NumberRequest();
        request.PhoneNo = phoneNumber;
        request.AppID = GlobalInfo.instance.appID;


        final String jsonObj = (new Gson()).toJson(request);

        StringRequest mStringRequest = new StringRequest(Request.Method.POST, URL_SEARCH,replyListener
                ,errorListener){
            @Override
            protected Map<String,String> getParams(){
                Map<String,String> params = new HashMap<String, String>();
                params.put("USER_MSG",jsonObj);
                return params;
            }
        };
        queue.add(mStringRequest);
    }

    private void displayUserInfo(USER_INFO info){
        this.userInfo = info;

        ((TextView)getActivity().findViewById(
                R.id.contact_lookup_name)).setText(info.DisplayName);
        ((TextView)getActivity().findViewById(
                R.id.contact_lookup_location)).setText(info.Location);
    }

    private Response.Listener<String> replyListener = new Response.Listener<String>() {
        @Override
        public void onResponse(String response) {
            Gson gson = new Gson();
            PhoneNumbers numbers = gson.fromJson(response,
                    PhoneNumbers.class);

            autoCompleteAdapter.clear();
            for(String item : numbers.PhoneNo)
                autoCompleteAdapter.add(item);
            autoCompleteAdapter.notifyDataSetChanged();
        }
    };

    private Response.ErrorListener errorListener = new Response.ErrorListener(){

        @Override
        public void onErrorResponse(VolleyError error) {
            Log.e("Contact Lookup",error.toString());
        }
    };

    @Override
    public void onClick(View view) {
        switch (view.getId()){
            case R.id.call:
                Intent intent = new Intent(Intent.ACTION_DIAL);
                intent.setData(Uri.parse("tel:"+userInfo.PhoneNo));
                startActivity(intent);
                break;
            case R.id.email:
                intent = new Intent(Intent.ACTION_SEND);
                intent.setType("text/plain");
                intent.putExtra(Intent.EXTRA_EMAIL, userInfo.Email);
                startActivity(Intent.createChooser(intent, "Send Email"));
                break;
            case R.id.chat:
                Intent myIntent = new Intent(getActivity(),Conversation.class);
                myIntent.putExtra(ChatList.MY_PHONE_NUMBER,userInfo.PhoneNo);
                startActivity(myIntent);
                break;
            case R.id.sms:
                intent = new Intent(Intent.ACTION_VIEW,
                        Uri.parse("sms:"+userInfo.PhoneNo));
                startActivity(intent);
                break;
        }
    }

    private class PhoneNumbers
    {
        public String[] PhoneNo;
    }

    public class USER_INFO{
        public String DisplayName;
        public String Location;
        public String PhoneNo;
        public String Email;
        public USER_INFO(){

        }
        public USER_INFO(String name,String loc,String Phone,String Email){
            DisplayName = name;
            Location = loc;
            PhoneNo = Phone;
            this.Email = Email;
        }
    };

    private class NumberRequest{
        public String PhoneNo;
        public int AppID;
    }
}
