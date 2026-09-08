import type { InboxRoute } from '@/store/notificationStore';
import { router } from 'expo-router';

/** Open the screen linked from an inbox notification. */
export function navigateInboxRoute(route?: InboxRoute | null) {
  if (!route) {
    router.push('/notifications');
    return;
  }

  switch (route.type) {
    case 'chat':
      router.push({
        pathname: '/chat/[videoId]',
        params: {
          videoId: String(route.videoId),
          secondUserId: route.secondUserId,
          userName: route.userName ?? '',
          userAvatar: route.userAvatar ?? '',
          chatsId: route.chatsId ?? '',
          senderId: route.senderId ?? '',
          receiverId: route.receiverId ?? '',
          myStatus: route.myStatus ?? '',
          otherStatus: route.otherStatus ?? '',
          messageData: route.messageData ?? '',
          description: route.description ?? '',
          tags: route.tags ?? '',
          bio: route.bio ?? '',
        },
      });
      return;
    case 'followRequests':
      router.push({
        pathname: '/profile/follow-requests',
        params: {
          videoId: String(route.videoId),
          thumbnail: route.thumbnail ?? '',
          name: route.name ?? '',
          viewsCount: String(route.viewsCount ?? 0),
        },
      });
      return;
    case 'chats':
      router.push('/(tabs)/chats');
      return;
    case 'home':
      router.push('/(tabs)');
      return;
    case 'profile':
      router.push('/(tabs)/profile');
      return;
    default:
      router.push('/notifications');
  }
}
