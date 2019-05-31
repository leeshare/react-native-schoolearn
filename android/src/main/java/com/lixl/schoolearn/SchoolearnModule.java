
package com.lixl.schoolearn;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.app.Dialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.location.LocationManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.PermissionChecker;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.modules.core.PermissionListener;

import java.util.ArrayList;

import static android.Manifest.permission.RECORD_AUDIO;
import static android.graphics.Color.argb;

import android.widget.Toast;

/**
 * Author: <a href="https://github.com/leeshare">lixl</a>
 * <p>
 * Created by lixl on 17/5/17.
 * <p>
 * show a waveform controlled by a voice
 * <p>
 */

public class SchoolearnModule extends ReactContextBaseJavaModule{

    Activity activity;
    private Context mContext;

    // 音频获取源
    public static int audioSource = MediaRecorder.AudioSource.MIC;
    // 设置音频采样率，44100是目前的标准，但是某些设备仍然支持22050，16000，11025
    public static int sampleRateInHz = 44100;
    // 设置音频的录制的声道CHANNEL_IN_STEREO为双声道，CHANNEL_CONFIGURATION_MONO为单声道
    public static int channelConfig = AudioFormat.CHANNEL_IN_STEREO;
    // 音频数据格式:PCM 16位每个样本。保证设备支持。PCM 8位每个样本。不一定能得到设备支持。
    public static int audioFormat = AudioFormat.ENCODING_PCM_16BIT;
    // 缓冲区字节大小
    public static int bufferSizeInBytes = 0;


    public SchoolearnModule(ReactApplicationContext reactContext){
        super(reactContext);
    }

    @Override
    public String getName() {
        return "SchoolearnModule";
    }

    @ReactMethod
    public void alert(String message) {
        Toast.makeText(getReactApplicationContext(), message, Toast.LENGTH_LONG).show();
    }

    @ReactMethod
    public void checkPermissionMic(Callback callback){
        Boolean p_result = false;
        activity = getCurrentActivity();
        if(activity != null) {
            mContext = activity.getApplicationContext();

            bufferSizeInBytes = 0;
            bufferSizeInBytes = AudioRecord.getMinBufferSize(sampleRateInHz, channelConfig, audioFormat);
            AudioRecord audioRecord = new AudioRecord(audioSource, sampleRateInHz, channelConfig, audioFormat, bufferSizeInBytes);
            //开始录制音频
            try {
                // 防止某些手机崩溃，例如联想
                audioRecord.startRecording();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            }
            /**
             * 根据开始录音判断是否有录音权限
             */
            if (audioRecord.getRecordingState() != AudioRecord.RECORDSTATE_RECORDING) {
                p_result = false;
            }else {
                audioRecord.stop();
                audioRecord.release();
                audioRecord = null;
                p_result = true;
            }
        }

        WritableMap result = new WritableNativeMap();
        result.putBoolean("is_success", p_result);
        callback.invoke(result);
    }

    @ReactMethod
    public void checkPermissionCamera(Callback callback){
        boolean canUse = true;
        Camera mCamera = null;
        try{
            mCamera = Camera.open();
            Camera.Parameters mParameters = mCamera.getParameters();
            mCamera.setParameters(mParameters);
        }catch(Exception e) {
            canUse = false;
        }
        if(mCamera != null) {
            mCamera.release();
        }
        WritableMap result = new WritableNativeMap();
        result.putBoolean("is_success", canUse);
        callback.invoke(result);
    }

    private static final int REQUEST_READ_STATE = 1;
    private static String[] PERMISSIONS_READ_STATE = {
            Manifest.permission.READ_PHONE_STATE,
    };
    private static final int REQUEST_WRITE= 1;
    private static String[] PERMISSIONS_WRITE= {
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    @ReactMethod
    public void checkPermissionReadPhoneState(Callback callback){
        boolean canUse = true;
        activity = getCurrentActivity();
        if(activity != null) {
            mContext = activity.getApplicationContext();
            try {
                int permission = ActivityCompat.checkSelfPermission(mContext, Manifest.permission.READ_PHONE_STATE);
                if (permission != PackageManager.PERMISSION_GRANTED) {
                    // We don't have permission so prompt the user
                    ((ReactActivity)activity).requestPermissions(PERMISSIONS_READ_STATE, REQUEST_READ_STATE, new PermissionListener() {
                        @Override
                        public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
                            if(grantResults.length>0 && grantResults[0]==0){
                                WritableMap result = new WritableNativeMap();
                                result.putBoolean("is_success", true);
                                callback.invoke(result);
                                return true;
                            }
                            else{
                                WritableMap result = new WritableNativeMap();
                                result.putBoolean("is_success", false);
                                callback.invoke(result);
                                return false;
                            }
                        }
                    });
                    /*
                    ActivityCompat.requestPermissions(
                            activity,
                            PERMISSIONS_READ_STATE,
                            REQUEST_READ_STATE
                    );
                    */
                }
                else{
                    WritableMap result = new WritableNativeMap();
                    result.putBoolean("is_success", true);
                    callback.invoke(result);
                }
            }catch(Exception e) {
                WritableMap result = new WritableNativeMap();
                result.putBoolean("is_success", false);
                callback.invoke(result);
            }

        }
    }

    /**
     * 检测是否开启定位权限
     * 2018-10-23
     * @param callback
     */
    @ReactMethod
    public void checkPermissionGeolocation(Callback callback){
        boolean canUse = true;
        LocationManager lm;
        activity = getCurrentActivity();
        if(activity != null) {
            lm = (LocationManager) activity.getSystemService(activity.LOCATION_SERVICE);
            boolean ok = lm.isProviderEnabled(LocationManager.GPS_PROVIDER);
            if(ok){
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
                    canUse = false;
                }else {
                    canUse = true;
                }
            }else {
                canUse = false;
            }
        }

        WritableMap result = new WritableNativeMap();
        result.putBoolean("is_success", canUse);
        callback.invoke(result);
    }

    /**
     * 检测是否开启存储读写权限
     * 2018-11-5
     * @param callback
     */
    @ReactMethod
    public void checkPermissionWriteExternalStorage(Callback callback){
        boolean canUse = true;
        activity = getCurrentActivity();
        if(activity != null) {
            try {
                int permission = ActivityCompat.checkSelfPermission(mContext, Manifest.permission.WRITE_EXTERNAL_STORAGE);
                if(permission != PackageManager.PERMISSION_GRANTED){
                    ActivityCompat.requestPermissions(
                            activity,
                            PERMISSIONS_WRITE,
                            REQUEST_WRITE
                    );
                }

            } catch(Exception e){
                canUse = false;
            }
        }

        WritableMap result = new WritableNativeMap();
        result.putBoolean("is_success", canUse);
        callback.invoke(result);
    }

    @ReactMethod
    public void openSettings(){
        activity = getCurrentActivity();
        if(activity != null) {
            mContext = activity.getApplicationContext();
            Intent intent = new Intent();

            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                if(Build.VERSION.SDK_INT>=9){
                    intent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
                    intent.setData(Uri.fromParts("package", mContext.getPackageName(),null));
                }else if(Build.VERSION.SDK_INT<=8){
                    intent.setAction(Intent.ACTION_VIEW);
                    intent.setClassName("com.android.settings","com.android.setting.InstalledAppDetails");
                    intent.putExtra("com.android.settings.ApplicationPkgName", mContext.getPackageName());
                }
                mContext.startActivity(intent);
            } catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    @ReactMethod
    public void getUuid(Callback callback){
        String id = "";
        activity = getCurrentActivity();
        if(activity != null){
            mContext = activity.getApplicationContext();

            String androidID = Settings.Secure.getString(mContext.getContentResolver(), Settings.Secure.ANDROID_ID);
            id = androidID + Build.SERIAL;
        }
        WritableMap result = new WritableNativeMap();
        result.putString("system", "android");
        result.putString("uuid", id);
        callback.invoke(result);
    }


}
