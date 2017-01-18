package potato.skyus.remotemediaplayer;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;

public class SKShowsAdapter extends ArrayAdapter<SKGenre.Show>
{
    Context SKContext;

    public SKShowsAdapter(Context context, ArrayList<SKGenre.Show> shows)
    {
        super(context, 0, shows);
    }

    public void passContext(Context context)
    {
        SKContext = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        SKGenre.Show show = getItem(position);
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.picasso_list_layout,parent,false);

        TextView genreName = (TextView)convertView.findViewById(R.id.textView);
        ImageView genreImage = (ImageView)convertView.findViewById(R.id.imageView);

        genreName.setText(show.show);
        Picasso.with(SKContext).load(show.image).fit().centerCrop().into(genreImage);
        return convertView;
    }

}
