package potato.skyus.dotcontacts;

import android.content.Intent;
import android.media.audiofx.BassBoost;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;

import org.apache.commons.lang3.StringUtils;

public class SettingsActivity extends AppCompatActivity {

    RequestQueue queue;
    final private String updateSettingsURL = "http://127.0.0.1/update_settings.php";

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {

        queue = Volley.newRequestQueue(this);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        Switch chat = (Switch)findViewById(R.id.settings_chat);
        if (GlobalInfo.instance.messagingAllowed.equals("Y"))
            chat.setChecked(true);

        Switch privacy = (Switch)findViewById(R.id.settings_privacy);
        if (GlobalInfo.instance.userInfoHidden.equals("Y"))
            privacy.setChecked(true);

        chat.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean isChecked)
            {
                compoundButton.setChecked(isChecked);
                GlobalInfo.instance.messagingAllowed = isChecked?"Y":"N";
                startVolley();
            }
        });

        privacy.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                buttonView.setChecked(isChecked);
                GlobalInfo.instance.userInfoHidden = isChecked?"Y":"N";
                startVolley();
            }
        });

    }

    protected void startVolley()
    {
        Gson gson = new Gson();
        final String settingsUpdate = gson.toJson(new SettingsInfo());

        StringRequest updateSettings = new StringRequest(Request.Method.POST, updateSettingsURL,
                new Response.Listener<String>()
                {
                    @Override
                    public void onResponse(String response)
                    {
                        if (StringUtils.isNumeric(response))
                        {
                            Log.v("Settings", "Updated successfully.");
                        }
                        else
                        {
                            Log.e("Volley Error", response);
                            Toast.makeText(SettingsActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                        }
                    }
                },
                new Response.ErrorListener()
                {
                    @Override
                    public void onErrorResponse(VolleyError error)
                    {
                        Toast.makeText(SettingsActivity.this, "Server error. Try again later.", Toast.LENGTH_SHORT).show();
                    }
                })
        {
            @Override
            public byte[] getBody() {
                return settingsUpdate.getBytes();
            }
        };

        queue.add(updateSettings);
    }

}
