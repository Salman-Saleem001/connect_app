/**
 * Mirrors Flutter `CameraScreen` (fromMessage: true).
 * Full black stage + centered preview, Create Video bar, left Flip/Flash/Media,
 * bottom timer + orange shutter, Upload, 30/45/60.
 */
import { Brand } from '@/constants/Colors';
import { CameraView, useCameraPermissions, useMicrophonePermissions } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { router, useLocalSearchParams } from 'expo-router';
import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

type FlashCycle = 'off' | 'auto' | 'torch';
type MediaMode = 'video' | 'image';

const SHUTTER_ORANGE = '#F15A31';

export default function ChatCameraScreen() {
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<Record<string, string>>();
  const cameraRef = useRef<CameraView>(null);

  const [camPerm, requestCamPerm] = useCameraPermissions();
  const [micPerm, requestMicPerm] = useMicrophonePermissions();

  const [facing, setFacing] = useState<'back' | 'front'>('back');
  const [flash, setFlash] = useState<FlashCycle>('off');
  const [mediaMode, setMediaMode] = useState<MediaMode>('video');
  const [recording, setRecording] = useState(false);
  const [ready, setReady] = useState(false);
  const [selectedTime, setSelectedTime] = useState(45);
  const [recordedSeconds, setRecordedSeconds] = useState(0);
  const [paddingValue, setPaddingValue] = useState(0);

  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const recordingRef = useRef(false);

  useEffect(() => {
    if (camPerm?.granted && !micPerm?.granted) {
      requestMicPerm();
    }
  }, [camPerm?.granted, micPerm?.granted, requestMicPerm]);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, []);

  useEffect(() => {
    if (!recording) return;
    timerRef.current = setInterval(() => {
      setRecordedSeconds((s) => {
        const next = s + 1;
        if (next >= selectedTime) {
          stopRecording();
          return s;
        }
        return next;
      });
    }, 1000);
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [recording, selectedTime]);

  async function ensurePerms() {
    if (!camPerm?.granted) {
      const r = await requestCamPerm();
      if (!r.granted) {
        Alert.alert('', 'Camera permission is required.');
        return false;
      }
    }
    if (!micPerm?.granted) {
      const r = await requestMicPerm();
      if (!r.granted) {
        Alert.alert('', 'Microphone permission is required to record video.');
        return false;
      }
    }
    return true;
  }

  function goToPreview(uri: string, isVideo: boolean) {
    router.replace({
      pathname: '/chat/preview',
      params: {
        ...params,
        uri,
        isVideo: isVideo ? '1' : '0',
      },
    });
  }

  async function startRecording() {
    if (!cameraRef.current || !ready || recordingRef.current) return;
    const ok = await ensurePerms();
    if (!ok) return;

    recordingRef.current = true;
    setPaddingValue(13);
    setRecording(true);
    setRecordedSeconds(0);

    try {
      const result = await cameraRef.current.recordAsync({
        maxDuration: selectedTime,
      });
      if (result?.uri) {
        goToPreview(result.uri, true);
      }
    } catch (e) {
      Alert.alert('Camera', e instanceof Error ? e.message : 'Failed to record');
    } finally {
      recordingRef.current = false;
      setRecording(false);
      setPaddingValue(0);
      setRecordedSeconds(0);
    }
  }

  function stopRecording() {
    if (!cameraRef.current || !recordingRef.current) return;
    cameraRef.current.stopRecording();
    recordingRef.current = false;
    setRecording(false);
    setPaddingValue(0);
  }

  async function onPressShutter() {
    if (mediaMode === 'image') {
      if (!cameraRef.current || !ready) return;
      const ok = await ensurePerms();
      if (!ok) return;
      try {
        const photo = await cameraRef.current.takePictureAsync({ quality: 0.8 });
        if (photo?.uri) goToPreview(photo.uri, false);
      } catch (e) {
        Alert.alert('Camera', e instanceof Error ? e.message : 'Failed to capture');
      }
      return;
    }

    if (recordingRef.current) stopRecording();
    else void startRecording();
  }

  function cycleFlash() {
    setFlash((f) => {
      if (f === 'off') return 'auto';
      if (f === 'auto') return 'torch';
      return 'off';
    });
  }

  async function onUpload() {
    if (recordingRef.current) return;
    if (mediaMode === 'image') {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        quality: 0.8,
      });
      if (!result.canceled && result.assets[0]?.uri) {
        goToPreview(result.assets[0].uri, false);
      }
    } else {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['videos'],
      });
      if (!result.canceled && result.assets[0]?.uri) {
        goToPreview(result.assets[0].uri, true);
      }
    }
  }

  function onBack() {
    if (recordingRef.current) stopRecording();
    if (router.canDismiss()) router.dismiss();
    else if (router.canGoBack()) router.back();
  }

  const flashIcon =
    flash === 'off'
      ? require('../../assets/images/ic_falsh_off.png')
      : flash === 'auto'
        ? require('../../assets/images/ic_falsh_auto.png')
        : require('../../assets/images/ic_flash_on.png');

  const mediaIcon =
    mediaMode === 'image'
      ? require('../../assets/images/video.png')
      : require('../../assets/images/image.png');

  const timeLabel =
    recordedSeconds < 10 ? `00:0${recordedSeconds}` : `00:${recordedSeconds}`;

  const bottomPad = Math.max(insets.bottom, 8);

  if (!camPerm) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={Brand.primary} />
      </View>
    );
  }

  if (!camPerm.granted) {
    return (
      <SafeAreaView style={styles.center}>
        <Text style={styles.permText}>Camera access is needed to record a reply.</Text>
        <Pressable style={styles.permBtn} onPress={requestCamPerm}>
          <Text style={styles.permBtnText}>Allow Camera</Text>
        </Pressable>
        <Pressable onPress={onBack} style={{ marginTop: 16 }}>
          <Text style={{ color: Brand.white }}>Go back</Text>
        </Pressable>
      </SafeAreaView>
    );
  }

  return (
    <View style={styles.root}>
      {/* Flutter: black Container + CameraPreview fill */}
      <CameraView
        ref={cameraRef}
        style={StyleSheet.absoluteFill}
        facing={facing}
        mode={mediaMode === 'video' ? 'video' : 'picture'}
        flash={flash === 'torch' ? 'off' : flash}
        enableTorch={flash === 'torch'}
        mute={false}
        active
        videoQuality="480p"
        onCameraReady={() => setReady(true)}
        onMountError={(e) =>
          Alert.alert('Camera', e.message ?? 'Failed to start camera')
        }
      />

      {!ready ? (
        <View style={styles.loadingOverlay} pointerEvents="none">
          <ActivityIndicator color={Brand.white} size="large" />
        </View>
      ) : null}

      {/* Flutter customAppBarTransparent — Create Video, marginTop 25 */}
      <View style={[styles.topBar, { top: insets.top + 25 }]} pointerEvents="box-none">
        <Pressable style={styles.circleBtn} hitSlop={12} onPress={onBack}>
          <MaterialIcons name="arrow-back-ios-new" size={15} color={Brand.primaryIconColor} />
        </Pressable>
        <Text style={styles.title}>Create Video</Text>
        <View style={styles.topBarSpacer} />
      </View>

      {/* Flutter _topToggleOptions: left 20, top 200 */}
      <View style={[styles.sideOptions, { top: 200 + insets.top }]}>
        <Pressable style={styles.sideBtn} onPress={() => setFacing((f) => (f === 'back' ? 'front' : 'back'))}>
          <Image
            source={require('../../assets/images/ic_flip.png')}
            style={styles.sideIcon}
            resizeMode="contain"
          />
        </Pressable>
        <View style={styles.sideGap} />
        <Pressable style={styles.sideBtn} onPress={cycleFlash}>
          <Image source={flashIcon} style={styles.sideIcon} resizeMode="contain" />
        </Pressable>
        {!recording ? (
          <>
            <View style={styles.sideGap} />
            <Pressable
              style={styles.sideBtn}
              onPress={() => setMediaMode((m) => (m === 'video' ? 'image' : 'video'))}
            >
              <Image source={mediaIcon} style={styles.sideIcon} resizeMode="contain" />
            </Pressable>
          </>
        ) : null}
      </View>

      {/* Flutter _captureButton: bottom 30, timer above shutter */}
      <View style={[styles.captureWrap, { bottom: 30 + bottomPad }]}>
        {mediaMode === 'video' ? (
          <Text style={styles.timerText}>{timeLabel}</Text>
        ) : (
          <View style={{ height: 20 }} />
        )}
        <Pressable onPress={onPressShutter} disabled={!ready}>
          <View style={styles.shutterOuter}>
            <View style={styles.shutterBlack}>
              <View
                style={[
                  styles.shutterInner,
                  {
                    backgroundColor: mediaMode === 'image' ? Brand.white : SHUTTER_ORANGE,
                    margin: paddingValue,
                  },
                ]}
              />
            </View>
          </View>
        </Pressable>
      </View>

      {/* Flutter Upload: bottom 50, right 40 */}
      {!recording ? (
        <Pressable
          style={[styles.upload, { bottom: 50 + bottomPad }]}
          onPress={onUpload}
        >
          <Image
            source={require('../../assets/images/ic_upload.png')}
            style={styles.uploadIcon}
            resizeMode="contain"
          />
          <Text style={styles.uploadLabel}>Upload</Text>
        </Pressable>
      ) : null}

      {/* Flutter 30/45/60: bottom 45, left 20 */}
      {!recording && mediaMode === 'video' ? (
        <View style={[styles.timePicker, { bottom: 45 + bottomPad }]}>
          {(['30', '45', '60'] as const).map((t) => {
            const n = Number(t);
            const active = selectedTime === n;
            return (
              <Pressable
                key={t}
                onPress={() => setSelectedTime(n)}
                style={[styles.timeChip, active && styles.timeChipActive]}
              >
                <Text
                  style={[
                    styles.timeChipText,
                    active && styles.timeChipTextActive,
                    { fontSize: active ? 18 : 14 },
                  ]}
                >
                  {t}
                </Text>
              </Pressable>
            );
          })}
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#000' },
  center: {
    flex: 1,
    backgroundColor: '#000',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  loadingOverlay: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0,0,0,0.25)',
    zIndex: 5,
  },
  permText: { color: Brand.white, textAlign: 'center', marginBottom: 16 },
  permBtn: {
    backgroundColor: Brand.primary,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 10,
  },
  permBtnText: { color: Brand.white, fontWeight: '600' },
  topBar: {
    position: 'absolute',
    left: 0,
    right: 0,
    height: 56,
    zIndex: 30,
    elevation: 30,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  topBarSpacer: { width: 44, height: 44, margin: 8 },
  // Flutter transparent app bar back: white circle, grey border, black icon
  circleBtn: {
    margin: 8,
    width: 44,
    height: 44,
    borderRadius: 22,
    borderWidth: 1,
    borderColor: '#9E9E9E',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Brand.white,
  },
  title: {
    flex: 1,
    textAlign: 'center',
    color: Brand.white,
    fontSize: 18,
    fontWeight: '700',
    fontFamily: 'SF-Pro-Display',
  },
  sideOptions: {
    position: 'absolute',
    left: 20,
    zIndex: 30,
    elevation: 30,
    alignItems: 'center',
  },
  sideGap: { height: 48 },
  sideBtn: {
    backgroundColor: Brand.white,
    borderRadius: 8,
    paddingHorizontal: 5,
    paddingVertical: 10,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sideIcon: { width: 25, height: 25, tintColor: '#9E9E9E' },
  captureWrap: {
    position: 'absolute',
    left: 0,
    right: 0,
    zIndex: 30,
    elevation: 30,
    alignItems: 'center',
  },
  timerText: {
    color: Brand.white,
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 8,
  },
  shutterOuter: {
    width: 75,
    height: 75,
    borderRadius: 40,
    backgroundColor: Brand.white,
    padding: 5,
  },
  shutterBlack: {
    flex: 1,
    borderRadius: 40,
    backgroundColor: '#000',
    overflow: 'hidden',
  },
  shutterInner: {
    flex: 1,
    borderRadius: 40,
  },
  upload: {
    position: 'absolute',
    right: 40,
    zIndex: 30,
    elevation: 30,
    alignItems: 'center',
  },
  uploadIcon: { width: 30, height: 30 },
  uploadLabel: {
    color: Brand.white,
    fontSize: 12,
    fontWeight: '500',
    marginTop: 4,
  },
  timePicker: {
    position: 'absolute',
    left: 20,
    zIndex: 30,
    elevation: 30,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.25)',
    borderRadius: 50,
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  timeChip: {
    borderRadius: 100,
    padding: 5,
    marginHorizontal: 4,
  },
  timeChipActive: { backgroundColor: Brand.white },
  timeChipText: { color: Brand.white, fontWeight: '500' },
  timeChipTextActive: { color: Brand.black },
});
