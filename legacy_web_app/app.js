/* ══════════════════════════════════════════════════
   RKCNL Rastriye Krishi – app.js
   Field Survey Mobile App
   ══════════════════════════════════════════════════ */

/* ────────────────────────────────────
   STATE & STORAGE
──────────────────────────────────── */
const STATE = {
    currentScreen: 'screen-splash',
    prevScreen: null,
    currentTab: 'home',
    currentSurvey: null,
    currentRespondentIdx: null,
    formStep: 0,
    formAnswers: {},
    filterMode: 'all',
    user: { name: 'John Doe', initials: 'JD', phone: '+977 9801234567', empId: 'EMP-0042', region: 'Ward 4, Northern Sector', email: 'j.doe@rkcnl.gov.np' },
    notifications: [
        { id: 1, title: 'New Survey Assigned', msg: 'Crop Health Assessment – Ward 6 has been assigned to you.', time: '2 hrs ago', read: false, icon: 'assignment', color: 'green' },
        { id: 2, title: 'Sync Reminder', msg: 'You have 3 responses pending upload. Please sync when online.', time: '5 hrs ago', read: false, icon: 'cloud_sync', color: 'orange' },
        { id: 3, title: 'Deadline Alert', msg: 'Soil Moisture Survey due date is tomorrow. Please submit soon.', time: '1 day ago', read: true, icon: 'alarm', color: 'orange' },
        { id: 4, title: 'Account Update', msg: 'Your profile has been updated by admin. Region changed to Ward 4.', time: '2 days ago', read: true, icon: 'manage_accounts', color: 'blue' },
    ],
    syncHistory: [],
    isOnline: navigator.onLine,
};

/* LocalStorage Helpers */
const LS_KEY_RESPONSES = 'rkcnl_responses';
const LS_KEY_PENDING = 'rkcnl_pending';
const LS_KEY_SYNCED = 'rkcnl_synced';
const LS_KEY_SYNC_TIME = 'rkcnl_last_sync';
const LS_KEY_HISTORY = 'rkcnl_sync_history';
const LS_KEY_AUTH = 'rkcnl_auth';

function lsGet(key, def = null) { try { const v = localStorage.getItem(key); return v ? JSON.parse(v) : def; } catch { return def; } }
function lsSet(key, val) { try { localStorage.setItem(key, JSON.stringify(val)); } catch { console.warn('LS write failed'); } }

/* ────────────────────────────────────
   SURVEY DATA (from admin / simulated)
──────────────────────────────────── */
const SURVEYS = [
    {
        id: 'SRV-001', title: 'Crop Health Assessment – Ward 4', region: 'Northern Sector',
        due: 'Mar 10, 2026', priority: 'high', status: 'in_progress',
        icon: 'grass', color: '#1a6b1a',
        description: 'Evaluate crop health conditions across assigned plots in Ward 4.',
        questions: [
            { id: 'q1', type: 'radio', text: 'What is the current crop stage?', desc: 'Select the most accurate phase for the observation area.', options: ['Sowing', 'Vegetative', 'Flowering', 'Harvesting'] },
            { id: 'q2', type: 'radio', text: 'Overall crop health?', desc: 'Rate the general health condition of the crops observed.', options: ['Excellent', 'Good', 'Fair', 'Poor', 'Critical'] },
            { id: 'q3', type: 'checkbox', text: 'Issues observed (select all that apply):', desc: 'Mark all problems currently visible in the field.', options: ['Pest infestation', 'Disease signs', 'Nutrient deficiency', 'Water stress', 'Weed overgrowth', 'None'] },
            { id: 'q4', type: 'text', text: 'Field Observations', desc: 'Note any pests, soil moisture, weather impacts or additional details.', placeholder: 'Describe what you observed...' },
            { id: 'q5', type: 'rating', text: 'Estimated yield potential (1–10)?', desc: '1 = very low, 10 = excellent expected yield.', max: 10 },
            { id: 'q6', type: 'radio', text: 'Irrigation status?', desc: 'Current irrigation situation of the plot.', options: ['Adequate', 'Insufficient', 'Over-irrigated', 'Rain-fed only'] },
            { id: 'q7', type: 'text', text: 'Recommended action?', desc: 'Suggest the next steps or interventions needed.', placeholder: 'e.g. Apply fertilizer, drain field...' },
        ]
    },
    {
        id: 'SRV-002', title: 'Soil Moisture Survey – East Plains', region: 'Eastern Plains',
        due: 'Mar 15, 2026', priority: 'medium', status: 'pending',
        icon: 'water_drop', color: '#0d47a1',
        description: 'Measure and document soil moisture levels across Eastern Plains plots.',
        questions: [
            { id: 'q1', type: 'radio', text: 'Soil moisture level?', desc: 'Visual and tactile estimation of the soil moisture.', options: ['Very Dry', 'Dry', 'Moist', 'Wet', 'Waterlogged'] },
            { id: 'q2', type: 'radio', text: 'Soil texture?', desc: 'Primary texture of the soil in this plot.', options: ['Sandy', 'Loamy', 'Clay', 'Silt', 'Rocky'] },
            { id: 'q3', type: 'checkbox', text: 'Observed soil issues:', desc: 'Select all issues currently visible.', options: ['Erosion', 'Compaction', 'Salinization', 'Drainage problem', 'None'] },
            { id: 'q4', type: 'rating', text: 'Soil quality rating (1–10)?', desc: 'Your overall assessment of soil quality.', max: 10 },
            { id: 'q5', type: 'text', text: 'Additional notes:', desc: 'Any other observations about the soil condition.', placeholder: 'Enter details here...' },
        ]
    },
    {
        id: 'SRV-003', title: 'Irrigation Audit – Zone B', region: 'Central Hub',
        due: 'Feb 28, 2026', priority: 'low', status: 'synced',
        icon: 'water', color: '#2e7d32',
        description: 'Verify irrigation infrastructure and water distribution in Zone B.',
        questions: [
            { id: 'q1', type: 'radio', text: 'Irrigation system type?', desc: 'Primary irrigation method used in this zone.', options: ['Drip', 'Sprinkler', 'Flood', 'Canal', 'None'] },
            { id: 'q2', type: 'radio', text: 'System condition?', desc: 'Overall condition of the irrigation infrastructure.', options: ['Excellent', 'Good', 'Needs repair', 'Broken'] },
            { id: 'q3', type: 'checkbox', text: 'Issues with irrigation:', desc: 'Select all issues observed.', options: ['Leaking pipes', 'Clogged nozzles', 'Uneven distribution', 'Low pressure', 'None'] },
            { id: 'q4', type: 'text', text: 'Maintenance notes:', desc: 'Describe needed repairs or observations.', placeholder: 'Describe issues in detail...' },
        ]
    },
    {
        id: 'SRV-004', title: 'Livestock & Fodder Assessment – Ward 6', region: 'Western Zone',
        due: 'Mar 20, 2026', priority: 'high', status: 'pending',
        icon: 'pets', color: '#4e342e',
        description: 'Survey livestock count, fodder availability and animal health in Ward 6.',
        questions: [
            { id: 'q1', type: 'radio', text: 'Primary livestock species?', desc: 'Main animals being kept in this farm.', options: ['Cattle', 'Goats', 'Poultry', 'Pigs', 'Mixed'] },
            { id: 'q2', type: 'rating', text: 'Animal health rating (1–10)?', desc: 'General condition and vitality of the animals.', max: 10 },
            { id: 'q3', type: 'radio', text: 'Fodder availability?', desc: 'Current availability of animal feed and fodder.', options: ['Abundant', 'Adequate', 'Scarce', 'Critical shortage'] },
            { id: 'q4', type: 'checkbox', text: 'Issues observed:', desc: 'Select all concerns noted.', options: ['Disease signs', 'Malnutrition', 'Water shortage', 'Overcrowding', 'None'] },
            { id: 'q5', type: 'text', text: 'Additional notes:', desc: 'Any other observations about the livestock condition.', placeholder: 'Enter notes here...' },
        ]
    },
    {
        id: 'SRV-005', title: 'Post-harvest Loss Assessment', region: 'All Sectors',
        due: 'Mar 25, 2026', priority: 'medium', status: 'pending',
        icon: 'warehouse', color: '#6a1b9a',
        description: 'Estimate and document post-harvest losses for major crops.',
        questions: [
            { id: 'q1', type: 'radio', text: 'Primary crop assessed?', desc: 'The main crop being evaluated for harvest loss.', options: ['Rice', 'Wheat', 'Maize', 'Vegetables', 'Fruits', 'Other'] },
            { id: 'q2', type: 'rating', text: 'Estimated harvest loss (%)?', desc: 'Rate from 1 (very low <5%) to 10 (severe >50%).', max: 10 },
            { id: 'q3', type: 'checkbox', text: 'Causes of post-harvest loss:', desc: 'Select all relevant causes.', options: ['Pest damage', 'Moisture/mold', 'Poor storage', 'Transport damage', 'Market delay', 'None'] },
            { id: 'q4', type: 'radio', text: 'Storage facility used?', desc: 'Where is the harvested produce being stored?', options: ['Home storage', 'Community warehouse', 'Cooperative store', 'Cold storage', 'None – sold immediately'] },
            { id: 'q5', type: 'text', text: 'Recommendations:', desc: 'Suggest improvements to reduce post-harvest losses.', placeholder: 'e.g. Better storage containers, cold chain...' },
        ]
    },
];

/* Respondents storage */
function getRespondents(surveyId) { return lsGet('rkcnl_respondents_' + surveyId, []); }
function saveRespondent(surveyId, respondent) {
    const list = getRespondents(surveyId);
    const idx = list.findIndex(r => r.id === respondent.id);
    if (idx >= 0) list[idx] = respondent; else list.push(respondent);
    lsSet('rkcnl_respondents_' + surveyId, list);
}

/* ────────────────────────────────────
   NAVIGATION / ROUTER
──────────────────────────────────── */
function showScreen(id) {
    const prev = STATE.currentScreen;
    const screens = document.querySelectorAll('.screen');
    screens.forEach(s => { s.classList.remove('active'); s.style.display = ''; });
    const target = document.getElementById(id);
    if (!target) return;
    target.classList.add('active');
    target.style.display = 'flex';
    STATE.prevScreen = prev;
    STATE.currentScreen = id;
    // lifecycle hooks
    if (id === 'screen-sync') renderSync();
    if (id === 'screen-analytics') renderAnalytics();
    if (id === 'screen-notifications') renderNotifications();
    if (id === 'screen-dashboard') refreshDashboard();
    if (id === 'screen-surveys') renderSurveys();
}

function goBack() { if (STATE.prevScreen) showScreen(STATE.prevScreen); else showScreen('screen-dashboard'); }

function switchTab(tab) {
    STATE.currentTab = tab;
    const tabScreenMap = { home: 'screen-dashboard', surveys: 'screen-surveys', sync: 'screen-sync', analytics: 'screen-analytics' };
    const screenId = tabScreenMap[tab] || 'screen-dashboard';
    showScreen(screenId);
    // Update all bottom navs
    document.querySelectorAll('.nav-item').forEach(el => { el.classList.toggle('active', el.dataset.tab === tab); });
}

/* ────────────────────────────────────
   SPLASH SCREEN
──────────────────────────────────── */
function runSplash() {
    const fill = document.getElementById('splashLoader');
    let w = 0;
    const iv = setInterval(() => {
        w += 2.5;
        fill.style.width = Math.min(w, 100) + '%';
        if (w >= 100) { clearInterval(iv); setTimeout(afterSplash, 300); }
    }, 30);
}
function afterSplash() {
    const auth = lsGet(LS_KEY_AUTH);
    if (auth && auth.loggedIn) {
        applyUserState(auth);
        showScreen('screen-dashboard');
    } else {
        showScreen('screen-login');
    }
}

/* ────────────────────────────────────
   AUTH
──────────────────────────────────── */
function doLogin() {
    const u = document.getElementById('loginUser').value.trim();
    const p = document.getElementById('loginPass').value;
    const err = document.getElementById('loginError');
    if (!u || !p) { err.classList.remove('hidden'); err.textContent = 'Please enter your credentials.'; return; }
    err.classList.add('hidden');
    // Simulate login (accept any non-empty credentials)
    const user = { loggedIn: true, name: u.includes('@') ? 'Field Surveyor' : (u.charAt(0).toUpperCase() + u.slice(1)), initials: u.slice(0, 2).toUpperCase(), phone: u.startsWith('+') ? u : '+977 98XXXXXXXX' };
    lsSet(LS_KEY_AUTH, user);
    applyUserState(user);
    showScreen('screen-dashboard');
    showToast('Welcome back, ' + user.name + '!');
}
function applyUserState(user) {
    STATE.user.name = user.name || 'Field Surveyor';
    STATE.user.initials = user.initials || 'FS';
    // Update UI
    ['headerAvatar', 'headerAvatar2'].forEach(id => { const el = document.getElementById(id); if (el) el.textContent = STATE.user.initials; });
    const wn = document.getElementById('welcomeName'); if (wn) wn.textContent = STATE.user.name;
    const pn = document.getElementById('profileName'); if (pn) pn.textContent = STATE.user.name;
    const pa = document.getElementById('profileAvatar'); if (pa) pa.textContent = STATE.user.initials;
}
function doLogout() {
    lsSet(LS_KEY_AUTH, { loggedIn: false });
    showScreen('screen-login');
    document.getElementById('loginUser').value = '';
    document.getElementById('loginPass').value = '';
    showToast('You have been logged out.');
}
function togglePass(inputId, btn) {
    const inp = document.getElementById(inputId);
    const icon = btn.querySelector('.material-symbols-outlined');
    if (inp.type === 'password') { inp.type = 'text'; icon.textContent = 'visibility_off'; }
    else { inp.type = 'password'; icon.textContent = 'visibility'; }
}

/* OTP */
function sendOTP() {
    const ph = document.getElementById('otpPhone').value.trim();
    if (!ph) { showToast('Please enter your phone number.'); return; }
    document.getElementById('otp-verify-section').classList.remove('hidden');
    showToast('OTP sent to ' + ph);
}
function otpMove(el, idx) {
    if (el.value.length === 1) { const next = document.querySelectorAll('.otp-box')[idx + 1]; if (next) next.focus(); }
}
function verifyOTP() {
    const boxes = document.querySelectorAll('.otp-box');
    const code = Array.from(boxes).map(b => b.value).join('');
    if (code.length < 4) { showToast('Please enter the 4-digit OTP.'); return; }
    const user = { loggedIn: true, name: 'Field Surveyor', initials: 'FS' };
    lsSet(LS_KEY_AUTH, user);
    applyUserState(user);
    showScreen('screen-dashboard');
    showToast('Login successful!');
}

/* ────────────────────────────────────
   DASHBOARD
──────────────────────────────────── */
function refreshDashboard() {
    const pending = lsGet(LS_KEY_PENDING, []);
    const synced = lsGet(LS_KEY_SYNCED, []);
    const allRespondents = SURVEYS.flatMap(s => getRespondents(s.id));
    const completedToday = allRespondents.filter(r => r.status === 'completed' && isToday(r.completedAt)).length;
    document.getElementById('statAssigned').textContent = SURVEYS.filter(s => s.status !== 'synced').length;
    document.getElementById('statCompleted').textContent = completedToday;
    document.getElementById('statPendingSync').textContent = pending.length;
    const badge = document.getElementById('pendingSyncBadge');
    if (badge) { badge.textContent = pending.length > 0 ? 'Needs sync' : 'All clear'; badge.className = 'stat-badge ' + (pending.length > 0 ? 'orange' : 'green'); }
    // offline banner
    document.getElementById('offlineBanner').classList.toggle('hidden', STATE.isOnline);
    // recent activity
    renderRecentActivity();
    // alert bell
    const unread = STATE.notifications.filter(n => !n.read).length;
    const bell = document.getElementById('alertBell');
    if (bell) bell.style.color = unread > 0 ? 'var(--orange)' : '';
}
function isToday(ts) { if (!ts) return false; const d = new Date(ts), n = new Date(); return d.toDateString() === n.toDateString(); }
function renderRecentActivity() {
    const el = document.getElementById('recentActivity'); if (!el) return;
    const allR = SURVEYS.flatMap(s => getRespondents(s.id).map(r => ({ ...r, surveyTitle: s.title }))).sort((a, b) => (b.completedAt || 0) - (a.completedAt || 0)).slice(0, 5);
    if (!allR.length) { el.innerHTML = '<p class="empty-state">No recent activity yet. Start collecting responses!</p>'; return; }
    el.innerHTML = allR.map(r => `<div class="recent-item"><div class="recent-dot ${r.status === 'completed' ? 'green' : r.status === 'draft' ? 'blue' : 'orange'}"></div><div class="recent-text"><strong>${r.name || 'Respondent'}</strong><br><span style="font-size:12px;color:var(--text-sub)">${r.surveyTitle}</span></div><div class="recent-time">${timeAgo(r.completedAt || r.startedAt)}</div></div>`).join('');
}

/* ────────────────────────────────────
   SURVEYS LIST
──────────────────────────────────── */
let surveyFilterActive = 'all';
function renderSurveys() {
    const container = document.getElementById('surveysContainer');
    if (!container) return;
    const search = (document.getElementById('surveySearch')?.value || '').toLowerCase();
    const list = SURVEYS.filter(s => {
        const matchFilter = surveyFilterActive === 'all' || s.status === surveyFilterActive;
        const matchSearch = !search || s.title.toLowerCase().includes(search) || s.id.toLowerCase().includes(search) || s.region.toLowerCase().includes(search);
        return matchFilter && matchSearch;
    });
    if (!list.length) { container.innerHTML = '<p class="empty-state" style="padding-top:40px">No surveys match your filters.</p>'; return; }
    container.innerHTML = list.map(s => surveyCard(s)).join('');
}
function surveyCard(s) {
    const respondents = getRespondents(s.id);
    const btnHtml = s.status === 'synced'
        ? `<button class="survey-card-btn card-btn-disabled" disabled>Completed & Synced</button>`
        : `<button class="survey-card-btn card-btn-primary" onclick="openRespondents('${s.id}')">
        ${s.status === 'in_progress' ? 'Continue Collection' : 'Start Collection'}
       </button>`;
    const statusClass = { in_progress: 'in-progress', pending: 'pending', synced: 'synced', draft: 'draft' }[s.status] || 'pending';
    const statusLabel = { in_progress: 'In Progress', pending: 'Pending', synced: 'Synced', draft: 'Draft' }[s.status] || 'Pending';
    const priorityColors = { high: 'var(--red)', medium: 'var(--orange)', low: 'var(--green)' };
    return `<div class="survey-card">
    <div class="survey-card-img" style="background:linear-gradient(135deg,${s.color}dd,${s.color}88)">
      <span class="material-symbols-outlined">${s.icon}</span>
      <span class="card-id-badge">${s.id}</span>
    </div>
    <div class="survey-card-body">
      <div class="survey-card-title-row">
        <h3 class="survey-card-title">${s.title}</h3>
        <span class="status-badge ${statusClass}">${statusLabel}</span>
      </div>
      <div class="survey-card-meta">
        <div class="meta-item"><span class="material-symbols-outlined">location_on</span>${s.region}</div>
        <div class="meta-item"><span class="material-symbols-outlined">calendar_today</span>Due ${s.due}</div>
        <div class="meta-item"><span class="material-symbols-outlined" style="color:${priorityColors[s.priority]}">priority_high</span>${s.priority.charAt(0).toUpperCase() + s.priority.slice(1)} Priority</div>
        <div class="meta-item"><span class="material-symbols-outlined">group</span>${respondents.length} Respondent${respondents.length !== 1 ? 's' : ''}</div>
      </div>
      <div class="respondents-count-chip"><span class="material-symbols-outlined">people</span>${respondents.length} response${respondents.length !== 1 ? 's' : ''} collected</div>
      ${btnHtml}
    </div>
  </div>`;
}
function setFilter(btn, mode) {
    surveyFilterActive = mode;
    document.querySelectorAll('.pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    renderSurveys();
}
function filterSurveys() {
    const val = document.getElementById('surveySearch')?.value || '';
    document.getElementById('clearSearch').style.display = val ? 'block' : 'none';
    renderSurveys();
}
function clearSurveySearch() { document.getElementById('surveySearch').value = ''; document.getElementById('clearSearch').style.display = 'none'; renderSurveys(); }

/* ────────────────────────────────────
   RESPONDENTS SCREEN
──────────────────────────────────── */
function openRespondents(surveyId) {
    const survey = SURVEYS.find(s => s.id === surveyId);
    if (!survey) return;
    STATE.currentSurvey = survey;
    document.getElementById('respondentsTitle').textContent = survey.title;
    document.getElementById('respondentsSurveyInfo').innerHTML = `<h3>${survey.id}: ${survey.title}</h3><p>${survey.region} &bull; Due ${survey.due}</p>`;
    renderRespondentsList();
    showScreen('screen-respondents');
}
function renderRespondentsList() {
    const container = document.getElementById('respondentsList');
    const survey = STATE.currentSurvey;
    if (!container || !survey) return;
    const respondents = getRespondents(survey.id);
    if (!respondents.length) {
        container.innerHTML = `<div style="text-align:center;padding:48px 20px"><span class="material-symbols-outlined" style="font-size:56px;color:var(--text-muted)">people</span><p style="font-size:16px;font-weight:700;color:var(--text);margin-top:12px">No respondents yet</p><p style="font-size:13px;color:var(--text-sub);margin-top:6px">Tap the + button to add your first respondent</p></div>`;
        return;
    }
    container.innerHTML = respondents.map((r, i) => `
    <div class="respondent-item" onclick="editRespondent(${i})">
      <div class="respondent-avatar">${(r.name || '?').slice(0, 2).toUpperCase()}</div>
      <div class="respondent-info">
        <div class="respondent-name">${r.name || 'Unknown'}</div>
        <div class="respondent-meta">${r.phone || ''} ${r.age ? '&bull; Age ' + r.age : ''}</div>
      </div>
      <span class="respondent-status ${r.status}">${r.status === 'completed' ? 'Done' : r.status === 'draft' ? 'Draft' : 'Pending'}</span>
    </div>`).join('');
}
function showAddRespondent() {
    document.getElementById('modal-content').innerHTML = `
    <div class="modal-handle"></div>
    <h3>Add Respondent</h3>
    <div class="form-group"><label class="form-label">Full Name *</label><div class="input-wrap"><span class="material-symbols-outlined input-icon">person</span><input id="respName" type="text" class="form-input" placeholder="Respondent's full name"/></div></div>
    <div class="form-group"><label class="form-label">Phone Number</label><div class="input-wrap"><span class="material-symbols-outlined input-icon">phone</span><input id="respPhone" type="tel" class="form-input" placeholder="+977 98XXXXXXXX"/></div></div>
    <div class="form-group"><label class="form-label">Age</label><div class="input-wrap"><span class="material-symbols-outlined input-icon">cake</span><input id="respAge" type="number" class="form-input" placeholder="Age (optional)"/></div></div>
    <div class="form-group"><label class="form-label">Gender</label><select id="respGender" class="form-input" style="border:1.5px solid var(--border);border-radius:8px;padding:13px 12px;width:100%;background:var(--bg);color:var(--text)"><option value="">Select gender</option><option>Male</option><option>Female</option><option>Other</option></select></div>
    <button class="btn-primary" onclick="saveNewRespondent()">Add & Start Survey</button>`;
    openModal();
}
function saveNewRespondent() {
    const name = document.getElementById('respName')?.value.trim();
    if (!name) { showToast('Please enter the respondent name.'); return; }
    const r = { id: Date.now().toString(), name, phone: document.getElementById('respPhone')?.value.trim(), age: document.getElementById('respAge')?.value, gender: document.getElementById('respGender')?.value, status: 'pending', startedAt: Date.now() };
    saveRespondent(STATE.currentSurvey.id, r);
    STATE.currentRespondentIdx = getRespondents(STATE.currentSurvey.id).length - 1;
    closeModal();
    startSurveyForm(STATE.currentSurvey, r);
}
function editRespondent(idx) {
    const r = getRespondents(STATE.currentSurvey.id)[idx];
    if (!r) return;
    STATE.currentRespondentIdx = idx;
    if (r.status === 'completed') { showToast('This response is already completed.'); return; }
    startSurveyForm(STATE.currentSurvey, r);
}

/* ────────────────────────────────────
   SURVEY FORM (multi-step)
──────────────────────────────────── */
function startSurveyForm(survey, respondent) {
    STATE.currentSurvey = survey;
    STATE.formStep = 0;
    STATE.formAnswers = respondent.answers ? { ...respondent.answers } : {};
    renderFormStep();
    showScreen('screen-form');
}
function renderFormStep() {
    const questions = STATE.currentSurvey.questions;
    const step = STATE.formStep;
    const total = questions.length + 1; // +1 for review step
    const pct = Math.round((step / total) * 100);
    document.getElementById('stepLabel').textContent = `Step ${step + 1} of ${total}`;
    document.getElementById('progressPct').textContent = pct + '% Complete';
    document.getElementById('progressFill').style.width = pct + '%';
    document.getElementById('formPrevBtn').style.display = step === 0 ? 'none' : '';

    if (step >= questions.length) { renderReviewStep(); return; }
    const q = questions[step];
    document.getElementById('formNextBtn').textContent = step < total - 2 ? 'Next Step' : 'Review';
    document.getElementById('formNextBtn').innerHTML = step < total - 2
        ? 'Next Step <span class="material-symbols-outlined btn-icon">arrow_forward</span>'
        : 'Review Answers <span class="material-symbols-outlined btn-icon">checklist</span>';
    const saved = STATE.formAnswers[q.id];
    let html = `<div class="form-question"><h3>${q.text}</h3>${q.desc ? `<p>${q.desc}</p>` : ''}`;
    if (q.type === 'radio') {
        html += q.options.map(o => `<div class="radio-option ${saved === o ? 'selected' : ''}" onclick="selectRadio(this,'${q.id}','${o.replace(/'/, "\\'")}')">${o}<div class="radio-circle"><div class="dot"></div></div></div>`).join('');
    } else if (q.type === 'checkbox') {
        const savedArr = saved || [];
        html += q.options.map(o => `<div class="checkbox-option ${savedArr.includes(o) ? 'selected' : ''}" onclick="toggleCheckbox(this,'${q.id}','${o.replace(/'/, "\\'")}')">${o}<div class="checkbox-sq"><span class="material-symbols-outlined">check</span></div></div>`).join('');
    } else if (q.type === 'text') {
        html += `<div class="input-wrap"><textarea class="form-input" rows="5" placeholder="${q.placeholder || ''}" id="textAnswer" oninput="STATE.formAnswers['${q.id}']=this.value">${saved || ''}</textarea></div>`;
    } else if (q.type === 'rating') {
        html += `<div class="rating-row">${Array.from({ length: q.max || 10 }, (_, i) => `<button class="rating-btn ${saved === (i + 1) ? 'selected' : ''}" onclick="selectRating(this,'${q.id}',${i + 1})">${i + 1}</button>`).join('')}</div>`;
    }
    html += '</div>';
    document.getElementById('formBody').innerHTML = html;
}
function renderReviewStep() {
    const q = STATE.currentSurvey.questions;
    document.getElementById('formNextBtn').innerHTML = 'Submit Response <span class="material-symbols-outlined btn-icon">check_circle</span>';
    document.getElementById('stepLabel').textContent = `Review – Step ${q.length + 1} of ${q.length + 1}`;
    document.getElementById('progressPct').textContent = '100% Complete';
    document.getElementById('progressFill').style.width = '100%';
    const rows = q.map(qu => {
        const ans = STATE.formAnswers[qu.id];
        const display = Array.isArray(ans) ? ans.join(', ') : (ans != null ? String(ans) : '<em style="color:var(--text-muted)">Skipped</em>');
        return `<div style="padding:12px 0;border-bottom:1px solid var(--border)"><p style="font-size:12px;color:var(--text-muted);margin-bottom:4px">${qu.text}</p><p style="font-size:15px;font-weight:600;color:var(--text)">${display}</p></div>`;
    }).join('');
    document.getElementById('formBody').innerHTML = `<div class="form-question"><h3>Review Your Answers</h3><p>Check your responses before submitting.</p>${rows}</div>`;
}
function selectRadio(el, qId, val) { STATE.formAnswers[qId] = val; document.querySelectorAll('.radio-option').forEach(e => e.classList.remove('selected')); el.classList.add('selected'); }
function toggleCheckbox(el, qId, val) {
    const arr = STATE.formAnswers[qId] || [];
    const idx = arr.indexOf(val);
    if (idx >= 0) arr.splice(idx, 1); else arr.push(val);
    STATE.formAnswers[qId] = arr;
    el.classList.toggle('selected', arr.includes(val));
}
function selectRating(el, qId, val) { STATE.formAnswers[qId] = val; document.querySelectorAll('.rating-btn').forEach(e => e.classList.remove('selected')); el.classList.add('selected'); }
function formNext() {
    const q = STATE.currentSurvey.questions;
    if (STATE.formStep > q.length) return;
    if (STATE.formStep === q.length) { submitForm(); return; }
    // auto-save text answers
    const ta = document.getElementById('textAnswer'); if (ta) STATE.formAnswers[q[STATE.formStep].id] = ta.value;
    saveDraft();
    STATE.formStep++;
    renderFormStep();
}
function formPrev() { if (STATE.formStep > 0) { STATE.formStep--; renderFormStep(); } }
function formBack() { saveDraft(); if (STATE.currentSurvey) openRespondents(STATE.currentSurvey.id); else showScreen('screen-surveys'); }
function saveDraft() {
    if (!STATE.currentSurvey) return;
    const respondents = getRespondents(STATE.currentSurvey.id);
    const r = respondents[STATE.currentRespondentIdx];
    if (!r) return;
    r.answers = { ...STATE.formAnswers };
    r.status = 'draft';
    saveRespondent(STATE.currentSurvey.id, r);
    // mark survey as in_progress
    const sv = SURVEYS.find(s => s.id === STATE.currentSurvey.id);
    if (sv && sv.status === 'pending') sv.status = 'in_progress';
}
function submitForm() {
    const respondents = getRespondents(STATE.currentSurvey.id);
    const r = respondents[STATE.currentRespondentIdx];
    if (!r) { showScreen('screen-surveys'); return; }
    r.answers = { ...STATE.formAnswers };
    r.status = 'completed';
    r.completedAt = Date.now();
    saveRespondent(STATE.currentSurvey.id, r);

    // Add to pending sync
    const pending = lsGet(LS_KEY_PENDING, []);
    pending.push({ id: r.id, surveyId: STATE.currentSurvey.id, surveyTitle: STATE.currentSurvey.title, respondent: r.name, savedAt: Date.now() });
    lsSet(LS_KEY_PENDING, pending);

    // Update survey status
    const sv = SURVEYS.find(s => s.id === STATE.currentSurvey.id);
    if (sv) sv.status = 'in_progress';

    // Show success
    document.getElementById('formBody').innerHTML = `<div class="success-screen"><div class="success-icon"><span class="material-symbols-outlined">check_circle</span></div><h2>Response Saved!</h2><p style="margin-bottom:8px">Response for <strong>${r.name || 'Respondent'}</strong> has been saved successfully.</p><p style="font-size:12px;color:var(--text-muted)">${STATE.isOnline ? 'Syncing with server...' : 'Saved offline. Will sync when online.'}</p></div>`;
    const ftr = document.querySelector('#screen-form .form-footer');
    if (ftr) ftr.innerHTML = `<button class="btn-secondary" onclick="openRespondents('${STATE.currentSurvey.id}')">Back to Respondents</button><button class="btn-primary flex1" onclick="showAddRespondent()">Add Another <span class="material-symbols-outlined btn-icon">person_add</span></button>`;

    if (STATE.isOnline) { setTimeout(() => { autoSyncOne(pending[pending.length - 1]); }, 1500); }
}

/* ────────────────────────────────────
   SYNC
──────────────────────────────────── */
function renderSync() {
    const pending = lsGet(LS_KEY_PENDING, []);
    const lastSync = lsGet(LS_KEY_SYNC_TIME);
    const history = lsGet(LS_KEY_HISTORY, []);
    // Status card
    const icon = document.getElementById('syncStatusIcon');
    const title = document.getElementById('syncStatusTitle');
    const sub = document.getElementById('syncStatusSub');
    if (pending.length > 0) {
        icon.className = 'sync-status-icon orange'; icon.innerHTML = '<span class="material-symbols-outlined">cloud_upload</span>';
        title.textContent = pending.length + ' Pending Upload' + (pending.length > 1 ? 's' : '');
        sub.textContent = 'Last sync: ' + (lastSync ? timeAgo(lastSync) : 'Never');
    } else {
        icon.className = 'sync-status-icon'; icon.innerHTML = '<span class="material-symbols-outlined">cloud_done</span>';
        title.textContent = 'All Data Synced';
        sub.textContent = 'Last sync: ' + (lastSync ? timeAgo(lastSync) : 'Never');
    }
    // Pending list
    const pl = document.getElementById('pendingList');
    pl.innerHTML = pending.length ? pending.map(p => `<div class="pending-item"><span class="material-symbols-outlined">upload_file</span><div class="pending-info"><p>${p.surveyTitle || 'Survey Response'}</p><span>${p.respondent || 'Unknown respondent'} &bull; ${timeAgo(p.savedAt)}</span></div></div>`).join('') : '<p class="empty-state">No pending data to sync.</p>';
    // History
    const hl = document.getElementById('syncHistoryList');
    hl.innerHTML = history.length ? history.slice(-8).reverse().map(h => `<div class="sync-history-item"><span class="material-symbols-outlined">check_circle</span><span class="shi-text">${h.count} response${h.count > 1 ? 's' : ''} synced</span><span class="shi-time">${timeAgo(h.ts)}</span></div>`).join('') : '<p class="empty-state">No sync history yet.</p>';
    // Update stats on dashboard
    document.getElementById('statPendingSync') && (document.getElementById('statPendingSync').textContent = pending.length);
}
function doSync() {
    const pending = lsGet(LS_KEY_PENDING, []);
    if (!pending.length) { showToast('Nothing to sync – all data is up to date!'); return; }
    if (!STATE.isOnline) { showToast('No internet connection. Please connect to sync.'); return; }
    const syncIcon = document.getElementById('syncNavIcon');
    const syncIcon2 = document.getElementById('syncNavIcon2');
    [syncIcon, syncIcon2].forEach(el => el && el.classList.add('spinning'));
    showToast('Syncing ' + pending.length + ' response' + (pending.length > 1 ? 's' : '') + '...');
    setTimeout(() => {
        const count = pending.length;
        const synced = lsGet(LS_KEY_SYNCED, []);
        synced.push(...pending);
        lsSet(LS_KEY_SYNCED, synced);
        lsSet(LS_KEY_PENDING, []);
        const now = Date.now();
        lsSet(LS_KEY_SYNC_TIME, now);
        const history = lsGet(LS_KEY_HISTORY, []);
        history.push({ count, ts: now });
        lsSet(LS_KEY_HISTORY, history);
        // Mark synced surveys
        pending.forEach(p => { const sv = SURVEYS.find(s => s.id === p.surveyId); if (sv) { const r = getRespondents(sv.id); if (r.every(rr => rr.status === 'completed')) sv.status = 'synced'; } });
        [syncIcon, syncIcon2].forEach(el => el && el.classList.remove('spinning'));
        showToast('✓ ' + count + ' response' + (count > 1 ? 's' : '') + ' synced successfully!');
        if (document.getElementById('screen-sync').classList.contains('active')) renderSync();
        refreshDashboard();
    }, 2000);
}
function autoSyncOne(item) {
    showToast('Auto-syncing response...');
    setTimeout(() => {
        const pending = lsGet(LS_KEY_PENDING, []);
        const remaining = pending.filter(p => p.id !== item.id);
        const synced = lsGet(LS_KEY_SYNCED, []);
        synced.push(item);
        lsSet(LS_KEY_PENDING, remaining);
        lsSet(LS_KEY_SYNCED, synced);
        lsSet(LS_KEY_SYNC_TIME, Date.now());
        const history = lsGet(LS_KEY_HISTORY, []);
        history.push({ count: 1, ts: Date.now() });
        lsSet(LS_KEY_HISTORY, history);
        showToast('✓ Response synced successfully!');
    }, 2000);
}

/* ── Settings helpers ── */
function clearCache() { ['rkcnl_responses', 'rkcnl_pending'].forEach(k => localStorage.removeItem(k)); updateStorageUsed(); showToast('Cache cleared.'); }
function updateStorageUsed() { const el = document.getElementById('storageUsed'); if (!el) return; try { let total = 0; for (let k in localStorage) { if (k.startsWith('rkcnl')) total += localStorage[k].length; }; el.textContent = (total / 1024).toFixed(1) + ' KB used'; } catch { el.textContent = 'Unable to calculate'; } }
function toggleDarkMode(cb) { document.body.classList.toggle('dark-mode', cb.checked); }

/* ────────────────────────────────────
   ANALYTICS
──────────────────────────────────── */
function renderAnalytics() {
    const allRespondents = SURVEYS.flatMap(s => getRespondents(s.id).map(r => ({ ...r, surveyTitle: s.title, surveyId: s.id })));
    const total = allRespondents.length;
    const completed = allRespondents.filter(r => r.status === 'completed').length;
    const pending = lsGet(LS_KEY_PENDING, []).length;
    const synced = lsGet(LS_KEY_SYNCED, []).length;
    const pct = total ? Math.round((completed / total) * 100) : 0;
    const container = document.getElementById('analyticsContent'); if (!container) return;
    // Per-survey breakdown for bar chart
    const surveyStats = SURVEYS.map(s => { const r = getRespondents(s.id); return { title: s.title.split('–')[0].trim(), count: r.filter(rr => rr.status === 'completed').length, total: r.length }; });
    const maxCount = Math.max(...surveyStats.map(s => s.count), 1);
    container.innerHTML = `
    <div class="analytics-banner"><h2>📊 My Survey Analytics</h2><p>Performance summary for your assigned surveys</p></div>
    <div class="analytics-grid">
      <div class="analytics-card"><div class="ac-label">Total Responses</div><div class="ac-value">${total}</div><div class="ac-sub">All respondents</div></div>
      <div class="analytics-card"><div class="ac-label">Completed</div><div class="ac-value" style="color:var(--green)">${completed}</div><div class="ac-sub">${pct}% completion rate</div></div>
      <div class="analytics-card"><div class="ac-label">Pending Sync</div><div class="ac-value" style="color:var(--orange)">${pending}</div><div class="ac-sub">Awaiting upload</div></div>
      <div class="analytics-card"><div class="ac-label">Total Synced</div><div class="ac-value" style="color:var(--blue)">${synced}</div><div class="ac-sub">Uploaded to server</div></div>
    </div>
    <div class="bar-chart">
      <h4>Responses per Survey</h4>
      ${surveyStats.map(s => `<div class="bar-row"><div class="bar-label">${s.title.slice(0, 14)}</div><div class="bar-track"><div class="bar-fill" style="width:${maxCount ? ((s.count / maxCount) * 100) : 0}%"></div></div><div class="bar-count">${s.count}</div></div>`).join('')}
    </div>
    <div class="donut-section">
      <h4>Response Status Breakdown</h4>
      <div class="donut-legend">
        ${[{ label: 'Completed', val: completed, color: 'var(--green)' }, { label: 'In Progress (Draft)', val: allRespondents.filter(r => r.status === 'draft').length, color: 'var(--blue)' }, { label: 'Pending', val: allRespondents.filter(r => r.status === 'pending').length, color: 'var(--text-muted)' }].map(i => `<div class="legend-item"><div class="legend-dot" style="background:${i.color}"></div><span class="legend-label">${i.label}</span><span class="legend-val">${i.val}</span></div>`).join('')}
      </div>
    </div>
    <div class="bar-chart">
      <h4>Survey Completion Rate</h4>
      ${SURVEYS.map(s => { const r = getRespondents(s.id); const c = r.filter(rr => rr.status === 'completed').length; const p = r.length ? Math.round((c / r.length) * 100) : 0; return `<div class="progress-bar-item"><div class="pbi-header"><span class="pbi-label">${s.id}</span><span class="pbi-pct">${p}%</span></div><div class="pbi-track"><div class="pbi-fill" style="width:${p}%;background:${p > 70 ? 'var(--green)' : p > 30 ? 'var(--orange)' : 'var(--red)'}"></div></div></div>` }).join('')}
    </div>
    <div style="height:16px"></div>
  `;
}

/* ────────────────────────────────────
   NOTIFICATIONS
──────────────────────────────────── */
function renderNotifications() {
    const el = document.getElementById('notifList'); if (!el) return;
    el.innerHTML = STATE.notifications.map((n, i) => `
    <div class="notif-item ${n.read ? '' : 'unread'}" onclick="markRead(${i})">
      <div class="notif-icon ${n.color}"><span class="material-symbols-outlined">${n.icon}</span></div>
      <div class="notif-body"><div class="notif-title">${n.title}</div><div class="notif-msg">${n.msg}</div><div class="notif-time">${n.time}</div></div>
      ${!n.read ? '<div class="notif-unread-dot"></div>' : ''}
    </div>`).join('');
}
function markRead(i) { STATE.notifications[i].read = true; renderNotifications(); }
function markAllRead() { STATE.notifications.forEach(n => n.read = true); renderNotifications(); showToast('All notifications marked as read.'); }

/* ────────────────────────────────────
   MODAL
──────────────────────────────────── */
function openModal() {
    document.getElementById('modal-overlay').classList.remove('hidden');
    document.getElementById('modal').classList.remove('hidden');
}
function closeModal() {
    document.getElementById('modal-overlay').classList.add('hidden');
    document.getElementById('modal').classList.add('hidden');
}

/* ────────────────────────────────────
   TOAST
──────────────────────────────────── */
let toastTimer;
function showToast(msg) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => t.classList.remove('show'), 3000);
}

/* ────────────────────────────────────
   TIME UTILS
──────────────────────────────────── */
function timeAgo(ts) {
    if (!ts) return 'Unknown';
    const diff = Date.now() - ts;
    if (diff < 60000) return 'Just now';
    if (diff < 3600000) return Math.floor(diff / 60000) + ' min ago';
    if (diff < 86400000) return Math.floor(diff / 3600000) + ' hr ago';
    return Math.floor(diff / 86400000) + ' day' + (Math.floor(diff / 86400000) > 1 ? 's' : '') + ' ago';
}

/* ────────────────────────────────────
   ONLINE / OFFLINE DETECTION
──────────────────────────────────── */
window.addEventListener('online', () => {
    STATE.isOnline = true;
    document.getElementById('offlineBanner')?.classList.add('hidden');
    showToast('Back online! Auto-syncing...');
    const autoSync = document.getElementById('autoSyncToggle');
    if (!autoSync || autoSync.checked) { setTimeout(doSync, 1500); }
});
window.addEventListener('offline', () => {
    STATE.isOnline = false;
    document.getElementById('offlineBanner')?.classList.remove('hidden');
    showToast('You are offline. Responses will be saved locally.');
});

/* ────────────────────────────────────
   INIT
──────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
    updateStorageUsed();
    runSplash();
    // Keyboard back button
    document.addEventListener('keydown', e => { if (e.key === 'Escape') goBack(); });
});
