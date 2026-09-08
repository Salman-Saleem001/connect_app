/**
 * Chat time helpers — mirrors Flutter `getTime` on chat_screen.dart.
 */
export function parseMessageDate(timestamp: unknown): Date | null {
  if (timestamp == null) return null;
  if (timestamp instanceof Date) {
    return Number.isNaN(timestamp.getTime()) ? null : timestamp;
  }
  if (typeof timestamp === 'number') {
    const ms = timestamp < 1e12 ? timestamp * 1000 : timestamp;
    const d = new Date(ms);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  if (typeof timestamp === 'string') {
    const d = new Date(timestamp);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  if (typeof timestamp === 'object') {
    const t = timestamp as {
      toDate?: () => Date;
      seconds?: number;
      _seconds?: number;
    };
    try {
      if (typeof t.toDate === 'function') {
        const d = t.toDate();
        return Number.isNaN(d.getTime()) ? null : d;
      }
    } catch {
      // ignore
    }
    const seconds = t.seconds ?? t._seconds;
    if (typeof seconds === 'number') return new Date(seconds * 1000);
  }
  return null;
}

/** Flutter-style relative time: just Now / N minutes ago / … */
export function formatRelativeChatTime(timestamp: unknown): string {
  const d = parseMessageDate(timestamp);
  if (!d) return '';
  const diffMs = Date.now() - d.getTime();
  const seconds = Math.max(0, Math.floor(diffMs / 1000));
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  if (days > 0) return `${days} days ago`;
  if (hours > 0) return `${hours} hours ago`;
  if (minutes > 0) return `${minutes} minutes ago`;
  return 'just Now';
}
