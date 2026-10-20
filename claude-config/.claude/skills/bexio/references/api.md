# Bexio REST API through `bxapi`

What worked on 2026-10-09 against the morntag company (plan Pro). `bxapi` is `scripts/bxapi` in this skill,
Python 3 without dependencies. `bxapi help` lists the commands. Spec: https://docs.bexio.com (the page embeds
an OpenAPI document; base `https://api.bexio.com`, every request needs `Accept: application/json`).

## Token

- Personal Access Token, read at call time from 1Password: `op read "op://Employee/Bexio API/credential"`.
  `$BEXIO_TOKEN` overrides it. Never print it, never write it to a file.
- PATs carry all scopes and expire after 60 days. Brian renews them at https://developer.bexio.com/pat (SSO
  with the morntag Chrome profile, developer terms accepted on 2026-10-09). The ClickUp task «Bexio PAT
  erneuern» in «brian stuff» reminds him. On 401 `bxapi` says so and exits 3.
- There is no API page inside office.bexio.com; the old `/admin/apiTokens` URL is a 404.
- Rate limit: 1000 requests per 30 s window, headers `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`.
  `bxapi check` prints them.

## Endpoints in use

| Need | Call | Notes |
|---|---|---|
| Chart of accounts | `GET /2.0/accounts?limit=2000` | `account_no` «1021», `id` (used by entries), `uuid` (used by the journal filter), `name`, `is_active`. 133 accounts. |
| Journal of one account | `GET /3.0/accounting/journal?from&to&account_uuid&limit&offset` | Rows where the account is on **either** side. Includes invoice payments (`ref_class` `KbClientAccountEntry`) and manual entries (`ref_class` null). Row `id` is the entry **line** id, not the manual entry id. |
| Manual entry | `GET/POST /3.0/accounting/manual_entries`, `GET/PUT/DELETE …/{id}` | Body below. Response has `id`, `reference_nr`, `entries[].id` (= journal row id). **Bexio does not assign a Belegnummer to API-created entries** (`reference_nr` stays null and the entry shows without number in the UI): read `GET …/manual_entries/next_ref_nr` → `{"next_ref_nr": "689"}` and send it as `reference_nr` in the POST body; `bxapi` does this on every create (since 2026-10-09). A PUT on an entry re-issues its journal line ids. Also `is_locked`/`locked_info` (`closed_business_year`). Delete is permanent. |
| Files on a manual entry | `GET/POST /3.0/accounting/manual_entries/{id}/entries/{line_id}/files`, `DELETE …/files/{file_id}` | Files hang off the **entry line** (`entries[].id`), not the entry: `GET …/manual_entries/{id}/files` is the compound-entry variant and returns `[]` for single entries. POST is `multipart/form-data`, field `fileName`, max 12MB, PDF/PNG/JPG/…; 201 with a `FileResponse` array (`id`, `uuid`, `name`, `extension`, `size_in_bytes`). `bxapi entry attach ID FILE` and `bxapi entry files ID` wrap this. |
| Supplier payment behind a Zahlungsausgang | `GET /4.0/purchase/outgoing-payments/{ref_uuid}` → `bill_id` → `GET /4.0/purchase/bills/{uuid}` | Bill has `document_no`, `lastname_company`, `title`, `status`, `pending_amount`. |
| Company | `GET /2.0/company_profile` | Used by `bxapi check`. |
| Taxes, currencies | `GET /3.0/taxes`, `GET /3.0/currencies` | CHF is currency id 1. Not needed for the accounting runs (no VAT on manual entries, see below). |

Not resolvable: the `ref_id` of a `Zahlungseingang` row (customer payment) is not a `kb_invoice` id and
`/2.0/kb_invoice/{ref_id}` is a 404. Match customer receipts on amount and date.

Not available: imported bank transactions. `/3.0/banking/accounts` lists the bank accounts, `/4.0/banking/payments`
are outgoing payment orders. The bank side of a reconciliation always comes from the bank export.

## Manual entry body

```json
{"type": "manual_single_entry", "date": "2026-09-30",
 "entries": [{"debit_account_id": 221, "credit_account_id": 238, "amount": 3044.70,
              "description": "Viseca Card SA, Belastung Kreditkarte September",
              "currency_id": 1, "currency_factor": 1}]}
```

Sammelbuchung (`bxapi compound`): `"type": "manual_compound_entry"`, every line carries **either**
`debit_account_id` **or** `credit_account_id` and the same `description`; the lines must balance. `GET` returns the
first line (the counter, e.g. Haben 1350 with the total) with `id: null`, so summing every line's amount doubles the
total. In the journal each line shows up as its own row with the counter on the opposite side (`6500 / 1350`), all
with the same description; `bxapi compound` detects an existing entry by that.

```json
{"type": "manual_compound_entry", "date": "2026-08-24",
 "entries": [{"credit_account_id": 221, "amount": 2201.25, "description": "Viseca Card SA, Abrechnung August", …},
             {"debit_account_id": 202, "amount": 1160.60, "description": "Viseca Card SA, Abrechnung August", …}, …]}
```

No `tax_id`: morntag settles VAT with the Saldosteuersatz method, so VAT appears only on customer invoices,
never on these bank-side entries. `bxapi entry create` and `bxapi book` build exactly this body from account
numbers; `--dry-run` prints it without sending.

## Numbers to know

- Journal net on 1021 for August 2026 equalled the Kontoblatt net plus that month's bookings to the Rappen,
  so the journal replaces the Kontoblatt export.
- The year-to-date sum of journal rows (`bxapi balance`) sits 1 to 2 Rappen above the Kontoblatt Übertrag Bexio
  printed for the same dates in 2026 (31.03: 24'293.98 vs 24'293.96; 31.08: 45'682.39 vs 45'682.37). Period
  movements agree exactly, so the offset is in Q1 rows. Anchor saldo checks on the bank export's opening balance,
  not on `bxapi balance`.

## Rules

- Reads are free. Manual entries are written only by the `morntag-accounting` skill (through `bxapi book
  FILE.json`, which skips rows already in the journal and stops at the first error) and the `morntag-viseca`
  skill (through `bxapi compound FILE.json`), each after Brian's «book it», one month at a time.
- Delete or change only entries whose ids the current run file holds. Never touch payments, bills, invoices or
  entries in a closed business year.
