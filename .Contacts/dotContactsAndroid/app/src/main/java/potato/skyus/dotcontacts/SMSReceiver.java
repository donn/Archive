package potato.skyus.dotcontacts;

import android.provider.Telephony;
import android.provider.Telephony.Sms.Intents;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.SmsMessage;
import android.util.Log;
import android.widget.Toast;

public class SMSReceiver extends BroadcastReceiver {
    private SMSReceiverInterface listener;

    public SMSReceiver() {
        super();
    }

    public void setListener(SMSReceiverInterface activity) {
        this.listener = activity;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.v("SMS Receiver","Broadcast received.");
        Toast.makeText(context,"SMS received.", Toast.LENGTH_LONG).show();
        switch (intent.getAction()){
            case Intents.SMS_RECEIVED_ACTION:
                String senderNumber = ((SmsMessage[])Intents.getMessagesFromIntent(intent))[0].getOriginatingAddress();
                String message = readSms(intent);
                listener.SMSReceived(senderNumber, message);
                break;
        }
    }

    private String readSms(Intent intent){
        StringBuilder builder = new StringBuilder();

        for(SmsMessage msg : Intents.getMessagesFromIntent(intent))
            builder.append(msg.getMessageBody());

        return builder.toString();
    }
}
