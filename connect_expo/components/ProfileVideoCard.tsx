/**
 * Profile video grid card — Flutter `BuildVideoCard`.
 * Message icon → Follow Requests; ⋮ → Stats / Delete; tap media → play.
 */
import { Brand } from '@/constants/Colors';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import React, { useState } from 'react';
import {
  ActionSheetIOS,
  Alert,
  Image,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';

type Props = {
  thumbnail?: string | null;
  videoUrl?: string | null;
  width: number;
  height: number;
  onOpen: () => void;
  onFollowRequests: () => void;
  onStats: () => void;
  onDelete: () => void;
};

export function ProfileVideoCard({
  thumbnail,
  width,
  height,
  onOpen,
  onFollowRequests,
  onStats,
  onDelete,
}: Props) {
  const [menuOpen, setMenuOpen] = useState(false);
  const abs = !!thumbnail && /^https?:\/\//i.test(thumbnail);

  function openMenu() {
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        {
          options: ['Cancel', 'Stats', 'Delete Video'],
          destructiveButtonIndex: 2,
          cancelButtonIndex: 0,
        },
        (i) => {
          if (i === 1) onStats();
          if (i === 2) onDelete();
        },
      );
      return;
    }
    setMenuOpen(true);
  }

  return (
    <View style={{ width, height, margin: 2 }}>
      <View style={[styles.card, { width, height }]}>
        <Pressable onPress={onOpen} style={StyleSheet.absoluteFill}>
          {abs ? (
            <Image source={{ uri: thumbnail! }} style={styles.thumb} resizeMode="cover" />
          ) : (
            <View style={[styles.thumb, styles.fallback]}>
              <MaterialIcons name="videocam" size={36} color={Brand.primary} />
            </View>
          )}
        </Pressable>

        {/* Flutter: message icon opens FollowRequestsScreen for this videoId */}
        <View style={styles.actions} pointerEvents="box-none">
          <Pressable
            onPress={onFollowRequests}
            hitSlop={10}
            style={styles.iconBtn}
            accessibilityRole="button"
            accessibilityLabel="Follow requests"
          >
            <Image
              source={require('../assets/images/video_message_icon.png')}
              style={styles.msgIcon}
              tintColor={Brand.white}
            />
          </Pressable>
          <Pressable
            onPress={openMenu}
            hitSlop={10}
            style={styles.iconBtn}
            accessibilityRole="button"
            accessibilityLabel="More options"
          >
            <MaterialIcons name="more-vert" size={22} color={Brand.white} />
          </Pressable>
        </View>
      </View>

      <Modal visible={menuOpen} transparent animationType="fade" onRequestClose={() => setMenuOpen(false)}>
        <Pressable style={styles.menuBackdrop} onPress={() => setMenuOpen(false)}>
          <View style={styles.menuSheet}>
            <Pressable
              style={styles.menuRow}
              onPress={() => {
                setMenuOpen(false);
                onStats();
              }}
            >
              <MaterialIcons name="query-stats" size={20} color={Brand.textPrimary} />
              <Text style={styles.menuText}>Stats</Text>
            </Pressable>
            <Pressable
              style={styles.menuRow}
              onPress={() => {
                setMenuOpen(false);
                Alert.alert('Delete Video', 'Are you sure you want to delete this video?', [
                  { text: 'Cancel', style: 'cancel' },
                  { text: 'Delete', style: 'destructive', onPress: onDelete },
                ]);
              }}
            >
              <MaterialIcons name="delete" size={20} color={Brand.primary} />
              <Text style={[styles.menuText, { color: Brand.primary }]}>Delete Video</Text>
            </Pressable>
          </View>
        </Pressable>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 5,
    overflow: 'hidden',
    backgroundColor: Brand.bgGrey,
  },
  thumb: { width: '100%', height: '100%' },
  fallback: { alignItems: 'center', justifyContent: 'center' },
  actions: {
    position: 'absolute',
    left: 2,
    right: 2,
    bottom: 2,
    zIndex: 2,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  iconBtn: {
    padding: 6,
    backgroundColor: 'rgba(0,0,0,0.25)',
    borderRadius: 16,
  },
  msgIcon: { width: 22, height: 22, resizeMode: 'contain' },
  menuBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.35)',
    justifyContent: 'flex-end',
  },
  menuSheet: {
    backgroundColor: Brand.white,
    borderTopLeftRadius: 14,
    borderTopRightRadius: 14,
    paddingBottom: 28,
    paddingTop: 8,
  },
  menuRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 20,
    paddingVertical: 14,
  },
  menuText: { fontSize: 16, color: Brand.textPrimary },
});
