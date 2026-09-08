import { AppTourTarget } from '@/components/AppTourTarget';
import { Brand } from '@/constants/Colors';
import { useAuthStore } from '@/store/authStore';
import { useNotificationStore } from '@/store/notificationStore';
import { Redirect, Tabs } from 'expo-router';
import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const TAB_BAR_CONTENT_HEIGHT = 56;

function TabIcon({
  source,
  color,
  label,
  focused,
  badge,
  tourId,
}: {
  source: number;
  color: string;
  label: string;
  focused: boolean;
  badge?: number;
  tourId: 'homeTab' | 'searchTab' | 'chatTab' | 'profileTab';
}) {
  return (
    <AppTourTarget id={tourId}>
      <View style={styles.tabItem}>
        <View>
          <Image source={source} style={[styles.icon, { tintColor: color }]} />
          {badge && badge > 0 ? (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>{badge > 99 ? '99+' : badge}</Text>
            </View>
          ) : null}
        </View>
        <Text style={[styles.label, { color }]} numberOfLines={1}>
          {label}
        </Text>
        <View
          style={[
            styles.underline,
            { backgroundColor: focused ? Brand.primary : 'transparent' },
          ]}
        />
      </View>
    </AppTourTarget>
  );
}

export default function TabLayout() {
  const token = useAuthStore((s) => s.token);
  const badgeCount = useNotificationStore((s) => s.badgeCount);
  const insets = useSafeAreaInsets();

  if (!token) {
    return <Redirect href="/(auth)/walkthrough" />;
  }

  const inactive = 'rgba(0,0,0,0.2)';
  const active = Brand.primary;
  const bottomPad = Math.max(insets.bottom, 8);

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarShowLabel: false,
        tabBarHideOnKeyboard: true,
        tabBarStyle: {
          backgroundColor: '#fff',
          height: TAB_BAR_CONTENT_HEIGHT + bottomPad,
          paddingTop: 0,
          paddingBottom: bottomPad,
          borderTopWidth: StyleSheet.hairlineWidth,
          borderTopColor: Brand.borderLight,
          elevation: 8,
          shadowColor: Brand.border,
          shadowOpacity: 0.2,
          shadowOffset: { width: 0, height: -2 },
          shadowRadius: 5,
        },
        tabBarItemStyle: {
          height: TAB_BAR_CONTENT_HEIGHT,
          justifyContent: 'center',
          alignItems: 'center',
          paddingVertical: 0,
        },
        tabBarIconStyle: {
          width: '100%',
          height: TAB_BAR_CONTENT_HEIGHT,
          marginTop: 0,
          marginBottom: 0,
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              tourId="homeTab"
              source={require('../../assets/images/ic_home.png')}
              color={focused ? active : inactive}
              label="Home"
              focused={focused}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: 'Search',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              tourId="searchTab"
              source={require('../../assets/images/ic_search.png')}
              color={focused ? active : inactive}
              label="Search"
              focused={focused}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="chats"
        options={{
          title: 'Chats',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              tourId="chatTab"
              source={require('../../assets/images/ic_message.png')}
              color={focused ? active : inactive}
              label="Chats"
              focused={focused}
              badge={badgeCount}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ focused }) => (
            <TabIcon
              tourId="profileTab"
              source={require('../../assets/images/ic_person.png')}
              color={focused ? active : inactive}
              label="Profile"
              focused={focused}
            />
          ),
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  tabItem: {
    width: 72,
    height: TAB_BAR_CONTENT_HEIGHT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  icon: {
    width: 24,
    height: 24,
    resizeMode: 'contain',
  },
  label: {
    fontSize: 11,
    marginTop: 3,
    textAlign: 'center',
  },
  underline: {
    marginTop: 3,
    width: 28,
    height: 3,
    borderRadius: 2,
  },
  badge: {
    position: 'absolute',
    top: -6,
    right: -10,
    minWidth: 16,
    height: 16,
    borderRadius: 8,
    paddingHorizontal: 4,
    backgroundColor: Brand.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  badgeText: {
    color: Brand.white,
    fontSize: 10,
    fontWeight: '700',
  },
});
