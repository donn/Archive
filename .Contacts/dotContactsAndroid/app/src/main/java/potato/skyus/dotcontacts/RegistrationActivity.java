package potato.skyus.dotcontacts;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.provider.Telephony;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
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

import java.io.FileOutputStream;


public class RegistrationActivity extends AppCompatActivity implements SMSReceiverInterface
{
    RequestQueue queue;
    final int PRLA_CONTACTS = 0;
    private int progress = 0;
    private SMSReceiver mSMSReceiver;
    private ProgressBar progressBar;
    private TextView display;
    private String expectedSender = "7674636";//"+14048003880";
    private String registerURL = "http://127.0.0.1//register.php";
    private String verifyURL = "http://127.0.0.1//verify.php";
    private int verificationCode;

    boolean receivedSMS = false;
    boolean haveBoth = false;


    public String APP_PREF = "PREFERENCES";
    public String APP_ID_PREF = "APP_ID_PREF";

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registration);

        queue = Volley.newRequestQueue(this);

        final String registrationJson = getIntent().getExtras().getString("jsonString");
        
        mSMSReceiver = new SMSReceiver();
        mSMSReceiver.setListener(this);
        progressBar = (ProgressBar)findViewById(R.id.postloadingregistration_progressbar);
        display = (TextView)findViewById(R.id.postloadingregistration_display);

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Telephony.Sms.Intents.SMS_RECEIVED_ACTION );

        StringRequest registrationPost = new StringRequest(Request.Method.POST, registerURL,
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        if (StringUtils.isNumeric(response))
                        {
                            GlobalInfo.instance.appID = Integer.valueOf(response);
                            progress += 33;
                            progressBar.setProgress(progress);
                            tryToStartVerification();
                        }
                        else
                        {
                            Log.e("registrationPost", response);
                            progressBar.setVisibility(View.GONE);
                            display.setVisibility(View.GONE);
                            Toast.makeText(RegistrationActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                        }
                    }

                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        progressBar.setVisibility(View.GONE);
                        display.setVisibility(View.GONE);
                        Toast.makeText(RegistrationActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                    }
                })
        {
          @Override
          public byte[] getBody()
          {
              return registrationJson.getBytes();
          }
        };

        registerReceiver(mSMSReceiver,intentFilter);
        queue.add(registrationPost);
        display.setText(R.string.postregistrationloading_gettingSMS);
    }

    @Override
    public void onStop()
    {
        unregisterReceiver(mSMSReceiver);
        finish();
        super.onStop();
    }

    @Override
    public void SMSReceived(String sender, String message)
    {
        final String sampleString = "Your .Contacts verification code is: ";
        if (message.contains(sampleString) && !receivedSMS)
        {
            display.setText(R.string.postregistrationloading_registering);
            progress += 33;
            progressBar.setProgress(progress);
            verificationCode = Integer.valueOf(message.substring(sampleString.length()));
            receivedSMS = true;
            if (haveBoth)
                startVerification();
            else
                haveBoth = true;
        }
    }

    public synchronized void tryToStartVerification()
    {
        if (haveBoth)
            startVerification();
        else haveBoth = true;
    }

    void startVerification()
    {
        progress += 34;
        progressBar.setProgress(progress);
        display.setText(R.string.postregistrationloading_registering);

        final Verification verification = new Verification(GlobalInfo.instance.appID, verificationCode);
        final Gson gson = new Gson();

        StringRequest verificationPost = new StringRequest(Request.Method.POST, verifyURL,
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        if (StringUtils.isNumeric(response) && Integer.valueOf(response) == GlobalInfo.instance.appID)
                        {
                            try
                            {
                                FileOutputStream fos;
                                fos = openFileOutput("appid.txt", Context.MODE_PRIVATE);
                                fos.write((GlobalInfo.instance.appID + "").getBytes());
                                fos.close();

                               // saveAppIDInPref(GlobalInfo.instance.appID);
                            } catch (Exception e) {
                                Log.e("Volley Response", "IO Error.");
                            }
                            Intent login = new Intent(RegistrationActivity.this, LoginActivity.class);
                            startActivity(login);
                        }
                        else
                        {
                            Log.e("verificationPost", response);
                            progressBar.setVisibility(View.GONE);
                            display.setVisibility(View.GONE);
                            Toast.makeText(RegistrationActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                        }

                    }

                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        progressBar.setVisibility(View.GONE);
                        display.setVisibility(View.GONE);
                        Toast.makeText(RegistrationActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                    }
                })
        {
            @Override
            public byte[] getBody()
            {
                return gson.toJson(verification).getBytes();
            }
        };

        queue.add(verificationPost);
    }

    private void saveAppIDInPref(int appID) {
        SharedPreferences prefs = getSharedPreferences(
                APP_PREF,Context.MODE_PRIVATE);
        prefs.edit().putInt(APP_ID_PREF,appID);
    }
}
