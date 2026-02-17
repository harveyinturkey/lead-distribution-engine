export default async (request, context) => {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "*"
      }
    });
  }

  if (request.method === "POST") {
    // Bitrix24 iframe POST ile açar — GET'e çevirip statik dosyayı sun
    const url = new URL(request.url);
    const getReq = new Request(url.toString(), { method: "GET" });
    const response = await fetch(getReq);
    const body = await response.text();
    return new Response(body, {
      status: 200,
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "X-Frame-Options": "ALLOWALL"
      }
    });
  }
};

export const config = {
  path: "/*"
};
