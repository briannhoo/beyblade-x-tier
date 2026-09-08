/* X 天梯 Warm service worker
   改咗 app 之後記得升 VERSION，唔係啲 client 會食舊 cache。 */
var VERSION = "beyx-warm-v1";
var SHELL = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./icon-512-maskable.png",
  "./apple-touch-icon.png",
  "./favicon-32.png"
];

self.addEventListener("install", function(e){
  e.waitUntil(
    caches.open(VERSION).then(function(c){
      return Promise.all(SHELL.map(function(u){
        return c.add(new Request(u, {cache: "reload"})).catch(function(){});
      }));
    }).then(function(){ return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function(e){
  e.waitUntil(
    caches.keys().then(function(keys){
      return Promise.all(keys.map(function(k){
        return k === VERSION ? null : caches.delete(k);
      }));
    }).then(function(){ return self.clients.claim(); })
  );
});

self.addEventListener("fetch", function(e){
  var req = e.request;
  if(req.method !== "GET") return;
  var url;
  try { url = new URL(req.url); } catch(err){ return; }

  // 開頁：一定要 cache:"reload" 繞過 HTTP cache —— GitHub Pages 對 HTML
  // 設 max-age=600，唔繞過嘅話部署後最多 10 分鐘仲會出舊版。
  if(req.mode === "navigate"){
    e.respondWith(
      fetch(new Request(req.url, {cache: "reload", credentials: "same-origin"}))
        .then(function(res){
          var copy = res.clone();
          caches.open(VERSION).then(function(c){ c.put("./index.html", copy); });
          return res;
        }).catch(function(){
          return caches.match("./index.html").then(function(hit){
            return hit || caches.match("./");
          });
        })
    );
    return;
  }

  var isFont = url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com";
  var isImg  = url.hostname === "i.ibb.co";
  var sameOrigin = url.origin === self.location.origin;
  if(!sameOrigin && !isFont && !isImg) return;

  e.respondWith(
    caches.match(req).then(function(hit){
      var net = fetch(req).then(function(res){
        if(res && (res.ok || res.type === "opaque")){
          var copy = res.clone();
          caches.open(VERSION).then(function(c){ c.put(req, copy); });
        }
        return res;
      }).catch(function(){ return hit; });
      return hit || net;
    })
  );
});
