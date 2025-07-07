export function formatTime(date: Date) {
  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  const { locale } = useI18n();
  const rtf = new Intl.RelativeTimeFormat(locale.value, { numeric: 'auto' });

  if (Math.abs(diffInSeconds) < 60) {
    return rtf.format(-diffInSeconds, 'second');
  }
  if (Math.abs(diffInSeconds) < 3600) {
    return rtf.format(-Math.floor(diffInSeconds / 60), 'minute');
  }
  if (Math.abs(diffInSeconds) < 86400) {
    return rtf.format(-Math.floor(diffInSeconds / 3600), 'hour');
  }
  if (Math.abs(diffInSeconds) < 604800) {
    return rtf.format(-Math.floor(diffInSeconds / 86400), 'day');
  }

  return date.toLocaleDateString(locale.value, { month: 'short', day: 'numeric' });
}
