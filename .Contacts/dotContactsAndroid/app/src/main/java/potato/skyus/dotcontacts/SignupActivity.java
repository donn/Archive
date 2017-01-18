package potato.skyus.dotcontacts;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.telephony.PhoneNumberUtils;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;

import java.io.FileInputStream;

public class SignupActivity extends AppCompatActivity
{
    private final int REGACTIVITY_RECEIVESMS = 0;
    private Gson gson;
    private String jsonToSend;
    private String[] countryArray;
    private String[] phonecodeArray;
    private TextView phonecodeDisplay;
    private Spinner spinner;
    private int currentCountry;
    private boolean needToRegister = false;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

        getWindow().setSoftInputMode(
                WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN
        );

        TelephonyManager manager = (TelephonyManager) this.getSystemService(Context.TELEPHONY_SERVICE);
        if (manager.getPhoneType() == TelephonyManager.PHONE_TYPE_NONE) {
            Intent mNotAPhone = new Intent(SignupActivity.this, NotAPhoneActivity.class);
            startActivity(mNotAPhone);
            finish();
        }


        try
        {
            FileInputStream fis = openFileInput("appid.txt");
            Log.v("Startup", "Found AppID file...");

            StringBuilder appIDSB = new StringBuilder("");
            int ch;
            while ((ch = fis.read()) != -1)
                appIDSB.append((char) ch); //Concatenate

            GlobalInfo.instance.appID = Integer.valueOf(appIDSB.toString());
            Log.v("AppID", GlobalInfo.instance.appID + "");
            Intent skipRegistration = new Intent(SignupActivity.this, LoginActivity.class);
            startActivity(skipRegistration);
            finish();


        } catch (Exception e) {
            Log.v("Startup", e.toString());
        }

        String[] countryLocPair = this.getResources().getStringArray(R.array.CountryCodes);
        countryArray = new String[countryLocPair.length];
        phonecodeArray = new String[countryLocPair.length];

        for (int i = 0; i < countryLocPair.length; i++)
        {
            String[] pair = countryLocPair[i].split(",");
            countryArray[i] = pair[1];
            phonecodeArray[i] = pair[0];
        }

        spinner = (Spinner)findViewById(R.id.registration_spinner);
        ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, countryArray); //selected item will look like a spinner set from XML
        spinnerArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(spinnerArrayAdapter);
        phonecodeDisplay = (TextView)findViewById(R.id.registration_phonecodedisplay);
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parentView, View selectedItemView, int position, long id) {
                currentCountry = position;
                phonecodeDisplay.setText("+" + phonecodeArray[position]);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parentView) {
                // welp
            }

        });

    }

    public void onClick_register(View currentView)
    {

        UserInfo currentUser = new UserInfo();

        EditText mFirstName = (EditText) findViewById(R.id.registration_firstName);
        EditText mLastName = (EditText) findViewById(R.id.registration_lastName);
        EditText mPhone = (EditText) findViewById(R.id.registration_phone);


            if (mFirstName != null && !(mFirstName.getText().toString().equals("")) && mLastName != null && !(mLastName.getText().toString().equals("")))
                currentUser.displayName = mFirstName.getText().toString() + " " + mLastName.getText().toString();
            else
            {
                Toast.makeText(this, "Display name invalid.", Toast.LENGTH_SHORT).show();
                return;
            }


        if (mPhone != null && PhoneNumberUtils.isGlobalPhoneNumber(mPhone.getText().toString()))
            currentUser.phoneNumber = "+" + phonecodeArray[currentCountry] + mPhone.getText().toString();
        else
        {
            Toast.makeText(this, "Phone number invalid.", Toast.LENGTH_SHORT).show();
            return;
        }

        currentUser.country = "+" + phonecodeArray[currentCountry];


        gson = new Gson();
        jsonToSend = gson.toJson(currentUser, UserInfo.class);

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS)
                != PackageManager.PERMISSION_GRANTED)
        {
            if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.RECEIVE_SMS))
                Toast.makeText(this, "We're gonna need your permission\nfor the registration SMS.", Toast.LENGTH_LONG).show();
            else
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECEIVE_SMS}, REGACTIVITY_RECEIVESMS);
        }
        else
        {
            Intent tryToRegister = new Intent(SignupActivity.this, RegistrationActivity.class);
            tryToRegister.putExtra("jsonString", jsonToSend);
            startActivity(tryToRegister);
            finish();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults)
    {
        switch (requestCode)
        {
            case REGACTIVITY_RECEIVESMS:
            {
                 if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED)
                {
                    Intent tryToRegister = new Intent(SignupActivity.this, RegistrationActivity.class);
                    tryToRegister.putExtra("jsonString", jsonToSend);
                    startActivity(tryToRegister);
                    finish();
                }
                else
                    finish();
                return;
            }
            default:
                Log.e("RegistrationActivity", "Undefined permission.");
        }
    }
}
