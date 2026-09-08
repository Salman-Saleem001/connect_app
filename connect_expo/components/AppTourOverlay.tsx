/**
 * Flutter Showcase overlay — same Skip/Next rules as `AppShowCaseWidget`:
 * - Skip hidden on like (first)
 * - Next hidden on profile (last) → only Skip remains
 *
 * Target rects are frozen when the tour starts so remesauring under a Modal
 * cannot jump the spotlight top↔bottom (flicker).
 */
import { Brand } from '@/constants/Colors';
import {
  TOUR_STEPS,
  useAppTourStore,
  type TourPlacement,
  type TargetRect,
} from '@/store/appTourStore';
import React, { useEffect, useMemo } from 'react';
import {
  Dimensions,
  Modal,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';

const PAD = 8;
const TOOLTIP_MAX_W = 280;
const TOOLTIP_EST_H = 150;

function tooltipStyle(rect: TargetRect, placement: TourPlacement) {
  const { width: sw, height: sh } = Dimensions.get('window');
  const cx = rect.x + rect.width / 2;
  const gap = 12;

  let top = rect.y;
  let left = Math.min(
    Math.max(12, cx - TOOLTIP_MAX_W / 2),
    sw - TOOLTIP_MAX_W - 12,
  );

  switch (placement) {
    case 'right':
      left = Math.min(rect.x + rect.width + PAD + gap, sw - TOOLTIP_MAX_W - 12);
      top = Math.max(16, Math.min(rect.y, sh - TOOLTIP_EST_H - 16));
      break;
    case 'left':
      left = Math.max(12, rect.x - TOOLTIP_MAX_W - gap);
      top = Math.max(16, Math.min(rect.y, sh - TOOLTIP_EST_H - 16));
      break;
    case 'bottom':
      top = rect.y + rect.height + PAD + gap;
      if (top + TOOLTIP_EST_H > sh - 16) {
        top = Math.max(16, rect.y - TOOLTIP_EST_H - gap);
      }
      break;
    case 'top':
    default:
      top = rect.y - TOOLTIP_EST_H - gap;
      if (top < 16) {
        top = Math.min(rect.y + rect.height + gap, sh - TOOLTIP_EST_H - 16);
      }
      break;
  }

  top = Math.min(Math.max(16, top), sh - TOOLTIP_EST_H - 16);
  left = Math.min(Math.max(12, left), sw - TOOLTIP_MAX_W - 12);

  return { top, left, maxWidth: TOOLTIP_MAX_W };
}

export function AppTourOverlay() {
  const running = useAppTourStore((s) => s.running);
  const stepIndex = useAppTourStore((s) => s.stepIndex);
  const frozenTargets = useAppTourStore((s) => s.frozenTargets);
  const next = useAppTourStore((s) => s.next);
  const skip = useAppTourStore((s) => s.skip);

  const step = TOUR_STEPS[stepIndex];
  const rect = step && frozenTargets ? frozenTargets[step.id] : undefined;

  const isLikeStep = step?.id === 'like';
  const isProfileStep = step?.id === 'profileTab';

  const hole = useMemo(() => {
    if (!rect) return null;
    const size = Math.max(rect.width, rect.height) + PAD * 2;
    const cx = rect.x + rect.width / 2;
    const cy = rect.y + rect.height / 2;
    return {
      left: cx - size / 2,
      top: cy - size / 2,
      width: size,
      height: size,
      borderRadius: size / 2,
    };
  }, [rect]);

  const tipPos = useMemo(() => {
    if (!rect || !step) return null;
    return tooltipStyle(rect, step.placement);
  }, [rect, step]);

  // Skip steps that have no frozen target (e.g. empty feed) without flashing
  useEffect(() => {
    if (!running || !step || !frozenTargets) return;
    if (frozenTargets[step.id]) return;
    const t = setTimeout(() => next(), 50);
    return () => clearTimeout(t);
  }, [running, step, frozenTargets, next, stepIndex]);

  return (
    <Modal
      visible={running && !!step}
      transparent
      animationType="none"
      statusBarTranslucent
      onRequestClose={skip}
    >
      <View style={styles.root} pointerEvents="box-none">
        {hole ? (
          <>
            <View
              pointerEvents="none"
              style={[
                styles.dim,
                { top: 0, left: 0, right: 0, height: Math.max(0, hole.top) },
              ]}
            />
            <View
              pointerEvents="none"
              style={[
                styles.dim,
                {
                  top: hole.top + hole.height,
                  left: 0,
                  right: 0,
                  bottom: 0,
                },
              ]}
            />
            <View
              pointerEvents="none"
              style={[
                styles.dim,
                {
                  top: hole.top,
                  left: 0,
                  width: Math.max(0, hole.left),
                  height: hole.height,
                },
              ]}
            />
            <View
              pointerEvents="none"
              style={[
                styles.dim,
                {
                  top: hole.top,
                  left: hole.left + hole.width,
                  right: 0,
                  height: hole.height,
                },
              ]}
            />
            <View
              pointerEvents="none"
              style={[
                styles.holeRing,
                {
                  top: hole.top,
                  left: hole.left,
                  width: hole.width,
                  height: hole.height,
                  borderRadius: hole.borderRadius,
                },
              ]}
            />
          </>
        ) : (
          <View style={[styles.dim, StyleSheet.absoluteFillObject]} />
        )}

        {tipPos && step ? (
          <View style={[styles.tooltip, tipPos]}>
            <Text style={styles.title}>{step.title}</Text>
            <Text style={styles.description}>{step.description}</Text>
            <View style={styles.actions}>
              {!isLikeStep ? (
                <Pressable style={styles.actionBtn} onPress={skip}>
                  <Text style={styles.actionText}>SKIP</Text>
                </Pressable>
              ) : (
                <View style={{ flex: 1 }} />
              )}
              {!isProfileStep ? (
                <Pressable style={styles.actionBtn} onPress={next}>
                  <Text style={styles.actionText}>NEXT</Text>
                </Pressable>
              ) : null}
            </View>
          </View>
        ) : null}
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
  dim: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0.4)',
  },
  holeRing: {
    position: 'absolute',
    borderWidth: 2,
    borderColor: Brand.primary,
  },
  tooltip: {
    position: 'absolute',
    backgroundColor: Brand.primary,
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingTop: 12,
    paddingBottom: 10,
    shadowColor: '#000',
    shadowOpacity: 0.25,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 8,
  },
  title: {
    color: Brand.white,
    fontSize: 16,
    fontWeight: '700',
    textAlign: 'left',
    paddingHorizontal: 4,
  },
  description: {
    color: Brand.white,
    fontSize: 13,
    lineHeight: 18,
    marginTop: 8,
    paddingHorizontal: 2,
    paddingBottom: 4,
  },
  actions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 8,
    marginTop: 10,
  },
  actionBtn: {
    backgroundColor: Brand.white,
    borderRadius: 6,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  actionText: {
    color: Brand.primary,
    fontSize: 12,
    fontWeight: '700',
  },
});
