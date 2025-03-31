import { WebviewWindow } from '@tauri-apps/api/webviewWindow'

const BITTE_URL = "https://bitte.ai/agents";

function checkOnlineStatus() {
  if (!navigator.onLine) {
    document.body.innerHTML = `
      <div style="
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100vh;
        font-family: system-ui, -apple-system, sans-serif;
        text-align: center;
        padding: 20px;
      ">
        <h2>No Internet Connection</h2>
        <p>Please check your internet connection and try again.</p>
        <button onclick="window.location.reload()" style="
          padding: 10px 20px;
          font-size: 16px;
          cursor: pointer;
          background: #007AFF;
          color: white;
          border: none;
          border-radius: 8px;
          margin-top: 20px;
        ">
          Retry
        </button>
      </div>
    `;
  }
}

// Check online status initially and when it changes
window.addEventListener('online', () => window.location.reload());
window.addEventListener('offline', checkOnlineStatus);
checkOnlineStatus();

// If online, load Bitte AI
if (navigator.onLine) {
  window.location.href = BITTE_URL;
}

// Handle new window creation for popups
const originalWindowOpen = window.open;

// Add message listener for iframe popup requests
window.addEventListener('message', (event) => {
  if (event.data.type === 'OPEN_POPUP') {
    try {
      const popup = new WebviewWindow('popup', {
        url: event.data.url,
        title: "Wallet Connection",
        width: 400,
        height: 600,
        resizable: true,
        center: true,
        decorations: true,
        visible: true,
        focus: true,
        alwaysOnTop: true,
        skipTaskbar: true,
        transparent: false,
        fullscreen: false,
        maximized: false,
        minWidth: 400,
        minHeight: 600,
      });

      // Add error handling for the popup window
      popup.once('tauri://error', (error) => {
        console.error('Popup window error:', error);
        // Fallback to browser window if Tauri window fails
        window.open(event.data.url, '_blank');
      });
    } catch (error) {
      console.error('Failed to create popup window:', error);
      // Fallback to browser window if Tauri window fails
      window.open(event.data.url, '_blank');
    }
  }
});

window.open = function (url?: string | URL, target?: string, features?: string): globalThis.Window | null {
  if (!url) return null;

  const urlString = url.toString();

  // Handle WalletConnect popups, NEAR wallet popups, or other trusted external services
  if (urlString.includes("walletconnect") ||
      urlString.includes("bitte.ai") ||
      urlString.includes("near.org") ||
      urlString.includes("near-wallet")) {
    try {
      // Check if we're in an iframe
      const isInIframe = window !== window.parent;

      if (isInIframe) {
        // When in iframe, try to open in parent window
        window.parent.postMessage({ type: 'OPEN_POPUP', url: urlString }, '*');
        return null;
      }

      // Create a new window with more specific options
      const popup = new WebviewWindow(target || 'popup', {
        url: urlString,
        title: "Wallet Connection",
        width: 400,
        height: 600,
        resizable: true,
        center: true,
        decorations: true,
        visible: true,
        focus: true,
        alwaysOnTop: true,
        skipTaskbar: true,
        transparent: false,
        fullscreen: false,
        maximized: false,
        minWidth: 400,
        minHeight: 600,
      });

      // Add error handling for the popup window
      popup.once('tauri://error', (error) => {
        console.error('Popup window error:', error);
        // Fallback to browser window if Tauri window fails
        return originalWindowOpen.call(window, url, target, features);
      });

      return null; // Prevent default browser popup
    } catch (error) {
      console.error('Failed to create popup window:', error);
      // Fallback to browser window if Tauri window fails
      return originalWindowOpen.call(window, url, target, features);
    }
  }

  // Otherwise, open normally in a browser
  return originalWindowOpen.call(window, url, target, features);
};