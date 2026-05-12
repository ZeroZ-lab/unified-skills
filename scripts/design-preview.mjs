#!/usr/bin/env node

/**
 * design-preview.mjs — Minimal HTTP server for interactive design comparison.
 *
 * Zero npm dependencies. Uses only Node.js built-in modules.
 *
 * Usage:
 *   node scripts/design-preview.mjs <serve-dir> [--port <port>]
 *
 * Endpoints:
 *   GET  /               → serve design-comparison.html
 *   GET  /api/status     → return current selection from design-selection.json
 *   POST /api/selection  → write selection JSON to design-selection.json
 *   POST /api/next-round → clear selection for next comparison round
 *   GET  /health         → return { ok: true }
 *
 * Output:
 *   Prints "DESIGN_PREVIEW_PORT=<port>" to stdout on startup.
 */

import { createServer } from 'node:http';
import { readFile, writeFile, unlink } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { existsSync } from 'node:fs';

// --- CLI args ---
const args = process.argv.slice(2);
const dir = resolve(args[0] || '.');
const portIdx = args.indexOf('--port');
const preferredPort = portIdx !== -1 ? parseInt(args[portIdx + 1], 10) : 0;

const SELECTION_FILE = join(dir, 'design-selection.json');
const HTML_FILE = join(dir, 'design-comparison.html');

// --- Helpers ---
function jsonResponse(res, data, status = 200) {
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  });
  res.end(JSON.stringify(data));
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf-8');
}

function htmlResponse(res, html) {
  res.writeHead(200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'no-cache',
  });
  res.end(html);
}

function errorResponse(res, message, status = 404) {
  res.writeHead(status, { 'Content-Type': 'text/plain' });
  res.end(message);
}

// --- Server ---
const server = createServer(async (req, res) => {
  const url = req.url.split('?')[0];
  const method = req.method;

  try {
    // CORS preflight
    if (method === 'OPTIONS') {
      res.writeHead(204, {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });
      res.end();
      return;
    }

    // Health check
    if (url === '/health' && method === 'GET') {
      jsonResponse(res, { ok: true });
      return;
    }

    // Serve comparison HTML
    if (url === '/' && method === 'GET') {
      if (!existsSync(HTML_FILE)) {
        errorResponse(res, 'design-comparison.html not found in ' + dir, 404);
        return;
      }
      const html = await readFile(HTML_FILE, 'utf-8');
      htmlResponse(res, html);
      return;
    }

    // Get current selection status
    if (url === '/api/status' && method === 'GET') {
      if (!existsSync(SELECTION_FILE)) {
        jsonResponse(res, { selected: false });
        return;
      }
      const data = JSON.parse(await readFile(SELECTION_FILE, 'utf-8'));
      jsonResponse(res, { selected: true, ...data });
      return;
    }

    // Save selection
    if (url === '/api/selection' && method === 'POST') {
      const body = JSON.parse(await readBody(req));
      const selection = {
        timestamp: new Date().toISOString(),
        ...body,
      };
      await writeFile(SELECTION_FILE, JSON.stringify(selection, null, 2), 'utf-8');
      jsonResponse(res, { ok: true, selection });
      return;
    }

    // Clear selection for next round
    if (url === '/api/next-round' && method === 'POST') {
      if (existsSync(SELECTION_FILE)) {
        await unlink(SELECTION_FILE);
      }
      jsonResponse(res, { ok: true, message: 'Selection cleared for next round' });
      return;
    }

    // 404
    errorResponse(res, 'Not Found', 404);
  } catch (err) {
    console.error('Error:', err.message);
    errorResponse(res, 'Internal Server Error', 500);
  }
});

// --- Startup ---
server.listen(preferredPort, () => {
  const addr = server.address();
  console.log(`DESIGN_PREVIEW_PORT=${addr.port}`);
  console.log(`Serving: ${dir}`);
  console.log(`Open: http://localhost:${addr.port}`);
});

// --- Graceful shutdown ---
function shutdown() {
  server.close(() => {
    process.exit(0);
  });
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
