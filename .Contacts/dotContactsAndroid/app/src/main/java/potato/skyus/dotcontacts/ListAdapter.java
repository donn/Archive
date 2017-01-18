package potato.skyus.dotcontacts;

import android.app.Activity;
import android.support.v4.content.pm.ActivityInfoCompat;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.support.v4.widget.*;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

import potato.skyus.dotcontacts.R;

/**
 * Created by auc on 6/20/16.
        */
public class ListAdapter  extends BaseAdapter {
    private Activity activity;
    private List<ListItemData> list;

    public ListAdapter(Activity activity,List<ListItemData> list){
        this.activity = activity;
        this.list = list;
    }

    public ListAdapter(Activity activity){
        this.activity = activity;
        list = new ArrayList<>();
    }

    public void addItem(String title,String subTitle,String imageURL){
        list.add(new ListItemData(title,subTitle,imageURL));
    }

    public void addItem(ListItemData item){
        list.add(item);
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ListItemView item;
        if(convertView == null) {
            convertView = activity.getLayoutInflater().
                    inflate(R.layout.list_view_item, parent, false);
            item = new ListItemView(convertView);
            convertView.setTag(item);
        }else{
            item = (ListItemView) convertView.getTag();
        }
        ListItemData info = list.get(position);

        item.title.setText(info.title);
        item.subText.setText(info.text2);
        Picasso.with(activity).load(info.imageUrl).
                placeholder(R.mipmap.ic_launcher).into(item.image);

        return convertView;
    }

    public class ListItemData{
        public String title; // larger text
        public String text2; // smaller text
        public String imageUrl;

        public ListItemData(String title, String text2, String imageUrl) {
            this.title = title;
            this.text2 = text2;
            this.imageUrl = imageUrl;
        }
    }

    private class ListItemView{
        public TextView title;
        public TextView subText;
        public ImageView image;

        public ListItemView(View view){
            title = (TextView) view.findViewById(R.id.list_view_item_title);
            subText = (TextView) view.findViewById(R.id.list_view_item_subtext);
            image = (ImageView) view.findViewById(R.id.list_view_item_image);
        }
    }
}
