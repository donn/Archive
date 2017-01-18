package potato.skyus.dotcontacts;

import android.content.ContentResolver;
import android.database.Cursor;
import android.os.AsyncTask;
import android.provider.ContactsContract;

import java.util.ArrayList;

public class ContactsTask extends AsyncTask<String, String, String>
{
    ContactDumpListener listener;
    ContentResolver contentResolver;

    void setListener(ContactDumpListener cdl)
    {
        listener = cdl;
    }

    void setContentResolver(ContentResolver cr)
    {
        contentResolver = cr;
    }

    //Acknowledgement: StackOverflow user Aerrow
    @Override
    protected String doInBackground(String... params) {


        Cursor cur = contentResolver.query(ContactsContract.Contacts.CONTENT_URI,
                null, null, null, null);

        ArrayList<Contact> contacts = new ArrayList<>();

        if (cur.getCount() > 0) {
            while (cur.moveToNext()) {

                Contact contact = new Contact();
                contact.emails = new ArrayList<>();
                contact.phoneNumbers = new ArrayList<>();

                String id = cur.getString(cur.getColumnIndex(ContactsContract.Contacts._ID));

                contact.displayName = cur.getString(
                        cur.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));

                Cursor pCur = contentResolver.query(
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                        new String[]{id}, null);

                while (pCur.moveToNext())
                    contact.phoneNumbers.add(pCur.getString(pCur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)));

                pCur.close();

                Cursor emailCur = contentResolver.query(
                        ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                        new String[]{id}, null);

                while (emailCur.moveToNext())
                {
                    String email = emailCur.getString(emailCur.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA));
                    contact.emails.add(email); // Here you will get list of email
                }

                emailCur.close();

                if (!(contact.emails.size() == 0) || !(contact.phoneNumbers.size() == 0))
                    contacts.add(contact);
            }
        }

        ContactsInfo.instance = new ContactsInfo();

        ContactsInfo.instance.contacts = contacts.toArray(new Contact[0]);

        listener.onTaskCompleted();
        return "Done";
    }
}
