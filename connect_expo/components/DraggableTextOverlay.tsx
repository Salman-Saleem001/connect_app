import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { Brand } from '@/constants/Colors';
import React, { useEffect, useMemo, useRef } from 'react';
import {
  Keyboard,
  PanResponder,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
  type TextInput as TextInputType,
} from 'react-native';

export type TextOverlayStyle = {
  text: string;
  color: string;
  fontSize: number;
  bold: boolean;
  x: number;
  y: number;
};

type Props = {
  value: TextOverlayStyle;
  editing: boolean;
  bounds: { width: number; height: number };
  onChange: (next: Partial<TextOverlayStyle>) => void;
  onRequestEdit: () => void;
  onDone: () => void;
};

const MIN_SIZE = 14;
const MAX_SIZE = 72;
const BOX_MIN_W = 120;

export function DraggableTextOverlay({
  value,
  editing,
  bounds,
  onChange,
  onRequestEdit,
  onDone,
}: Props) {
  const valueRef = useRef(value);
  const boundsRef = useRef(bounds);
  const onChangeRef = useRef(onChange);
  const startRef = useRef({ x: value.x, y: value.y });
  const inputRef = useRef<TextInputType>(null);

  useEffect(() => {
    valueRef.current = value;
  }, [value]);
  useEffect(() => {
    boundsRef.current = bounds;
  }, [bounds]);
  useEffect(() => {
    onChangeRef.current = onChange;
  }, [onChange]);

  function finishEditing() {
    inputRef.current?.blur();
    Keyboard.dismiss();
    onDone();
  }

  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: (_, g) =>
          Math.abs(g.dx) > 2 || Math.abs(g.dy) > 2,
        onPanResponderGrant: () => {
          startRef.current = {
            x: valueRef.current.x,
            y: valueRef.current.y,
          };
        },
        onPanResponderMove: (_, g) => {
          const b = boundsRef.current;
          const maxX = Math.max(0, b.width - BOX_MIN_W);
          const maxY = Math.max(0, b.height - 48);
          const x = Math.min(Math.max(0, startRef.current.x + g.dx), maxX);
          const y = Math.min(Math.max(0, startRef.current.y + g.dy), maxY);
          onChangeRef.current({ x, y });
        },
      }),
    [],
  );

  const textStyle = {
    color: value.color,
    fontSize: value.fontSize,
    fontWeight: (value.bold ? '700' : '500') as '700' | '500',
    textAlign: 'center' as const,
    textShadowColor: 'rgba(0,0,0,0.75)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
  };

  if (!editing && !value.text.trim()) return null;

  return (
    <>
      {editing ? (
        <Pressable style={styles.dismissScrim} onPress={finishEditing} />
      ) : null}
      <View style={[styles.box, { left: value.x, top: value.y }]}>
        {editing ? (
          <>
            <View style={styles.dragBar} {...panResponder.panHandlers}>
              <MaterialIcons name="drag-indicator" size={22} color={Brand.white} />
              <Text style={styles.dragHint}>Drag</Text>
            </View>
            <TextInput
              ref={inputRef}
              autoFocus
              value={value.text}
              onChangeText={(text) => onChange({ text })}
              placeholder="Type something…"
              placeholderTextColor="rgba(255,255,255,0.5)"
              style={[styles.input, textStyle]}
              multiline
              textAlign="center"
              blurOnSubmit
              returnKeyType="done"
              onSubmitEditing={finishEditing}
            />
            <View style={styles.toolbar}>
              <Pressable
                style={styles.toolBtn}
                onPress={() =>
                  onChange({
                    fontSize: Math.max(MIN_SIZE, value.fontSize - 4),
                  })
                }
              >
                <MaterialIcons name="remove" size={20} color={Brand.black} />
              </Pressable>
              <Text style={styles.sizeLabel}>{Math.round(value.fontSize)}</Text>
              <Pressable
                style={styles.toolBtn}
                onPress={() =>
                  onChange({
                    fontSize: Math.min(MAX_SIZE, value.fontSize + 4),
                  })
                }
              >
                <MaterialIcons name="add" size={20} color={Brand.black} />
              </Pressable>
              <Pressable
                style={[styles.toolBtn, value.bold && styles.toolBtnActive]}
                onPress={() => onChange({ bold: !value.bold })}
              >
                <Text style={[styles.boldLabel, value.bold && styles.boldLabelActive]}>
                  B
                </Text>
              </Pressable>
              <Pressable style={styles.doneBtn} onPress={finishEditing}>
                <Text style={styles.doneLabel}>Done</Text>
              </Pressable>
            </View>
          </>
        ) : (
          <View {...panResponder.panHandlers}>
            <Pressable onPress={onRequestEdit}>
              <Text style={[styles.display, textStyle]}>{value.text}</Text>
            </Pressable>
          </View>
        )}
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  dismissScrim: {
    ...StyleSheet.absoluteFill,
    zIndex: 20,
  },
  box: {
    position: 'absolute',
    zIndex: 25,
    maxWidth: '85%',
    minWidth: BOX_MIN_W,
    alignItems: 'center',
  },
  dragBar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    alignSelf: 'center',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 14,
    backgroundColor: 'rgba(0,0,0,0.55)',
    marginBottom: 8,
  },
  dragHint: {
    color: Brand.white,
    fontSize: 12,
    fontWeight: '600',
  },
  input: {
    width: '100%',
    minWidth: BOX_MIN_W,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  display: {
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  toolbar: {
    marginTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: Brand.white,
    borderRadius: 22,
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderWidth: 1,
    borderColor: '#000',
  },
  toolBtn: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#F2F2F2',
  },
  toolBtnActive: {
    backgroundColor: Brand.primary,
  },
  sizeLabel: {
    minWidth: 24,
    textAlign: 'center',
    fontWeight: '700',
    color: Brand.black,
    fontSize: 13,
  },
  boldLabel: {
    fontSize: 16,
    fontWeight: '800',
    color: Brand.black,
  },
  boldLabelActive: {
    color: Brand.white,
  },
  doneBtn: {
    marginLeft: 4,
    paddingHorizontal: 12,
    height: 34,
    borderRadius: 17,
    backgroundColor: Brand.black,
    alignItems: 'center',
    justifyContent: 'center',
  },
  doneLabel: {
    color: Brand.white,
    fontWeight: '700',
    fontSize: 13,
  },
});
