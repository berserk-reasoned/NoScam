// Prototype State Management
const state = {
  language: 'en',
  role: null, // 'user' or 'guardian'
  uid: null,
  linkedUserUid: null, // For guardians
  fcmToken: 'mock-fcm-token-' + Math.floor(Math.random() * 1000)
};

// --- UI NAVIGATION ---
function showScreen(screenId) {
  // Hide all screens
  document.querySelectorAll('.screen').forEach(el => el.classList.add('hidden'));
  // Show target
  document.getElementById(screenId).classList.remove('hidden');
}

function showToast(message) {
  const container = document.getElementById('toast-container');
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerText = message;
  container.appendChild(toast);
  
  setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

// --- APP FLOW ---
const app = {
  selectLanguage(lang) {
    state.language = lang;
    showScreen('screen-role');
  },

  selectRole(role) {
    state.role = role;
    showScreen('screen-auth');
  },

  simulateLogin() {
    // Generate a fake UID
    state.uid = 'uid_' + Math.random().toString(36).substr(2, 9);
    localStorage.setItem('scamshield_uid', state.uid);
    localStorage.setItem('scamshield_role', state.role);
    
    // Save to "Firestore" (Mocked via LocalStorage)
    const users = JSON.parse(localStorage.getItem('db_users') || '{}');
    if (!users[state.uid]) {
      users[state.uid] = { role: state.role, fcm_token: state.fcmToken, guardians: [] };
      localStorage.setItem('db_users', JSON.stringify(users));
    }

    if (state.role === 'user') {
      showScreen('screen-pairing-user');
    } else {
      showScreen('screen-pairing-guardian');
    }
  },

  // --- PAIRING LOGIC (MOCK FIRESTORE) ---
  generatePairingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    
    // Save to "Firestore" pairing_codes collection
    const pairings = JSON.parse(localStorage.getItem('db_pairings') || '{}');
    pairings[code] = {
      creator_uid: state.uid,
      timestamp: Date.now()
    };
    localStorage.setItem('db_pairings', JSON.stringify(pairings));
    
    document.getElementById('generated-code').innerText = code;
    showToast("Code generated! Waiting for guardian...");

    // Poll for Guardian connection (Simulating Firestore onSnapshot)
    this.pollForConnection();
  },

  pollForConnection() {
    const interval = setInterval(() => {
      const users = JSON.parse(localStorage.getItem('db_users') || '{}');
      const myProfile = users[state.uid];
      if (myProfile && myProfile.guardians && myProfile.guardians.length > 0) {
        clearInterval(interval);
        showToast("Guardian connected!");
        showScreen('screen-user-dash');
      }
    }, 2000);
  },

  submitPairingCode() {
    const code = document.getElementById('pairing-input').value.toUpperCase();
    const pairings = JSON.parse(localStorage.getItem('db_pairings') || '{}');
    
    const pairingDoc = pairings[code];
    if (pairingDoc) {
      // Check 10 min TTL (600,000 ms)
      if (Date.now() - pairingDoc.timestamp > 600000) {
        showToast("Code expired!");
        return;
      }
      
      const userUid = pairingDoc.creator_uid;
      state.linkedUserUid = userUid;
      
      // Update User profile to add this Guardian (Simulating Firestore Write)
      const users = JSON.parse(localStorage.getItem('db_users') || '{}');
      if (users[userUid]) {
        if (!users[userUid].guardians) users[userUid].guardians = [];
        users[userUid].guardians.push(state.uid);
        localStorage.setItem('db_users', JSON.stringify(users));
        
        showToast("Successfully linked!");
        showScreen('screen-guardian-dash');
        this.pollForAlerts();
      }
    } else {
      showToast("Invalid code!");
    }
  },

  // --- GUARDIAN ALERT POLLING ---
  pollForAlerts() {
    let lastAlertCount = 0;
    setInterval(() => {
      if (!state.linkedUserUid) return;
      const alerts = JSON.parse(localStorage.getItem(`db_alerts_${state.linkedUserUid}`) || '[]');
      if (alerts.length > lastAlertCount) {
        // New alert arrived!
        const latestAlert = alerts[alerts.length - 1];
        showToast(`🚨 ALERT: ${latestAlert.message}`);
        this.updateAlertsUI(alerts);
        lastAlertCount = alerts.length;
      }
    }, 2000);
  },

  updateAlertsUI(alerts) {
    const list = document.getElementById('alerts-list');
    list.innerHTML = '';
    alerts.reverse().forEach(alert => {
      list.innerHTML += `
        <div style="padding: 1rem; background: rgba(244, 63, 94, 0.1); border-left: 4px solid var(--accent); margin-bottom: 0.5rem; border-radius: 4px;">
          <div style="font-weight: 600; color: var(--accent);">${alert.type}</div>
          <div style="font-size: 0.9rem;">${alert.message}</div>
          <div style="font-size: 0.7rem; color: var(--text-muted); margin-top: 0.5rem;">${new Date(alert.timestamp).toLocaleTimeString()}</div>
        </div>
      `;
    });
  },

  // --- MOCK NATIVE FEATURES (USER) ---
  triggerLinkAlert() {
    // 1. Simulate finding a bad link
    showToast("Suspicious link blocked!");
    
    // 2. Write alert to database for Guardian
    const alerts = JSON.parse(localStorage.getItem(`db_alerts_${state.uid}`) || '[]');
    alerts.push({
      type: "Suspicious Link",
      message: "User clicked a potentially malicious URL.",
      timestamp: Date.now()
    });
    localStorage.setItem(`db_alerts_${state.uid}`, JSON.stringify(alerts));
    
    // (In reality, here is where we POST to FCM using Guardian's fcm_token)
  },

  triggerBankingBlock() {
    // Simulate Android overlay
    document.getElementById('overlay-banking').classList.remove('hidden');
    
    // Send alert to guardian
    const alerts = JSON.parse(localStorage.getItem(`db_alerts_${state.uid}`) || '[]');
    alerts.push({
      type: "Security Lockout",
      message: "Banking apps temporarily locked due to recent unknown SMS OTP.",
      timestamp: Date.now()
    });
    localStorage.setItem(`db_alerts_${state.uid}`, JSON.stringify(alerts));
  }
};

// Initialize App
window.onload = () => {
  // Clear mock DB on fresh load for easy testing
  // localStorage.clear();
};
