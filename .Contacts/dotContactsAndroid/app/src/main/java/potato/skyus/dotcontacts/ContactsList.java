package potato.skyus.dotcontacts;


import android.app.Activity;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.Toast;

import java.util.List;


/**
 * A simple {@link Fragment} subclass.
 */
public class ContactsList extends Fragment {
    private ListView mListView;
    private ListAdapter mListAdapter;
    private Activity activity;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mListAdapter = new ListAdapter(getActivity());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_contracts_list, container, false);
        mListView = (ListView) view.findViewById(R.id.contacts_list_list_view);
        mListView.setAdapter(mListAdapter);
        return view;
    }


    @Override
    public void onStart(){
        super.onStart();
        if(mListAdapter.getCount() == 0){
            loadContacts();
        }
    }

    private void loadContacts(){
        Cursor phones = getActivity().getContentResolver().query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                null,null,null, null);

        while (phones.moveToNext())
        {
            String name= phones.getString(phones.getColumnIndex(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
            String phoneNumber = phones.getString(phones.getColumnIndex(
                    ContactsContract.CommonDataKinds.Phone.NUMBER));
            mListAdapter.addItem(name,phoneNumber,null);
        }
        phones.close();
        mListAdapter.notifyDataSetChanged();
    }
}
