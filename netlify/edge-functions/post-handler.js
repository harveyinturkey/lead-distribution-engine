export default async (request, context) => {
  if (request.method === "POST" || request.method === "OPTIONS") {
    const url = new URL(request.url);
    const response = await context.rewrite(url.pathname);
    const headers = new Headers(response.headers);
    headers.set("Access-Control-Allow-Origin", "*");
    headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    headers.set("Access-Control-Allow-Headers", "*");
    return new Response(response.body, {
      status: response.status,
      headers
    });
  }
};

export const config = {
  path: "/*"
};
