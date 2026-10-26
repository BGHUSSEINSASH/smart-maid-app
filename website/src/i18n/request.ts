import { getRequestConfig } from 'next-intl/server';
export default getRequestConfig(async ({ requestLocale }) => {
  const locale = (await requestLocale) ?? 'ar';
  const messages = locale === 'en'
    ? (await import('../../messages/en.json')).default
    : (await import('../../messages/ar.json')).default;
  return { locale, messages };
});
