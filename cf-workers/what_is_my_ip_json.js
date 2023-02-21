async function handleRequest(request) {
  const ip = request.headers.get('CF-Connecting-IP');
  const country = request.headers.get('CF-IPCountry');
  const content = JSON.stringify({ ip, country });
  return new Response(content, {status: 200})
}
addEventListener('fetch', event => {
  return event.respondWith(handleRequest(event.request))
})
