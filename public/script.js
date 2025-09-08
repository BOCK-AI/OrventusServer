document.addEventListener('DOMContentLoaded', () => {
  // --- References to HTML elements (no changes here) ---
  const authForm = document.getElementById('auth-form');
  const phoneInput = document.getElementById('phone');
  const roleInput = document.getElementById('role');
  const logoutBtn = document.getElementById('logout-btn');
  const profileSection = document.getElementById('profile-section');
  const getProfileBtn = document.getElementById('get-profile-btn');
  const updateForm = document.getElementById('update-form');
  const nameInput = document.getElementById('name');
  const emailInput = document.getElementById('email');
  const responseOutput = document.getElementById('response-output');

  // --- State (no changes here) ---
  let accessToken = null;

  // --- Helper function to display success responses ---
  function displaySuccess(data) {
    responseOutput.style.color = 'black'; // Reset color on success
    responseOutput.textContent = JSON.stringify(data, null, 2);
  }

  // --- NEW: Helper function to display error messages ---
  function displayError(errorMessage) {
    // We can use a simple alert for a clear, user-friendly error message.
    alert(`Error: ${errorMessage}`);
    
    // We'll also show it in the response box for debugging.
    responseOutput.style.color = 'red'; // Make errors stand out
    responseOutput.textContent = JSON.stringify({ error: errorMessage }, null, 2);
  }

  // --- Event Listener for Login/Register (Updated Logic) ---
  authForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('/auth/signin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone: phoneInput.value, role: roleInput.value }),
      });
      const data = await res.json();

      // --- NEW: Check if the response was successful ---
      if (!res.ok) {
        // If not OK, it's an error. The message is in data.msg.
        throw new Error(data.msg || 'An unknown error occurred.');
      }

      displaySuccess(data);
      accessToken = data.access_token;
      profileSection.style.display = 'block';
      logoutBtn.style.display = 'inline-block';
    } catch (error) {
      displayError(error.message);
    }
  });

  // --- Event Listener for Getting Profile (Updated Logic) ---
  getProfileBtn.addEventListener('click', async () => {
    if (!accessToken) {
      displayError('You must be logged in to get a profile.');
      return;
    }
    try {
      const res = await fetch('/api/v1/users/me', {
        method: 'GET',
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.msg || 'Failed to fetch profile.');
      }

      displaySuccess(data);
    } catch (error) {
      displayError(error.message);
    }
  });

  // --- Event Listener for Updating Profile (Updated Logic) ---
  updateForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (!accessToken) {
      displayError('You must be logged in to update a profile.');
      return;
    }
    try {
      const res = await fetch('/api/v1/users/me', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({ name: nameInput.value, email: emailInput.value }),
      });
      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.msg || 'Failed to update profile.');
      }

      displaySuccess(data);
    } catch (error) {
      displayError(error.message);
    }
  });

  // --- Event Listener for Logout (Updated Logic) ---
  logoutBtn.addEventListener('click', async () => {
    try {
      const res = await fetch('/auth/logout', { method: 'POST' });
      const data = await res.json();
      
      if (!res.ok) {
        throw new Error(data.msg || 'Logout failed.');
      }

      displaySuccess(data);
      accessToken = null;
      profileSection.style.display = 'none';
      logoutBtn.style.display = 'none';
    } catch (error) {
      displayError(error.message);
    }
  });
});