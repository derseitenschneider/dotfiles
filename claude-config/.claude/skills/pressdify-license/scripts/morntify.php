<?php
// Runs on the Morntify render server inside the app directory (config.php next to it).
// Piped there by scripts/morntify; never run it locally. Output is JSON, one object per line.
// The API key column is never printed: the api check sends it to api.pressdify.com from here.

$args = array_values(array_filter(array_slice($argv, 1), fn($a) => $a !== '--'));
$cmd  = array_shift($args) ?? 'help';

include 'config.php';
$db = new mysqli($DB_HOST, $DB_USER, $DB_PASSWORD, $DB_NAME);
$db->set_charset('utf8mb4');

const COLS = "ID, URL, `per Year` AS perYear, `Amount bought` AS bought, `Amount Used` AS used,
              `Start Date` AS start, `End Date` AS end, weasyprint_version AS weasyprint";

function out(array $o): void { echo json_encode($o, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE), "\n"; }
function fail(string $msg): void { out(['error' => $msg]); exit(1); }
function opt(array &$args, string $name, $default = null) {
    $i = array_search($name, $args, true);
    if ($i === false) return $default;
    $v = $args[$i + 1] ?? fail("$name needs a value");
    array_splice($args, $i, 2);
    return $v;
}

function rows(mysqli $db, string $where = '', array $params = []): array {
    $st = $db->prepare("SELECT " . COLS . " FROM Customer $where ORDER BY ID");
    if ($params) $st->bind_param(str_repeat('s', count($params)), ...$params);
    $st->execute();
    return $st->get_result()->fetch_all(MYSQLI_ASSOC);
}

// Exactly one row whose URL is the domain, with or without www.
function one(mysqli $db, string $domain): array {
    $bare = preg_replace('/^www\./', '', strtolower($domain));
    $r = rows($db, "WHERE URL = ? OR URL = ?", [$bare, "www.$bare"]);
    if (count($r) !== 1) fail(count($r) . " rows match '$domain': " . json_encode(array_column($r, 'URL')));
    return $r[0];
}

// What the public API answers for this customer. The key never leaves the server.
function api_check(mysqli $db, int $id): array {
    $st = $db->prepare("SELECT URL, `API Key` AS k FROM Customer WHERE ID = ?");
    $st->bind_param('i', $id); $st->execute();
    $row = $st->get_result()->fetch_assoc();
    $ctx = stream_context_create(['http' => [
        'method' => 'GET', 'ignore_errors' => true, 'timeout' => 20,
        'header' => "Morntify-Key: {$row['k']}\r\nPressdify-Request-Url: {$row['URL']}\r\n",
    ]]);
    $raw = file_get_contents('https://api.pressdify.com/api/v1/user/', false, $ctx);
    $j = json_decode($raw ?: '', true);
    return $j['data']['user'] ?? ['status' => $j['status'] ?? 'no response', 'detail' => $j['data'] ?? $raw];
}

switch ($cmd) {
    case 'list':
        foreach (rows($db) as $r) out($r);
        break;

    case 'customer':
        $domain = $args[0] ?? fail('customer DOMAIN');
        $row = one($db, $domain);
        out(['row' => $row, 'api' => api_check($db, (int)$row['ID'])]);
        break;

    case 'renew':
        $from  = opt($args, '--from', date('Y-m-d'));
        $topup = opt($args, '--top-up');
        $domain = $args[0] ?? fail('renew DOMAIN [--from YYYY-MM-DD | --top-up N]');
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $from)) fail("--from wants YYYY-MM-DD, got '$from'");
        $before = one($db, $domain);
        $id = (int)$before['ID'];
        if ($topup !== null) {
            if (!ctype_digit((string)$topup) || (int)$topup < 1) fail("--top-up wants a positive number");
            $st = $db->prepare("UPDATE Customer SET `Amount bought` = `Amount bought` + ? WHERE ID = ?");
            $st->bind_param('ii', $topup, $id);
        } else {
            $to = date('Y-m-d', strtotime("$from +1 year"));
            $st = $db->prepare("UPDATE Customer SET `Amount Used` = 0, `Start Date` = ?, `End Date` = ? WHERE ID = ?");
            $st->bind_param('ssi', $from, $to, $id);
        }
        $st->execute();
        if ($st->affected_rows !== 1) fail("update touched {$st->affected_rows} rows");
        $after = one($db, $domain);
        out(['before' => $before, 'after' => $after, 'api' => api_check($db, $id)]);
        break;

    default:
        out(['usage' => ['list', 'customer DOMAIN', 'renew DOMAIN [--from YYYY-MM-DD | --top-up N]']]);
}
