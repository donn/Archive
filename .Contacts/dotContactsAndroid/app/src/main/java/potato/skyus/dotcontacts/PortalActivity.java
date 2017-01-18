package potato.skyus.dotcontacts;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.PagerTitleStrip;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import java.util.List;

public class PortalActivity extends AppCompatActivity {
    private TabLayout mTabLayout;
    private PageAdapter mPageAdapter;
    private ViewPager mViewPager;

    private final static String[] TITLE = {"Contact Search","Contact List","Conversations"};
    private final Fragment[] fragment = new Fragment[3];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_portal);

        mTabLayout = (TabLayout) findViewById(R.id.portal_tab_layout);
        mPageAdapter = new PageAdapter(getSupportFragmentManager(),fragment,TITLE);
        mViewPager = (ViewPager) findViewById(R.id.portal_view_pager);

        initFragments();

        mTabLayout.addOnTabSelectedListener(tabListener);
        mViewPager.setAdapter(mPageAdapter);
    }

    private void initFragments(){
        fragment[0] = new ContactLookup();
        fragment[1] = new ContactsList();
        fragment[2] = new ChatList();
    }



    private TabLayout.OnTabSelectedListener tabListener = new TabLayout.OnTabSelectedListener() {
        @Override
        public void onTabSelected(TabLayout.Tab tab) {
            int position = tab.getPosition();
            mViewPager.setCurrentItem(position);
        }

        @Override
        public void onTabUnselected(TabLayout.Tab tab) {

        }

        @Override
        public void onTabReselected(TabLayout.Tab tab) {

        }
    };


    private class PageAdapter extends FragmentPagerAdapter {
        private Fragment[] fragment;
        private String[] title;
        private int[] ICONS = {R.mipmap.search_icon,R.mipmap.contacts_icon,
                R.mipmap.chat_icon};
        public PageAdapter(FragmentManager fm,Fragment[] fragment,String[] title) {
            super(fm);
            this.fragment = fragment;
            this.title = title;
        }

        @Override
        public Fragment getItem(int position) {
            return fragment[position];
        }

        @Override
        public int getCount() {
            return fragment.length;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            Drawable image = ContextCompat.getDrawable(PortalActivity.this, ICONS[position]);
            image.setBounds(0, 0, image.getIntrinsicWidth(), image.getIntrinsicHeight());
            SpannableString sb = new SpannableString(" ");
            ImageSpan imageSpan = new ImageSpan(image, ImageSpan.ALIGN_BOTTOM);
            sb.setSpan(imageSpan, 0, 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            return sb;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) //Show overflow menu
    {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.items, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) //Process overflow menu interaction
    {
        // Handle item selection
        switch (item.getItemId())
        {
            case R.id.overflowmenu_settings:
                startActivity(new Intent(PortalActivity.this, SettingsActivity.class));
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
}
