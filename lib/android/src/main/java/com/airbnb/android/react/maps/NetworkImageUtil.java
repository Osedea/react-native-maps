package com.airbnb.android.react.maps;


import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class NetworkImageUtil extends AsyncTask<URL, Void, Bitmap> {

  protected Bitmap doInBackground(URL... url) {
    try {
      HttpURLConnection connection = (HttpURLConnection) url[0].openConnection();
      connection.connect();
      InputStream input = connection.getInputStream();
      Bitmap bitmap = BitmapFactory.decodeStream(input);
      return bitmap;
    } catch (Exception ex) {
      return null;
    }
  }
}
