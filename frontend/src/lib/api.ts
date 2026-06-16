// Client gọi backend NestJS. Backend bọc response trong { statusCode, message, data }
// (TransformInterceptor) → ở đây tự unwrap `.data`.

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000/api/v1';

export async function apiGet<T>(path: string, signal?: AbortSignal): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { Accept: 'application/json' },
    signal,
  });

  const json = await res.json().catch(() => null);

  if (!res.ok) {
    const msg = json?.message ?? `Lỗi API (${res.status})`;
    throw new Error(Array.isArray(msg) ? msg.join(', ') : String(msg));
  }

  return (json?.data ?? json) as T;
}
