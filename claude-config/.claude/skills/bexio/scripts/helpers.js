// Bexio page helpers for `browser-use eval`. scripts/bx loads this file before every call.
// Sync code only: browser-use eval returns {} for promises. Every function returns a string.
(() => {
  const jq = window.jQuery;
  const clean = s => (s || '').replace(/[ \t ]+/g, ' ').replace(/\s*\n\s*/g, '\n').trim();
  const plain = html => clean((html || '').replace(/<br\s*\/?>/gi, '\n').replace(/<\/(p|li|ul|ol|div|tr|h\d|label)>/gi, '\n').replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&'));
  const docRef = () => {
    const m = location.pathname.match(/\/(kb_offer|kb_invoice|kb_order)\/show\/id\/(\d+)/);
    return m ? {type: m[1], id: m[2]} : null;
  };
  // GET a tab of the current document without leaving the page (read-only).
  const getTab = action => {
    const r = docRef();
    if (!r) return null;
    const x = new XMLHttpRequest();
    x.open('GET', '/index.php/' + r.type + '/' + action + '/id/' + r.id, false);
    x.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    x.send();
    const d = new DOMParser().parseFromString(x.responseText, 'text/html');
    d.querySelectorAll('script,style').forEach(e => e.remove());
    return d;
  };
  const rows = () => [...document.querySelectorAll('[id^=position_]')].map(e => ({
    id: e.id,
    type: e.id.replace(/^position_KbPosition/, '').replace(/\d+$/, ''),
    optional: !!e.closest('.optionalPositionTable'),
    text: clean(e.innerText),
    price: clean((e.querySelector('.single_price') || {}).innerText).replace(/\n/g, ' '),
  }));
  const textsObj = () => {
    const d = getTab('editTexts');
    if (!d) return null;
    const f = n => d.querySelector('[name="kb_item[' + n + ']"]');
    if (f('header')) return {draft: true, title: f('title').value, header: plain(f('header').value), footer: plain(f('footer').value)};
    // Issued documents show the texts as plain text, not as fields.
    const t = plain(d.body.innerHTML);
    const cut = (a, b) => { const i = t.indexOf(a); if (i < 0) return ''; const j = b ? t.indexOf(b, i) : -1; return t.slice(i + a.length, j < 0 ? undefined : j).trim(); };
    return {draft: false, title: cut('Titel', 'Referenz'), header: cut('Kopfzeile', 'Fusszeile'), footer: cut('Fusszeile')};
  };
  const posForm = type => {
    const f = document.querySelector('form[action*="KbPosition' + type + '"]');
    return f && f.offsetParent !== null ? f : null;
  };
  const save = f => {
    const b = [...f.querySelectorAll('button')].find(b => b.innerText.trim() === 'Speichern');
    if (!b) return false;
    b.click();
    return true;
  };

  window.__bx = {
    // Where am I, and am I logged in?
    where: () => location.host + ' | ' + location.pathname + ' | ' + document.title,

    // Rows of a list page (kb_offer/list, kb_invoice/list, kb_order/list), optionally filtered by a regex.
    list: pattern => {
      const re = pattern ? new RegExp(pattern, 'i') : null;
      const out = [...document.querySelectorAll('tr')].map(r => {
        const a = r.querySelector('a[href*="/show/id/"]');
        return a ? [...r.cells].map(c => clean(c.innerText).replace(/\n/g, ' ')).filter(Boolean).join(' | ').replace(/ \| Aktionen.*$/, '') + ' -> ' + a.getAttribute('href') : null;
      }).filter(l => l && (!re || re.test(l)));
      const pager = (document.body.innerText.match(/Einträge \d+-\d+ von \d+/) || [''])[0];
      return out.join('\n') + '\n' + out.length + ' rows' + (pager ? ' (' + pager + ')' : '');
    },

    // One document (offer, invoice or order show page): heading, positions, totals, status, contact id.
    read: () => {
      const c = document.querySelector('#contentContainer');
      if (!c || !docRef()) return 'not a document page: ' + location.pathname;
      const t = c.innerText;
      const m = re => clean((t.match(re) || [''])[0]).replace(/\n/g, ' ');
      const contact = (document.querySelector('a[href*="kontakt/show/id/"]') || {getAttribute: () => ''}).getAttribute('href');
      const partial = [...document.querySelectorAll('a[href*="createNextPartialInvoice"], a[href*="createInvoice"]')].map(a => a.innerText.trim() + ' -> ' + a.getAttribute('href'));
      return [
        m(/(Angebot|Rechnung|Auftrag) [A-Z]{2}-\d+[^\n]*/),
        m(/Titel:[^\n]*/),
        m(/STATUS\s*\n\s*[^\n]+/),
        'contact: ' + contact,
        m(/Vorgängerdokument:\s*\n[^\n]+/),
        m(/TEILRECHNUNGEN[\s\S]*?(?=STATUSAKTIONEN)/),
        partial.join('\n'),
        '--- positions',
        ...rows().map(r => '[' + r.id + (r.optional ? ', optional' : '') + ']\n' + r.text),
        '--- totals',
        m(/Total\s*\n\s*[\d'.]+/), m(/Zzgl\. Steuer[^\n]*\n\s*[\d'.]+/), m(/Betrag inkl\. Steuer\s*\n\s*[\d'.]+/),
      ].filter(Boolean).join('\n');
    },

    // Title, header and footer of the current document (works on drafts and issued documents).
    texts: () => {
      const o = textsObj();
      return o ? 'TITLE: ' + o.title + '\nHEADER:\n' + o.header + '\nFOOTER:\n' + o.footer : 'not a document page';
    },

    // Konditionen of the current document: dates and payment text.
    conditions: () => {
      const d = getTab('editPayment');
      if (!d) return 'not a document page';
      const fields = [...d.querySelectorAll('input[type=text], textarea, select')].filter(e => e.name).map(e =>
        e.name + ' = ' + (e.tagName === 'SELECT' ? (e.selectedOptions[0] ? e.selectedOptions[0].text.trim() : '') : e.value));
      return fields.length ? fields.join('\n') : clean(d.body.textContent);
    },

    // Address form and spelling check over header, positions and footer.
    // form 'euch': lists lines with du-forms. form 'du': lists lines with ihr-forms (may include "ihr" = her/their).
    scan: form => {
      const o = textsObj();
      if (!o) return 'not a document page';
      const lines = (o.header + '\n' + rows().map(r => r.text).join('\n') + '\n' + o.footer).split('\n');
      const du = /(^|[^\wäöü])(du|dir|dich|dein|deine|deinen|deinem|deiner|deines|hast|bist|kannst|willst|sag)(?![\wäöü])/i;
      const ihr = /(^|[^\wäöü])(ihr|euch|euer|eure|euren|eurem|eurer|eures|habt|seid|könnt|wollt)(?![\wäöü])/i;
      const wrong = lines.filter(l => (form === 'du' ? ihr : du).test(l));
      const eszett = lines.filter(l => /ß/.test(l));
      return 'address form expected: ' + (form === 'du' ? 'du' : 'euch') +
        '\nWRONG FORM: ' + (wrong.length ? '\n  ' + wrong.join('\n  ') : 'none') +
        '\nESZETT: ' + (eszett.length ? '\n  ' + eszett.join('\n  ') : 'none');
    },

    // New-document dialog (kb_offer|kb_invoice /edit/contact_id/<id>): set contact person and title, read back.
    // Does not click "Weiter". That click assigns the document number.
    fillNew: (title, person) => {
      const s = document.getElementById('kb_item_contact_sub_id'), t = document.getElementById('kb_item_title');
      if (!s || !t) return 'new-document dialog not open';
      if (person) {
        const o = [...s.options].find(o => o.text.trim() === person);
        if (!o) return 'contact person "' + person + '" not found. Options: ' + [...s.options].map(o => o.text.trim()).filter(Boolean).join(', ');
        jq(s).val(o.value).trigger('change');
      }
      t.value = title;
      jq(t).trigger('change');
      const cur = document.getElementById('kb_item_currency_id');
      return JSON.stringify({
        contact: (document.getElementById('autocomplete_kb_item_contact_id') || {}).value,
        contact_id: (document.querySelector('[name="kb_item[contact_id]"]') || {}).value,
        person: s.selectedOptions[0] ? s.selectedOptions[0].text.trim() : '',
        persons: [...s.options].map(o => o.text.trim()).filter(Boolean),
        title: t.value,
        date: (document.getElementById('kb_item_is_valid_from') || {}).value,
        currency: cur && cur.selectedOptions[0] ? cur.selectedOptions[0].text : '',
      });
    },

    // Is a position form open? type: 'Custom' (priced) or 'Text'.
    formOpen: type => posForm(type) ? 'open' : 'closed',

    // Text position: fill the open form and save.
    addText: (html, optional) => {
      const f = posForm('Text'), ed = window.tinymce && tinymce.get('kb_position_text_text');
      if (!f || !ed) return 'text position form not open';
      ed.setContent(html.trim());
      tinymce.triggerSave();
      const o = f.elements['kb_position_text[is_optional]'];
      if (o && o.checked !== !!optional) o.click();
      return save(f) ? 'saved text position, optional=' + !!(o && o.checked) : 'no Speichern button';
    },

    // Priced position: fill the open form, return what the form now holds. Save with saveCustom().
    fillCustom: (html, price, optional, unitId) => {
      const f = posForm('Custom'), ed = window.tinymce && tinymce.get('kb_position_custom_text');
      if (!f || !ed) return 'priced position form not open';
      ed.setContent(html.trim());
      tinymce.triggerSave();
      const set = (n, v) => { const e = f.elements[n]; e.value = v; jq(e).trigger('change'); };
      set('kb_position_custom[amount]', '1');
      set('kb_position_custom[unit_id]', unitId || '1');
      set('kb_position_custom[unit_price]', price);
      const o = f.elements['kb_position_custom[is_optional]'];
      if (o && o.checked !== !!optional) o.click();
      const sel = n => { const e = f.elements[n]; return e && e.selectedOptions && e.selectedOptions[0] ? e.selectedOptions[0].text.trim() : ''; };
      return JSON.stringify({
        text: plain(f.elements['kb_position_custom[text]'].value).slice(0, 80) + '…',
        amount: f.elements['kb_position_custom[amount]'].value,
        unit: sel('kb_position_custom[unit_id]'),
        price: f.elements['kb_position_custom[unit_price]'].value,
        account: sel('kb_position_custom[account_id]'),
        tax: sel('kb_position_custom[tax_id]'),
        optional: !!(o && o.checked),
      });
    },
    saveCustom: () => { const f = posForm('Custom'); return f ? (save(f) ? 'saved priced position' : 'no Speichern button') : 'priced position form not open'; },

    // Open the edit form of a saved position, e.g. 'position_KbPositionText1019'.
    openEdit: rowId => {
      const a = document.querySelector('#' + rowId + ' a.editPosition');
      if (!a) return 'no such position: ' + rowId;
      a.click();
      return 'edit form opening';
    },

    // Change an open edit form. expect: text the position must contain now, or nothing is saved.
    // html and price may be null to keep them. Changing a price this way is untested.
    edit: (type, expect, html, price) => {
      const f = posForm(type), ed = window.tinymce && tinymce.get(type === 'Text' ? 'kb_position_text_text' : 'kb_position_custom_text');
      if (!f || !ed) return type + ' position form not open';
      const now = plain(ed.getContent());
      if (!now.includes(expect)) return 'wrong position, nothing saved. It holds: ' + now.slice(0, 100);
      if (html != null) { ed.setContent(html.trim()); tinymce.triggerSave(); }
      if (price != null && type === 'Custom') { const e = f.elements['kb_position_custom[unit_price]']; e.value = price; jq(e).trigger('change'); }
      return save(f) ? 'saved' : 'no Speichern button';
    },

    // Click a tab of the document page by its label ('Texte', 'Konditionen', 'Positionen', …).
    tab: name => {
      const a = [...document.querySelectorAll('#contentContainer a')].find(a => a.innerText.trim() === name);
      if (!a) return 'no tab ' + name;
      a.click();
      return 'tab ' + name;
    },

    // Texte tab must be open. null keeps the current text.
    setTexts: (header, footer) => {
      const h = window.tinymce && tinymce.get('kb_item_header'), f = window.tinymce && tinymce.get('kb_item_footer');
      if (!h || !f) return 'Texte tab not open';
      if (header != null) h.setContent(header.trim());
      if (footer != null) f.setContent(footer.trim());
      tinymce.triggerSave();
      const b = [...document.querySelectorAll('button, input[type=submit]')].find(b => /Texte speichern/.test(b.innerText || b.value || ''));
      if (!b) return 'no "Texte speichern" button';
      b.click();
      return 'texts saved';
    },
  };
  return 'helpers loaded';
})()
