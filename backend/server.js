import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { createClient } from '@supabase/supabase-js';
import { AccessToken } from 'livekit-server-sdk';

const app = express();
app.use(cors({ origin: process.env.ALLOWED_ORIGIN?.split(',') ?? false }));
app.use(express.json({ limit: '32kb' }));
const required = ['SUPABASE_URL','SUPABASE_ANON_KEY','LIVEKIT_URL','LIVEKIT_API_KEY','LIVEKIT_API_SECRET'];
const configured = required.every((k) => Boolean(process.env[k]));

app.get('/health', (_req, res) => res.json({ ok: true, service: 'nexus-backend', configured }));

app.post('/api/livekit/token', async (req, res) => {
  if (!configured) return res.status(503).json({ error: 'Backend services are not configured.' });
  try {
    const auth = req.headers.authorization ?? '';
    if (!auth.startsWith('Bearer ')) return res.status(401).json({ error: 'Authentication required.' });
    const jwt = auth.slice(7);
    const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, { global: { headers: { Authorization: `Bearer ${jwt}` } }, auth: { persistSession: false } });
    const { data: { user }, error } = await supabase.auth.getUser(jwt);
    if (error || !user) return res.status(401).json({ error: 'Invalid session.' });
    const { roomName } = req.body ?? {};
    if (typeof roomName !== 'string' || !/^[a-zA-Z0-9_-]{1,80}$/.test(roomName)) return res.status(400).json({ error: 'Invalid room name.' });
    // TODO: Verify the authenticated user is an active member of the community/voice room
    // represented by roomName before issuing a production token.
    const token = new AccessToken(process.env.LIVEKIT_API_KEY, process.env.LIVEKIT_API_SECRET, { identity: user.id, ttl: '10m' });
    token.addGrant({ roomJoin: true, room: roomName, canPublish: true, canSubscribe: true });
    return res.json({ serverUrl: process.env.LIVEKIT_URL, token: await token.toJwt() });
  } catch (e) {
    console.error('token endpoint failed', e);
    return res.status(500).json({ error: 'Unable to create room token.' });
  }
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`NEXUS backend listening on ${port}`));
