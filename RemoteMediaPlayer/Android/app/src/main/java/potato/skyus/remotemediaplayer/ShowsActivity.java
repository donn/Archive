package potato.skyus.remotemediaplayer;

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
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Arrays;

public class ShowsActivity extends AppCompatActivity
{

    int genre;

    void quit()
    {
        Toast.makeText(this, "Unknown error occurred.", Toast.LENGTH_LONG).show();
        finish();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) //Startup.
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_shows);
        genre = getIntent().getExtras().getInt("genre_id");

        TextView activityTitle = (TextView)findViewById(R.id.shows_title);

        if (activityTitle != null)
            activityTitle.setText(SKGenre.genres[genre].list);
        else
            quit();

        ListView list = (ListView)findViewById(R.id.shows_list);
        ArrayList<SKGenre.Show> showArrayList = new ArrayList<>(Arrays.asList(SKGenre.genres[genre].shows));
        SKShowsAdapter adapter = new SKShowsAdapter(this, showArrayList);
        adapter.passContext(this);

        if (list != null)
            list.setAdapter(adapter);
        else
            quit();

        //List cannot be null by this point, the entire activity will have terminated.
        assert list != null;
        list.setOnItemClickListener(new AdapterView.OnItemClickListener()
        {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id)
            {
                Log.d("Pressed", "" + position);
                Intent i = new Intent(ShowsActivity.this, EpisodesActivity.class);
                i.putExtra("genre_id", genre);
                i.putExtra("show_id", position);
                startActivity(i);
            }
        });

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.items, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        // Handle item selection
        switch (item.getItemId())
        {
            case R.id.overflowmenu_about:
                startActivity(new Intent(ShowsActivity.this, AboutActivity.class));
                return true;
            case R.id.overflowmenu_update:
                Intent i = new Intent(ShowsActivity.this, GenresActivity.class);
                i.putExtra("update",true);
                startActivity(i);
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

}
