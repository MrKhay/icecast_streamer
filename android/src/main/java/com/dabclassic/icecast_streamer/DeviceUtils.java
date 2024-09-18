package com.dabclassic.icecast_streamer;

import android.content.Context;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;

import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DeviceUtils {


    @RequiresApi(api = Build.VERSION_CODES.M)
    public static List<Map<String, String>> listInputDevicesAsMap(Context context) {
        List<Map<String, String>> devices = new ArrayList<>();
        for (AudioDeviceInfo device : listInputDevices(context)) {
            StringBuilder label = new StringBuilder();
            label.append(device.getProductName())
                    .append(" (")
                    .append(typeToString(device.getType()));
            if (Build.VERSION.SDK_INT >= 28) {
                label.append(", ").append(device.getAddress());
            }
            label.append(")");

            Map<String, String> deviceMap = new HashMap<>();
            deviceMap.put("id", String.valueOf(device.getId()));
            deviceMap.put("label", label.toString());
            devices.add(deviceMap);
        }
        return devices;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private static List<AudioDeviceInfo> listInputDevices(Context context) {
        AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_INPUTS);
        return filterSources(devices);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public static AudioDeviceInfo deviceInfoFromId(Context context, String id) {
        if (id == null) return null;

        for (AudioDeviceInfo info : listInputDevices(context)) {
            if (String.valueOf(info.getId()).equals(id)) {
                return info;
            }
        }
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    private static List<AudioDeviceInfo> filterSources(AudioDeviceInfo[] devices) {
        List<AudioDeviceInfo> filteredDevices = new ArrayList<>();
        for (AudioDeviceInfo device : devices) {
            if (device.isSource() &&
                    device.getType() != AudioDeviceInfo.TYPE_TELEPHONY &&
                    device.getType() != AudioDeviceInfo.TYPE_REMOTE_SUBMIX) {
                filteredDevices.add(device);
            }
        }
        return filteredDevices;
    }

    private static String typeToString(int type) {
        switch (type) {
            case AudioDeviceInfo.TYPE_UNKNOWN:
                return "unknown";
            case AudioDeviceInfo.TYPE_BUILTIN_EARPIECE:
                return "built-in earpiece";
            case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER:
                return "built-in speaker";
            case AudioDeviceInfo.TYPE_WIRED_HEADSET:
                return "wired headset";
            case AudioDeviceInfo.TYPE_WIRED_HEADPHONES:
                return "wired headphones";
            case AudioDeviceInfo.TYPE_LINE_ANALOG:
                return "line analog";
            case AudioDeviceInfo.TYPE_LINE_DIGITAL:
                return "line digital";
            case AudioDeviceInfo.TYPE_BLUETOOTH_SCO:
                return "Bluetooth telephony SCO";
            case AudioDeviceInfo.TYPE_BLUETOOTH_A2DP:
                return "Bluetooth A2DP";
            case AudioDeviceInfo.TYPE_HDMI:
                return "HDMI";
            case AudioDeviceInfo.TYPE_HDMI_ARC:
                return "HDMI audio return channel";
            case AudioDeviceInfo.TYPE_USB_DEVICE:
                return "USB device";
            case AudioDeviceInfo.TYPE_USB_ACCESSORY:
                return "USB accessory";
            case AudioDeviceInfo.TYPE_DOCK:
                return "dock";
            case AudioDeviceInfo.TYPE_FM:
                return "FM";
            case AudioDeviceInfo.TYPE_BUILTIN_MIC:
                return "built-in microphone";
            case AudioDeviceInfo.TYPE_FM_TUNER:
                return "FM tuner";
            case AudioDeviceInfo.TYPE_TV_TUNER:
                return "TV tuner";
            case AudioDeviceInfo.TYPE_TELEPHONY:
                return "telephony";
            case AudioDeviceInfo.TYPE_AUX_LINE:
                return "auxiliary line-level connectors";
            case AudioDeviceInfo.TYPE_IP:
                return "IP";
            case AudioDeviceInfo.TYPE_BUS:
                return "bus";
            case AudioDeviceInfo.TYPE_USB_HEADSET:
                return "USB headset";
            case AudioDeviceInfo.TYPE_HEARING_AID:
                return "hearing aid";
            case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER_SAFE:
                return "built-in speaker safe";
            case AudioDeviceInfo.TYPE_REMOTE_SUBMIX:
                return "remote submix";
            case AudioDeviceInfo.TYPE_BLE_HEADSET:
                return "BLE headset";
            case AudioDeviceInfo.TYPE_BLE_SPEAKER:
                return "BLE speaker";
            case 28:
                return "echo reference"; // AudioDeviceInfo.TYPE_ECHO_REFERENCE
            case AudioDeviceInfo.TYPE_HDMI_EARC:
                return "HDMI enhanced ARC";
            case AudioDeviceInfo.TYPE_BLE_BROADCAST:
                return "BLE broadcast";
            default:
                return "unknown=" + type;
        }
    }
}
