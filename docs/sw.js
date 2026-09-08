/* X 天梯 service worker
   改咗 app 之後記得升 VERSION，唔係啲 client 會食舊 cache。 */
var VERSION = "beyx-tier-v8";
var SHELL = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./apple-touch-icon.png",
  "./favicon-32.png"
];

self.addEventListener("install", function(e){
  e.waitUntil(
    caches.open(VERSION).then(function(c){
      // 逐個加，一個失敗唔會拖冚整個安裝
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

  // 開頁：先試網絡（攞最新版），斷網就出 cache。
  // 一定要 cache:"reload" 繞過 HTTP cache —— GitHub Pages 對 HTML 設 max-age=600，
  // 唔繞過嘅話部署後最多 10 分鐘仲會出舊版。
  if(req.mode === "navigate"){
    e.respondWith(
      fetch(new Request(req.url, {cache: "reload", credentials: "same-origin"})).then(function(res){
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

  // Google Fonts：cache 住，離線都有返 Chakra Petch
  var isFont = url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com";
  var sameOrigin = url.origin === self.location.origin;
  if(!sameOrigin && !isFont) return;

  // 其餘：cache 行先，順手背景更新
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
