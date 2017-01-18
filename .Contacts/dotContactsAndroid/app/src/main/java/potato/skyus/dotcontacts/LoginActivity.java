package potato.skyus.dotcontacts;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;

import org.apache.commons.lang3.StringUtils;

import java.io.File;

//Verify AppID, reupload contacts, download userdata
public class LoginActivity extends AppCompatActivity implements ContactDumpListener
{
    final private String checkAppIDURL = "http://127.0.0.1//check_appid.php";
    final private String uploadContactsURL = "http://127.0.0.1//contact_upload.php";
    final private String getUserInfoURL = "http://127.0.0.1//get_userdata.php";
    private TextView display;
    RequestQueue queue;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {

        queue = Volley.newRequestQueue(this);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        display = (TextView)findViewById(R.id.login_display);

        StringRequest appIDCheck = new StringRequest(Request.Method.POST, checkAppIDURL,
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {

                        if (StringUtils.isNumeric(response))
                        {
                            doContacts();
                        }
                        else
                        {
                            File dir = getFilesDir();
                            File file = new File(dir, "appid.txt");
                            boolean deleted = file.delete();
                            if (deleted)
                            {
                                Intent signup = new Intent(LoginActivity.this, SignupActivity.class);
                                startActivity(signup);
                                finish();
                            }
                            else
                                display.setText("FATAL APP ERROR");
                        }
                    }

                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        display.setVisibility(View.GONE);
                        Log.e("Volley Error", "AppID Check");
                        Toast.makeText(LoginActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                    }
                })
        {
            @Override
            public byte[] getBody()
            {
                return (GlobalInfo.instance.appID + "").getBytes();
            }
        };

        queue.add(appIDCheck);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults)
    {
        switch (requestCode)
        {
            case 0:
            {
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED)
                {
                    ContactsTask contactsTask = new ContactsTask();
                    contactsTask.setListener(this);
                    contactsTask.setContentResolver(getContentResolver());
                    contactsTask.execute();
                }
                else
                    finish();
                return;
            }
            default:
                Log.e("oRPR","Undefined permission.");
        }
    }

    @Override
    public void onTaskCompleted()
    {
        //display.setText(R.string.login_uploadingcontacts);
        Gson gson = new Gson();
        final String contactsJson =  gson.toJson(ContactsInfo.instance);
        StringRequest uploadContacts = new StringRequest(Request.Method.POST, uploadContactsURL,
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        if (StringUtils.isNumeric(response))
                        {
                            StringRequest getUserInfo = new StringRequest(Request.Method.POST, getUserInfoURL,
                                    new Response.Listener<String>()
                                    {
                                        @Override
                                        public void onResponse(String userInfoResponse)
                                        {
                                            Gson userInfoJSON = new Gson();
                                            GlobalInfo.instance = userInfoJSON.fromJson(userInfoResponse, GlobalInfo.class);
                                            Intent i = new Intent(LoginActivity.this, PortalActivity.class);
                                            startActivity(i);
                                            finish();
                                        }
                                    },
                                    new Response.ErrorListener()
                                    {
                                        @Override
                                        public void onErrorResponse(VolleyError error)
                                        {
                                            display.setVisibility(View.GONE);
                                            Log.e("Volley Error", "Get User Info");
                                            Toast.makeText(LoginActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                                        }
                                    })
                            {
                                @Override
                                public byte[] getBody() {
                                    return (GlobalInfo.instance.appID + "").getBytes();
                                }
                            };

                            queue.add(getUserInfo);
                        }
                        else
                        {
                            display.setVisibility(View.GONE);
                            Log.e("Volley Error", "Upload Contacts (Non-numeric)");
                            Log.e("Volley Error", response);
                            Toast.makeText(LoginActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                        }

                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        display.setVisibility(View.GONE);
                        Log.e("Volley Error", "Upload Contacts (VolleyError)");
                        Toast.makeText(LoginActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                    }
                })
        {
            @Override
            public byte[] getBody()
            {
                return contactsJson.getBytes();
            }
        };

        queue.add(uploadContacts);
    }

    void doContacts()
    {
        display.setText(R.string.login_processingcontacts);

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED)
        {
            if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.READ_CONTACTS))
                Toast.makeText(this, "We're gonna need your permission\nto upload your contacts.", Toast.LENGTH_LONG).show();
            else
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_CONTACTS}, 0);
        } else {
            ContactsTask contactsTask = new ContactsTask();
            contactsTask.setListener(this);
            contactsTask.setContentResolver(getContentResolver());
            contactsTask.execute();
        }
    }





}
