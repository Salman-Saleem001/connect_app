/**
 * Flutter `TakeTour` dialog — shown once after first login on a fresh install.
 */
import { Brand } from '@/constants/Colors';
import { useAppTourStore } from '@/store/appTourStore';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import React, { useState } from 'react';
import {
  Modal,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';

export function TakeTourModal() {
  const visible = useAppTourStore((s) => s.welcomeVisible);
  const hideWelcome = useAppTourStore((s) => s.hideWelcome);
  const startTour = useAppTourStore((s) => s.startTour);
  const markTourSeen = useAppTourStore((s) => s.markTourSeen);
  const setSkippedForever = useAppTourStore((s) => s.setSkippedForever);
  const [dontAsk, setDontAsk] = useState(false);

  async function toggleDontAsk() {
    const next = !dontAsk;
    setDontAsk(next);
    await setSkippedForever(next);
  }

  function onContinue() {
    // Mark first-time tour as offered, then start showcase
    void markTourSeen();
    hideWelcome();
    useAppTourStore.getState().bumpRemeasure();
    setTimeout(() => {
      useAppTourStore.getState().bumpRemeasure();
      setTimeout(() => {
        startTour();
      }, 180);
    }, 200);
  }

  function onClose() {
    // Closing counts as first-time offer done — never ask again on this install
    void markTourSeen();
    hideWelcome();
  }

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      statusBarTranslucent
      onRequestClose={onClose}
    >
      <View style={styles.backdrop}>
        <View style={styles.card}>
          <Pressable style={styles.close} onPress={onClose} hitSlop={10}>
            <MaterialIcons name="close" size={22} color={Brand.primary} />
          </Pressable>

          <Text style={styles.title}>Let&apos;s take a quick tour !</Text>
          <Text style={styles.sub}>
            Here are some helpful tips to get you started with the Connect Giant app
          </Text>

          <Pressable style={styles.checkRow} onPress={() => void toggleDontAsk()}>
            <View style={styles.checkbox}>
              {dontAsk ? (
                <MaterialIcons name="done" size={16} color={Brand.primary} />
              ) : (
                <View style={styles.checkboxEmpty} />
              )}
            </View>
            <Text style={styles.checkLabel}>Don&apos;t ask again</Text>
          </Pressable>

          <Pressable style={styles.continueBtn} onPress={onContinue}>
            <Text style={styles.continueText}>Continue</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.45)',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  card: {
    width: '100%',
    backgroundColor: Brand.white,
    borderRadius: 12,
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 24,
  },
  close: {
    alignSelf: 'flex-end',
    padding: 4,
  },
  title: {
    marginTop: 4,
    fontSize: 20,
    fontWeight: '700',
    color: Brand.primary,
  },
  sub: {
    marginTop: 10,
    fontSize: 14,
    lineHeight: 20,
    color: Brand.bgGrey,
  },
  checkRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginTop: 16,
  },
  checkbox: {
    width: 22,
    height: 22,
    borderWidth: 2,
    borderColor: Brand.primary,
    borderRadius: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxEmpty: {
    width: 12,
    height: 12,
  },
  checkLabel: {
    fontSize: 14,
    color: Brand.txtGrey,
  },
  continueBtn: {
    marginTop: 18,
    height: 50,
    borderRadius: 8,
    backgroundColor: Brand.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  continueText: {
    fontSize: 20,
    fontWeight: '700',
    color: Brand.white,
  },
});
