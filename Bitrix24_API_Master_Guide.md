# Bitrix24 REST API Master Guide
> Comprehensive reference for Bitrix24 CRM automation and API integration
> Last Updated: February 2026

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Authentication Methods](#authentication-methods)
3. [Core Concepts](#core-concepts)
4. [CRM Methods Reference](#crm-methods-reference)
5. [JavaScript/TypeScript SDK](#javascript-typescript-sdk)
6. [Rate Limiting & Batch Operations](#rate-limiting-batch-operations)
7. [File Handling](#file-handling)
8. [Workflow Automation](#workflow-automation)
9. [Best Practices](#best-practices)
10. [Common Use Cases](#common-use-cases)

---

## Getting Started

### What is Bitrix24 REST API?

Bitrix24 REST API allows developers to:
- Integrate external services with Bitrix24 CRM
- Automate business processes
- Build custom applications
- Extend Bitrix24 functionality
- Access and manipulate CRM data programmatically

### Official Resources
- Documentation: https://apidocs.bitrix24.com/
- GitHub Docs: https://github.com/bitrix24/b24restdocs
- Developer Hub: https://github.com/bitrix24/bitrix24-dev-hub

---

## Authentication Methods

### Method 1: OAuth 2.0 (Recommended for Production)

**Pros:**
- Secure, token-based authentication
- Automatic token renewal
- Suitable for marketplace applications

**Cons:**
- Requires additional setup
- Tokens expire (30 minutes for access token, 1 month for refresh token)

**Implementation:**
```javascript
// Access token usage
const bitrix = Bitrix('https://PORTAL_NAME.bitrix24.ru/rest', 'ACCESS_TOKEN')

// Token refresh required every 30 minutes
// Use refresh token to get new access token
```

### Method 2: Incoming Webhook (Simple, Quick Setup)

**Pros:**
- Easy setup, instant access
- No token expiration
- Perfect for internal automation

**Cons:**
- Less secure
- Limited to specific user permissions
- Not suitable for public applications

**Setup:**
1. Go to Bitrix24 → Applications → Webhooks → Inbound webhook
2. Select required permissions
3. Get webhook URL with embedded token

**Implementation:**
```javascript
const bitrix = Bitrix('https://PORTAL_NAME.bitrix24.ru/rest/1/WEBHOOK_TOKEN')
```

---

## Core Concepts

### REST API Structure

All Bitrix24 REST API requests follow this pattern:
```
https://your-domain.bitrix24.com/rest/[METHOD_NAME].json
```

### Request Methods

#### Using cURL:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "TITLE": "New Deal",
      "TYPE_ID": "SALE",
      "STAGE_ID": "NEW"
    },
    "auth": "YOUR_ACCESS_TOKEN"
  }' \
  https://your-domain.bitrix24.com/rest/crm.deal.add.json
```

#### Using Webhook:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "TITLE": "New Deal",
      "TYPE_ID": "SALE",
      "STAGE_ID": "NEW"
    }
  }' \
  https://your-domain.bitrix24.com/rest/USER_ID/CODE/crm.deal.add.json
```

### Response Format

**Success Response:**
```json
{
  "result": {
    "ID": "123",
    "TITLE": "New Deal"
  },
  "time": {
    "start": 1234567890.123,
    "finish": 1234567890.456,
    "duration": 0.333
  }
}
```

**Error Response:**
```json
{
  "error": "ERROR_CODE",
  "error_description": "Human readable error description"
}
```

---

## CRM Methods Reference

### Deals (crm.deal.*)

#### Get Single Deal
```javascript
// Method: crm.deal.get
bitrix.deals.get('77')
  .then(({ result }) => {
    const { TITLE, STAGE_ID, OPPORTUNITY } = result
    console.log(TITLE, STAGE_ID, OPPORTUNITY)
  })
```

**Parameters:**
- `ID` (required): Deal ID

**Common Fields:**
- `TITLE`: Deal title
- `TYPE_ID`: Deal type (SALE, etc.)
- `STAGE_ID`: Current stage
- `OPPORTUNITY`: Deal amount
- `CURRENCY_ID`: Currency code
- `COMPANY_ID`: Related company ID
- `CONTACT_ID`: Related contact ID
- `UF_*`: User fields (custom fields)

#### List Deals
```javascript
// Method: crm.deal.list
bitrix.deals.list({
  select: ['*', 'UF_*'],
  filter: {
    '>OPPORTUNITY': 1000,
    'STAGE_ID': 'NEW'
  },
  order: { 'DATE_CREATE': 'DESC' }
})
```

**Important:** Include `'UF_*'` in select to get custom user fields!

#### Add Deal
```javascript
// Method: crm.deal.add
bitrix.deals.add({
  TITLE: 'New Deal',
  TYPE_ID: 'SALE',
  STAGE_ID: 'NEW',
  OPPORTUNITY: 5000,
  CURRENCY_ID: 'USD',
  COMPANY_ID: '123',
  CONTACT_ID: '456'
})
```

#### Update Deal
```javascript
// Method: crm.deal.update
bitrix.deals.update('77', {
  STAGE_ID: 'WON',
  OPPORTUNITY: 6000
})
```

### Leads (crm.lead.*)

#### List Leads with Filtering
```javascript
bitrix.leads.list({
  select: ['*', 'UF_*'],
  filter: {
    'STATUS_ID': 'NEW',
    '>=DATE_CREATE': '2024-01-01T00:00:00'
  },
  order: { 'DATE_CREATE': 'DESC' }
})
```

### Contacts (crm.contact.*)

#### Add Contact
```javascript
bitrix.contacts.add({
  NAME: 'John',
  LAST_NAME: 'Doe',
  EMAIL: [{ VALUE: 'john@example.com', VALUE_TYPE: 'WORK' }],
  PHONE: [{ VALUE: '+1234567890', VALUE_TYPE: 'WORK' }]
})
```

### Companies (crm.company.*)

#### Get Company
```javascript
bitrix.companies.get('123')
  .then(({ result }) => {
    console.log(result.TITLE, result.INDUSTRY)
  })
```

### Payment Records (crm.item.payment.*)

Critical for financial tracking in healthcare tourism:

```javascript
// Get payment by ID
crm.item.payment.get({
  entityTypeId: 31, // Payment entity type
  id: 12345
})

// List payments with filter
crm.item.payment.list({
  entityTypeId: 31,
  filter: {
    '>=createdTime': '2024-01-01T00:00:00',
    'stageId': 'PAID'
  },
  select: ['*', 'ufCrm*']
})
```

---

## JavaScript/TypeScript SDK

### @2bad/bitrix (Recommended)

**Why use this SDK?**
- ✅ TypeScript support with strong typing
- ✅ Automatic rate limiting (2 req/sec)
- ✅ Automatic batch processing for large datasets
- ✅ Promise-based API
- ✅ Handles 250K reads/minute, 5K updates/minute

**Installation:**
```bash
npm install @2bad/bitrix
```

**Basic Usage:**
```typescript
import Bitrix from '@2bad/bitrix'

const bitrix = Bitrix('https://PORTAL.bitrix24.ru/rest', 'TOKEN')

// Single record
const deal = await bitrix.deals.get('77')

// All records (automatic pagination!)
const allDeals = await bitrix.deals.list({ 
  select: ['*', 'UF_*'] 
})

// Batch operations
const results = await bitrix.batch({
  lead: { method: 'crm.lead.get', params: { ID: '77' } },
  deals: { method: 'crm.deal.list', params: {} }
})
```

**Advanced Features:**

1. **Automatic Pagination:**
```typescript
// Gets ALL deals automatically, no pagination code needed
const allDeals = await bitrix.deals.list({
  select: ['*', 'UF_*'],
  filter: { 'STAGE_ID': 'NEW' }
})
// Returns all matching records, SDK handles pagination
```

2. **Rate Limiting:**
```typescript
// SDK automatically queues requests to respect 2 req/sec limit
for (let i = 0; i < 100; i++) {
  await bitrix.deals.get(i.toString())
}
// No rate limit errors!
```

3. **Batch Processing:**
```typescript
await bitrix.batch({
  deal77: { method: 'crm.deal.get', params: { ID: '77' } },
  deal78: { method: 'crm.deal.get', params: { ID: '78' } },
  allLeads: { method: 'crm.lead.list', params: {} }
})
```

4. **Error Handling:**
```typescript
try {
  const result = await bitrix.deals.get('invalid_id')
} catch (error) {
  // SDK rejects promise on error
  console.error(error.message)
}
```

---

## Rate Limiting & Batch Operations

### Bitrix24 Rate Limits

- **Standard limit:** 2 requests per second per account
- **Batch request:** Up to 50 operations in one call
- **Pagination:** Default 50 records per page, max varies by method

### Strategy 1: Use batch() for Multiple Operations

```javascript
// Instead of 3 separate API calls:
const deal = await bitrix.call('crm.deal.get', { ID: '77' })
const lead = await bitrix.call('crm.lead.get', { ID: '88' })
const contact = await bitrix.call('crm.contact.get', { ID: '99' })

// Use batch (1 API call):
const { result } = await bitrix.batch({
  deal: { method: 'crm.deal.get', params: { ID: '77' } },
  lead: { method: 'crm.lead.get', params: { ID: '88' } },
  contact: { method: 'crm.contact.get', params: { ID: '99' } }
})

console.log(result.deal, result.lead, result.contact)
```

### Strategy 2: Use list() with Automatic Pagination

```javascript
// SDK handles pagination automatically
const allDeals = await bitrix.deals.list({
  select: ['*', 'UF_*'],
  filter: { '>OPPORTUNITY': 1000 }
})
// Returns ALL matching records
```

### Strategy 3: Manual Batch for Updates

```javascript
// Update 100 deals in batches of 50
const updates = []
for (let i = 0; i < 100; i++) {
  updates.push({
    method: 'crm.deal.update',
    params: { ID: i, fields: { STAGE_ID: 'PROCESSED' } }
  })
}

// Split into chunks of 50
const chunks = []
for (let i = 0; i < updates.length; i += 50) {
  chunks.push(updates.slice(i, i + 50))
}

// Execute each chunk
for (const chunk of chunks) {
  await bitrix.batch(
    chunk.reduce((acc, item, idx) => {
      acc[`update_${idx}`] = item
      return acc
    }, {})
  )
}
```

---

## File Handling

### Method 1: Base64 Encoding (Most Common)

```javascript
// File upload example
const fileContent = fs.readFileSync('document.pdf')
const base64Content = fileContent.toString('base64')

// Upload to deal
await bitrix.call('crm.deal.add', {
  fields: {
    TITLE: 'Deal with Document',
    FILES: [
      ['document.pdf', base64Content]
    ]
  }
})
```

### Method 2: Using Disk API

```javascript
// 1. Upload file to disk
const uploadResult = await bitrix.call('disk.storage.uploadfile', {
  id: 'storage_id',
  data: {
    NAME: 'document.pdf'
  },
  fileContent: ['document.pdf', base64Content]
})

const fileId = uploadResult.result.ID

// 2. Attach to entity
await bitrix.call('crm.deal.update', {
  ID: '77',
  fields: {
    FILES: [fileId]
  }
})
```

### Important Notes:
- **URL encoding required** for cURL/GET requests
- Maximum file size varies by Bitrix24 plan
- Use `fileData` or `fileContent` parameter depending on method

---

## Workflow Automation

### Automation Rules (bizproc.robot.*)

Create custom automation actions:

```javascript
// Register custom automation rule
await bitrix.call('bizproc.robot.add', {
  CODE: 'send_custom_email',
  HANDLER: 'https://your-server.com/handler',
  NAME: 'Send Custom Email',
  PROPERTIES: {
    email: { Name: 'Email Address', Type: 'string' }
  }
})
```

### Triggers (crm.automation.trigger.*)

Execute actions on CRM events:

```javascript
// Add trigger
await bitrix.call('crm.automation.trigger.execute', {
  ENTITY_TYPE_ID: 2, // Deal
  ENTITY_ID: 77,
  TRIGGER: 'CUSTOM_TRIGGER_CODE'
})
```

### Event Handlers

Register webhooks for real-time events:

```javascript
// Register event handler
await bitrix.call('event.bind', {
  event: 'ONCRMDEALUPDATE',
  handler: 'https://your-server.com/webhook'
})

// Your webhook receives:
{
  event: 'ONCRMDEALUPDATE',
  data: {
    FIELDS: {
      ID: '77',
      STAGE_ID: 'WON'
    }
  }
}
```

---

## Best Practices

### 1. Always Use User Fields Wildcard

```javascript
// ❌ Bad - missing custom fields
bitrix.deals.list({ select: ['ID', 'TITLE'] })

// ✅ Good - includes all custom fields
bitrix.deals.list({ select: ['*', 'UF_*'] })
```

### 2. Filter on Server, Not Client

```javascript
// ❌ Bad - fetches all then filters
const allDeals = await bitrix.deals.list({})
const filtered = allDeals.result.filter(d => d.OPPORTUNITY > 1000)

// ✅ Good - filters on server
const filtered = await bitrix.deals.list({
  filter: { '>OPPORTUNITY': 1000 }
})
```

### 3. Use Batch for Multiple Operations

```javascript
// ❌ Bad - 3 API calls
const deal = await bitrix.deals.get('77')
const contact = await bitrix.contacts.get('88')
const company = await bitrix.companies.get('99')

// ✅ Good - 1 API call
const { result } = await bitrix.batch({
  deal: { method: 'crm.deal.get', params: { ID: '77' } },
  contact: { method: 'crm.contact.get', params: { ID: '88' } },
  company: { method: 'crm.company.get', params: { ID: '99' } }
})
```

### 4. Handle Errors Properly

```typescript
try {
  const result = await bitrix.deals.get('77')
  // Process result
} catch (error) {
  if (error.message.includes('Not found')) {
    // Handle not found
  } else if (error.message.includes('Access denied')) {
    // Handle permission error
  } else {
    // Handle other errors
  }
}
```

### 5. Date Filtering

```javascript
// Use ISO 8601 format
bitrix.deals.list({
  filter: {
    '>=DATE_CREATE': '2024-01-01T00:00:00',
    '<=DATE_CREATE': '2024-12-31T23:59:59'
  }
})
```

### 6. Pagination for Large Datasets

```javascript
// SDK handles automatically, but for custom pagination:
let start = 0
const pageSize = 50
let hasMore = true

while (hasMore) {
  const result = await bitrix.call('crm.deal.list', {
    start: start,
    select: ['*', 'UF_*']
  })
  
  // Process result.result
  
  start += pageSize
  hasMore = result.total > start
}
```

---

## Common Use Cases

### Use Case 1: Lead Analytics Pipeline

```javascript
// Fetch all leads from last month with advertising data
const leads = await bitrix.leads.list({
  select: ['*', 'UF_*'],
  filter: {
    '>=DATE_CREATE': '2024-01-01T00:00:00',
    '<=DATE_CREATE': '2024-01-31T23:59:59'
  }
})

// Group by source
const bySource = {}
leads.result.forEach(lead => {
  const source = lead.SOURCE_ID || 'UNKNOWN'
  bySource[source] = (bySource[source] || 0) + 1
})

console.log('Leads by source:', bySource)
```

### Use Case 2: Payment Data Sync

```javascript
// Get all payments for specific period
const payments = await bitrix.call('crm.item.payment.list', {
  entityTypeId: 31,
  select: ['*', 'ufCrm*'],
  filter: {
    '>=createdTime': '2024-01-01T00:00:00',
    'stageId': 'PAID'
  }
})

// Parse and sum by currency
const totals = {}
payments.result.items.forEach(payment => {
  const currency = payment.currencyId
  const amount = parseFloat(payment.opportunity)
  totals[currency] = (totals[currency] || 0) + amount
})
```

### Use Case 3: Bulk Deal Update

```javascript
// Get all deals in specific stage
const deals = await bitrix.deals.list({
  select: ['ID'],
  filter: { 'STAGE_ID': 'NEW' }
})

// Update in batches of 50
const batchUpdates = {}
deals.result.forEach((deal, idx) => {
  batchUpdates[`update_${idx}`] = {
    method: 'crm.deal.update',
    params: {
      ID: deal.ID,
      fields: { 
        STAGE_ID: 'IN_PROCESS',
        COMMENTS: 'Auto-updated by script'
      }
    }
  }
  
  // Execute batch every 50 records
  if (Object.keys(batchUpdates).length === 50) {
    await bitrix.batch(batchUpdates)
    batchUpdates = {}
  }
})

// Execute remaining
if (Object.keys(batchUpdates).length > 0) {
  await bitrix.batch(batchUpdates)
}
```

### Use Case 4: CRM to External System Sync

```javascript
// Sync deals to external analytics system
const deals = await bitrix.deals.list({
  select: ['*', 'UF_*'],
  filter: {
    '>=DATE_MODIFY': lastSyncDate
  }
})

for (const deal of deals.result) {
  // Transform Bitrix data to external format
  const externalData = {
    id: deal.ID,
    title: deal.TITLE,
    amount: parseFloat(deal.OPPORTUNITY),
    currency: deal.CURRENCY_ID,
    stage: deal.STAGE_ID,
    customField1: deal.UF_CRM_1234567890
  }
  
  // Send to external API
  await fetch('https://analytics.example.com/api/deals', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(externalData)
  })
}
```

---

## Quick Reference: Common Filters

### Comparison Operators
- `=` - Equals
- `!=` - Not equals
- `>` - Greater than
- `>=` - Greater than or equal
- `<` - Less than
- `<=` - Less than or equal
- `%` - LIKE (substring match)

### Examples:
```javascript
filter: {
  'TITLE': 'Exact Match',              // equals
  '!STAGE_ID': 'LOST',                 // not equals
  '>OPPORTUNITY': 1000,                // greater than
  '>=DATE_CREATE': '2024-01-01',       // greater or equal
  '%TITLE': 'substring',               // contains
  'ASSIGNED_BY_ID': [1, 2, 3]          // in array
}
```

---

## Error Codes Reference

Common Bitrix24 errors:

- `ERROR_CORE`: System error
- `ERROR_METHOD_NOT_FOUND`: Invalid method name
- `INVALID_CREDENTIALS`: Auth token invalid/expired
- `ACCESS_DENIED`: Insufficient permissions
- `QUERY_LIMIT_EXCEEDED`: Rate limit hit
- `WRONG_REQUEST`: Invalid parameters

---

## Resources & Links

### Official Documentation
- Main docs: https://apidocs.bitrix24.com/
- GitHub docs: https://github.com/bitrix24/b24restdocs
- Developer hub: https://github.com/bitrix24/bitrix24-dev-hub

### SDK Libraries
- JavaScript/TypeScript: https://github.com/2BAD/bitrix
- PHP: https://github.com/bitrix24/b24phpsdk
- Python: https://github.com/gebvlad/bitrix24-python-sdk

### Community
- Bitrix24 Developer Forum
- Stack Overflow tag: bitrix24

---

**Document Version:** 1.0  
**Last Updated:** February 2026  
**Maintained for:** Healthcare Tourism CRM Automation

