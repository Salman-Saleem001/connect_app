import { Brand } from '@/constants/Colors';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import React from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type Props = {
  visible: boolean;
  mode: 'attach' | 'gallery';
  onClose: () => void;
  onDocument: () => void;
  onGallery: () => void;
  onLocation: () => void;
  onPhotos: () => void;
  onVideos: () => void;
};

export function ChatAttachmentSheet({
  visible,
  mode,
  onClose,
  onDocument,
  onGallery,
  onLocation,
  onPhotos,
  onVideos,
}: Props) {
  const insets = useSafeAreaInsets();

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
      statusBarTranslucent
    >
      <View style={styles.root}>
        <Pressable style={styles.backdrop} onPress={onClose} />
        <View style={[styles.sheet, { paddingBottom: Math.max(insets.bottom, 16) }]}>
          <View style={styles.handle} />
          <Text style={styles.title}>{mode === 'attach' ? 'Attach' : 'Gallery'}</Text>

          {mode === 'attach' ? (
            <>
              <SheetRow
                icon="insert-drive-file"
                color="#FF9800"
                title="Document"
                subtitle="PDF, Word, Excel"
                onPress={onDocument}
              />
              <SheetRow
                icon="photo-library"
                color="#4CAF50"
                title="Gallery"
                subtitle="Photos and videos"
                onPress={onGallery}
              />
              <SheetRow
                icon="location-on"
                color="#F44336"
                title="Location"
                subtitle="Share your location"
                onPress={onLocation}
              />
            </>
          ) : (
            <>
              <SheetRow
                icon="photo"
                color="#4CAF50"
                title="Photos"
                subtitle="Choose images from gallery"
                onPress={onPhotos}
              />
              <SheetRow
                icon="videocam"
                color="#2196F3"
                title="Video"
                subtitle="Choose a video from gallery"
                onPress={onVideos}
              />
            </>
          )}
        </View>
      </View>
    </Modal>
  );
}

function SheetRow({
  icon,
  color,
  title,
  subtitle,
  onPress,
}: {
  icon: React.ComponentProps<typeof MaterialIcons>['name'];
  color: string;
  title: string;
  subtitle: string;
  onPress: () => void;
}) {
  return (
    <Pressable style={styles.row} onPress={onPress}>
      <View style={[styles.iconWrap, { backgroundColor: `${color}1A` }]}>
        <MaterialIcons name={icon} size={22} color={color} />
      </View>
      <View style={styles.rowText}>
        <Text style={styles.rowTitle}>{title}</Text>
        <Text style={styles.rowSub}>{subtitle}</Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, justifyContent: 'flex-end' },
  backdrop: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(0,0,0,0.4)' },
  sheet: {
    backgroundColor: Brand.white,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 12,
    paddingTop: 10,
  },
  handle: {
    alignSelf: 'center',
    width: 40,
    height: 4,
    borderRadius: 2,
    backgroundColor: '#E0E0E0',
    marginBottom: 10,
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
    color: Brand.black,
    textAlign: 'center',
    marginBottom: 8,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 8,
    gap: 12,
  },
  iconWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowText: { flex: 1 },
  rowTitle: { fontSize: 16, fontWeight: '600', color: Brand.black },
  rowSub: { fontSize: 12, color: Brand.txtGrey, marginTop: 2 },
});
