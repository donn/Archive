package potato.skyus.remotemediaplayer;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Arrays;

public class GenresActivity extends AppCompatActivity implements Response.Listener, Response.ErrorListener
{
    RequestQueue queue;
    SKDate today = SKDate.today();
    SKDate obtainedDate;
    String obtainedDateJSON;
    private int requestQueueCount = -1;

    @Override
    public void onResponse(Object response) //Handles volley responses.
    {
        String szResponse = response.toString();
        boolean attemptedListingUpdate = false;
        if (requestQueueCount == 1)
        {
            Gson gson = new Gson();

            obtainedDateJSON = szResponse;

            obtainedDate = gson.fromJson(szResponse, SKDate.class);
            Log.v("Volley Response", "Date received.");

            StringRequest jsonRequest = new StringRequest(Request.Method.GET, SKGenre.mainURL, this, this);
            queue.add(jsonRequest);
        }
        else if (requestQueueCount == 0)
        {
            boolean update;
            attemptedListingUpdate = true;

            try
            {
                update = obtainedDate.greaterThan(SKGenre.lastUpdated);
            } catch (Exception e) {
                update = true;
            }

            if (update)
            {
                Gson gson = new Gson();

                FileOutputStream fos = null;
                try
                {
                    fos = openFileOutput("videos.json", Context.MODE_PRIVATE);
                    fos.write(szResponse.getBytes());
                    fos.close();
                } catch (Exception e) {
                    Log.e("Volley Response", "IO Error.");
                }

                try
                {
                    fos = openFileOutput("date.json", Context.MODE_PRIVATE);
                    fos.write(obtainedDateJSON.getBytes());
                    fos.close();
                } catch (Exception e) {
                    Log.e("Volley Response", "IO Error.");
                }

                SKGenre.genres = new SKGenre[]{};
                SKGenre.genres = gson.fromJson(szResponse, SKGenre[].class);

                Log.v("Volley Response", "Show JSON and Date JSON parsed.");

                SKGenre.lastUpdated = obtainedDate;
                Toast.makeText(this, "Show list updated.", Toast.LENGTH_LONG).show();
            }
            else
                Toast.makeText(this, "Show list already up to date.", Toast.LENGTH_LONG).show();
        }
        else
            Log.e("Volley Response", "Extraneous request.");

        if (attemptedListingUpdate) //For safety, it's done regardless of if the data is indate or not.
        {
            ListView list = (ListView) findViewById(R.id.genres_list);

            ArrayList<SKGenre> genreArrayList = new ArrayList<SKGenre>(Arrays.asList(SKGenre.genres));
            SKGenresAdapter adapter = new SKGenresAdapter(this, genreArrayList);
            adapter.passContext(this);
            list.setAdapter(adapter);
            list.setOnItemClickListener(new AdapterView.OnItemClickListener()
            {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    Log.v("Pressed", "" + position);
                    Intent i = new Intent(GenresActivity.this, ShowsActivity.class);
                    i.putExtra("genre_id", position);
                    startActivity(i);
                }
            });
        }


        requestQueueCount--;
    }

    @Override
    public void onErrorResponse(VolleyError error) //Responds to network errors.
    {
        String statusCode;

        try
        {
            statusCode = "" + error.networkResponse.statusCode;
        } catch (NullPointerException name) { //A null pointer with volley usually means the internet connection is down.
            statusCode = "Network response null. No internet connection.";
            Toast.makeText(this, "Check your internet connection.", Toast.LENGTH_LONG).show();
        }
        Log.e("Volley Error", statusCode);

        requestQueueCount--;

    }


    void attemptUpdate() //Tries to update. Will not respond if the RequestQueueCount is >= 0 for thread safety.
    {
        if (requestQueueCount < 0)
        {
            StringRequest jsonRequest = new StringRequest(Request.Method.GET, SKGenre.dateURL, this, this);
            queue.add(jsonRequest);
            requestQueueCount = 1;
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) //Startup
    {
        boolean update;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_genres);
        queue =  Volley.newRequestQueue(this);


        Intent received = getIntent();
        if (received == null)
            Log.d("Startup", "Null intent.");

        //Update routine
        update = (today.day % 5) == 0;

        if (update)
            Log.d("Startup", "Updating today." + today.toString());

        try
        {
            if (getIntent().getExtras().getBoolean("update"))
            {
                update = true;
                Log.d("Startup","Intent received, updating.");
            }
        } catch (NullPointerException npe) {
            //Most likely started from the launcher.
        }

        //Check for local date file
        try
        {
            FileInputStream fis = openFileInput("date.json");
            Log.v("Startup", "Found date file, parsing...");

            StringBuilder dateJson = new StringBuilder("");
            int ch;
            while((ch = fis.read()) != -1)
                dateJson.append((char)ch); //Concatenate

            SKGenre.lastUpdated = new Gson().fromJson(dateJson.toString(), SKDate.class);
        } catch (Exception e) {
            Log.v("Startup", "Local date.json inaccessible.");
            update = true;
        }

        //Check for local genre file
        try
        {
            FileInputStream fis = openFileInput("videos.json");
            Log.v("Startup", "Found show file, parsing...");

            StringBuilder localShowJson = new StringBuilder("");
            int ch;
            while ((ch = fis.read()) != -1)
                localShowJson.append((char) ch); //Concatenate

            SKGenre.genres = new Gson().fromJson(localShowJson.toString(), SKGenre[].class);
        } catch (Exception e) {
            Log.v("Startup", "Local videos.json inaccessible.");
            update = true;
        }

        if (update)
            attemptUpdate();
        else
        {
            ListView list = (ListView) findViewById(R.id.genres_list);

            ArrayList<SKGenre> genreArrayList = new ArrayList<SKGenre>(Arrays.asList(SKGenre.genres));
            SKGenresAdapter adapter = new SKGenresAdapter(this, genreArrayList);
            adapter.passContext(this);
            list.setAdapter(adapter);
            list.setOnItemClickListener(new AdapterView.OnItemClickListener()
            {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id)
                {
                    Log.v("Pressed", "" + position);
                    Intent i = new Intent(GenresActivity.this, ShowsActivity.class);
                    i.putExtra("genre_id", position);
                    startActivity(i);
                }
            });
        }

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) //Show overflow menu
    {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.items, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) //Process overflow menu interaction
    {
        // Handle item selection
        switch (item.getItemId())
        {
            case R.id.overflowmenu_about:
                startActivity(new Intent(GenresActivity.this, AboutActivity.class));
                return true;
            case R.id.overflowmenu_update:
                attemptUpdate();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

}
