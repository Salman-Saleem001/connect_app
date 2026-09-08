import { useAuthStore } from '@/store/authStore';
import { Redirect, Stack } from 'expo-router';

export default function ProfileLayout() {
  const token = useAuthStore((s) => s.token);

  // Settings/profile stack lives outside tabs — gate auth here too
  if (!token) {
    return <Redirect href="/(auth)/walkthrough" />;
  }

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="settings" />
      <Stack.Screen name="edit" />
      <Stack.Screen name="blocked" />
      <Stack.Screen name="notifications" />
      <Stack.Screen name="password" />
      <Stack.Screen name="views-stats" />
      <Stack.Screen name="stats/[id]" />
      <Stack.Screen name="follow-requests" />
    </Stack>
  );
}
