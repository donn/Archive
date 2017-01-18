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
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.Arrays;

public class EpisodesActivity extends AppCompatActivity
{

    int genre, show;

    void quit()
    {
        Toast.makeText(this, "Unknown error occurred.", Toast.LENGTH_LONG).show();
        finish();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) //Startup.
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_episodes);
        genre = getIntent().getExtras().getInt("genre_id");
        show = getIntent().getExtras().getInt("show_id");

        TextView activityTitle = (TextView)findViewById(R.id.episodes_title);

        if (activityTitle != null)
            activityTitle.setText(SKGenre.genres[genre].shows[show].show);
        else
            quit();

        TextView showdescription = (TextView)findViewById(R.id.episodes_showDescription);

        if (showdescription != null)
                showdescription.setText(SKGenre.genres[genre].shows[show].description);
        else
            quit();

        ImageView showImage = (ImageView)findViewById(R.id.episodes_showImage);
        Picasso.with(this).load(SKGenre.genres[genre].shows[show].image).fit().centerCrop().into(showImage);

        ListView list = (ListView)findViewById(R.id.episodes_list);
        ArrayList<SKGenre.Episode> episodesArrayList = new ArrayList<>(Arrays.asList(SKGenre.genres[genre].shows[show].episodes));
        SKEpisodesAdapter adapter = new SKEpisodesAdapter(this, episodesArrayList);

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
                Intent i = new Intent(EpisodesActivity.this, PlayerActivity.class);
                i.putExtra("genre_id", genre);
                i.putExtra("show_id", show);
                i.putExtra("episode_id", position);
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
                startActivity(new Intent(EpisodesActivity.this, AboutActivity.class));
                return true;
            case R.id.overflowmenu_update:
                Intent i = new Intent(EpisodesActivity.this, GenresActivity.class);
                i.putExtra("update",true);
                startActivity(i);
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
}
