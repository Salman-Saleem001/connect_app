import { Stack } from 'expo-router';

export default function ChatLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen
        name="[videoId]"
        getId={({ params }) =>
          `chat-${params?.videoId ?? 'x'}-${params?.secondUserId ?? params?.senderId ?? 'u'}`
        }
      />
      <Stack.Screen name="camera" options={{ presentation: 'fullScreenModal' }} />
      <Stack.Screen name="preview" options={{ presentation: 'fullScreenModal' }} />
      <Stack.Screen name="create-post" options={{ presentation: 'fullScreenModal' }} />
      <Stack.Screen name="pick-location" options={{ presentation: 'fullScreenModal' }} />
      <Stack.Screen name="post-success" options={{ presentation: 'fullScreenModal' }} />
      <Stack.Screen name="status" options={{ presentation: 'fullScreenModal' }} />
      <Stack.Screen name="rate" />
      <Stack.Screen name="video" />
      <Stack.Screen name="location" options={{ presentation: 'modal' }} />
    </Stack>
  );
}
