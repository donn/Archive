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

public class SKGenresAdapter extends ArrayAdapter<SKGenre>
{
    Context SKContext;

    public SKGenresAdapter(Context context, ArrayList<SKGenre> genres)
    {
        super(context, 0, genres);
    }

    public void passContext(Context context)
    {
        SKContext = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        SKGenre genre = getItem(position);
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.picasso_list_layout,parent,false);

        TextView genreName = (TextView)convertView.findViewById(R.id.textView);
        ImageView genreImage = (ImageView)convertView.findViewById(R.id.imageView);

        genreName.setText(genre.list);
        Picasso.with(SKContext).load(genre.image).fit().centerCrop().into(genreImage);
        return convertView;
    }

}
