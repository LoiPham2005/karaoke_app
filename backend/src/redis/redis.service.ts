import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client!: Redis;

  constructor(private readonly config: ConfigService) {}

  async onModuleInit() {
    this.client = new Redis({
      host: this.config.get<string>('redis.host'),
      port: this.config.get<number>('redis.port'),
      password: this.config.get<string>('redis.password') || undefined,
      lazyConnect: false,
      maxRetriesPerRequest: 3,
    });

    this.client.on('connect', () => this.logger.log('✅ Redis connected'));
    this.client.on('error', (err) => this.logger.error('Redis error', err));
  }

  async onModuleDestroy() {
    await this.client?.quit();
  }

  getClient(): Redis {
    return this.client;
  }

  async get<T = unknown>(key: string): Promise<T | null> {
    const value = await this.client.get(key);
    if (!value) return null;
    try {
      return JSON.parse(value) as T;
    } catch {
      return value as unknown as T;
    }
  }

  async set(key: string, value: unknown, ttlSeconds?: number): Promise<void> {
    const data = typeof value === 'string' ? value : JSON.stringify(value);
    if (ttlSeconds) {
      await this.client.set(key, data, 'EX', ttlSeconds);
    } else {
      await this.client.set(key, data);
    }
  }

  async del(key: string | string[]): Promise<void> {
    await this.client.del(...(Array.isArray(key) ? key : [key]));
  }

  async exists(key: string): Promise<boolean> {
    return (await this.client.exists(key)) === 1;
  }

  async increment(key: string, by = 1): Promise<number> {
    return this.client.incrby(key, by);
  }
}
