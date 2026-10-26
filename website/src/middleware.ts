import createMiddleware from 'next-intl/middleware';
export default createMiddleware({
  locales: ['ar','en'],
  defaultLocale: 'ar',
  localePrefix: 'always'
});
export const config = {
  // استثناء /app/ (Flutter Web) و /api/ و ملفات Next.js الثابتة
  matcher: ['/((?!api|_next|_vercel|app|.*\\..*).*)']
};
