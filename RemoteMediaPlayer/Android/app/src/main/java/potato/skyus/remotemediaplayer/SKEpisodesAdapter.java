package potato.skyus.remotemediaplayer;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

public class SKEpisodesAdapter extends ArrayAdapter<SKGenre.Episode>
{

    public SKEpisodesAdapter(Context context, ArrayList<SKGenre.Episode> episodes)
    {
        super(context, 0, episodes);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        SKGenre.Episode episode = getItem(position);
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(android.R.layout.simple_list_item_1,parent,false);

        TextView genreName = (TextView)convertView.findViewById(android.R.id.text1);

        genreName.setText(episode.video);
        return convertView;
    }

}
