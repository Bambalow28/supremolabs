// Cloudflare Worker: the CORS proxy for supremolabs.com/marketpulse/personal.
// Deploy:  npx wrangler deploy tool/mp_proxy_worker.js --name mp-proxy
// then paste its URL into the console's "Data source" panel.
// Only the hosts the app reads are allowed, so it cannot be used as an open proxy.
const ALLOW = [
  'aljazeera.com',
  'axios.com',
  'bbci.co.uk',
  'benzinga.com',
  'bloomberg.com',
  'bls.gov',
  'cbsnews.com',
  'census.gov',
  'cnbc.com',
  'dowjones.io',
  'economist.com',
  'eia.gov',
  'europa.eu',
  'federalreserve.gov',
  'foxnews.com',
  'google.com',
  'investing.com',
  'investors.com',
  'nasdaq.com',
  'npr.org',
  'nytimes.com',
  'sec.gov',
  'skynews.com',
  'theguardian.com',
  'yahoo.com',
];
const ORIGINS = ['https://supremolabs.com', 'https://www.supremolabs.com'];

export default {
  async fetch(req) {
    const origin = req.headers.get('origin') || '';
    const okOrigin = ORIGINS.includes(origin) || /^http:\/\/localhost(:\d+)?$/.test(origin);
    const cors = {
      'access-control-allow-origin': okOrigin ? origin : 'https://supremolabs.com',
      'access-control-allow-headers': '*',
      'vary': 'origin',
    };
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
    if (!okOrigin) return new Response('forbidden', { status: 403, headers: cors });
    const target = new URL(req.url).searchParams.get('url');
    let u;
    try { u = new URL(target); } catch { return new Response('bad url', { status: 400, headers: cors }); }
    if (u.protocol !== 'https:' || !ALLOW.some((h) => u.hostname === h || u.hostname.endsWith('.' + h))) {
      return new Response('host not allowed', { status: 403, headers: cors });
    }
    const r = await fetch(u, {
      method: req.method,
      headers: { 'user-agent': req.headers.get('x-forward-ua') || 'Mozilla/5.0', accept: req.headers.get('accept') || '*/*' },
      cf: { cacheTtl: 30 },
    });
    const h = new Headers(r.headers);
    for (const [k, v] of Object.entries(cors)) h.set(k, v);
    return new Response(r.body, { status: r.status, headers: h });
  },
};
