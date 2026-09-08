import {
  useAppTourStore,
  type TourStepId,
} from '@/store/appTourStore';
import React, { useCallback, useEffect, useRef } from 'react';
import {
  View,
  type LayoutChangeEvent,
  type StyleProp,
  type ViewStyle,
} from 'react-native';

type Props = {
  id: TourStepId;
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  /** Only register when true (e.g. active feed item). Default true. */
  active?: boolean;
};

/** Registers on-screen rect for the app tour spotlight (Flutter Showcase child). */
export function AppTourTarget({ id, children, style, active = true }: Props) {
  const ref = useRef<View>(null);
  const registerTarget = useAppTourStore((s) => s.registerTarget);
  const remeasureEpoch = useAppTourStore((s) => s.remeasureEpoch);
  const running = useAppTourStore((s) => s.running);

  const measure = useCallback(() => {
    if (!active || running) return;
    ref.current?.measureInWindow((x, y, width, height) => {
      if (width <= 0 || height <= 0) return;
      registerTarget(id, { x, y, width, height });
    });
  }, [active, id, registerTarget, running]);

  useEffect(() => {
    if (!active) {
      if (!running) registerTarget(id, null);
      return;
    }
    if (running) return;
    measure();
    const t = setTimeout(measure, 100);
    return () => clearTimeout(t);
  }, [active, id, measure, registerTarget, remeasureEpoch, running]);

  useEffect(() => {
    return () => {
      if (!useAppTourStore.getState().running) {
        registerTarget(id, null);
      }
    };
  }, [id, registerTarget]);

  function onLayout(_e: LayoutChangeEvent) {
    measure();
  }

  return (
    <View ref={ref} collapsable={false} style={style} onLayout={onLayout}>
      {children}
    </View>
  );
}
