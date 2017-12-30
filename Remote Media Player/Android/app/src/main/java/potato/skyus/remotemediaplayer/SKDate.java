package potato.skyus.remotemediaplayer;

import java.util.Calendar;
import java.util.Date;

public class SKDate //Simple date class.
{
        int day;
        int month;
        int year;

    @Override
    public String toString()
    {
        String output;
        output = this.year + "-" + this.month + "-" + this.day;
        return output;
    }

    public boolean greaterThan(SKDate other)
    {
        if (other.year < this.year) return true;
        else if (other.year > this.year) return false;
            //Years equal by this point
        else if (other.month < this.month) return true;
        else if (other.month > this.month) return false;
            //Months equal by this point
        else if (other.day < this.day) return true;
        else return false;
    }

    public boolean equalTo(SKDate other)
    {
        return ((other.year == this.year) && (other.month == this.month) && (other.day == this.day));
    }

    public boolean lessThan(SKDate other)
    {
        if (other.year > this.year) return true;
        else if (other.year < this.year) return false;
            //Years equal by this point
        else if (other.month > this.month) return true;
        else if (other.month < this.month) return false;
            //Months equal by this point
        else if (other.day > this.day) return true;
        else return false;
    }

    @Deprecated
    public static SKDate fromDate(Date date)
    {
        SKDate skdate = new SKDate();
        skdate.day = date.getDay();
        skdate.month = date.getMonth();
        skdate.year = date.getYear();
        return skdate;
    }

    public static SKDate fromCalendar(Calendar calendar)
    {
        SKDate skdate = new SKDate();
        skdate.day = calendar.get(Calendar.DAY_OF_MONTH);
        skdate.month = calendar.get(Calendar.MONTH);
        skdate.year = calendar.get(Calendar.YEAR);
        return skdate;
    }

    public static SKDate today()
    {
        return SKDate.fromCalendar(Calendar.getInstance());
    }

    public static SKDate epoch()
    {
        SKDate epoch = new SKDate();
        epoch.day = 1;
        epoch.month = 1;
        epoch.year = 1970;
        return epoch;
    }

}
