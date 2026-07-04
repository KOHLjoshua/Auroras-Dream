// In the Hand of Dante — Service Worker
// Cache strategy: cache-first for static assets, network-first for API calls

const CACHE = 'aurora-v3';
const STATIC = [
  '/',
  '/index.html',
  '/manifest.json',
  '/config.js',
  'https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,300;0,400;0,600;1,300;1,400;1,600&family=Caveat:wght@400;600;700&family=Playfair+Display:ital,wght@0,400;1,400&family=IM+Fell+English:ital@0;1&family=Special+Elite&family=Cormorant+Garamond:ital,wght@0,300;1,300&family=Philosopher:ital@0;1&family=Lora:ital,wght@0,400;1,400&family=Raleway:wght@100;200&display=swap'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(STATIC)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // Skip non-GET and Supabase API calls (always network)
  if (e.request.method !== 'GET') return;
  if (url.hostname.includes('supabase.co')) return;

  // Cache-first for same-origin assets + fonts
  e.respondWith(
    caches.match(e.request).then(cached => {
      if (cached) return cached;
      return fetch(e.request).then(res => {
        if (res.ok && (url.origin === location.origin || url.hostname.includes('fonts.g'))) {
          const clone = res.clone();
          caches.open(CACHE).then(c => c.put(e.request, clone));
        }
        return res;
      }).catch(() => caches.match('/index.html'));
    })
  );
});
