// Firebase Messaging Service Worker for tqwa-ai project

importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCF8ktbd-G4FQNF-5dOxQke1jHa4q27cWo',
  appId: '1:352375214270:web:7e43833f24c2c38e3a0eef',
  messagingSenderId: '352375214270',
  projectId: 'tqwa-ai',
  authDomain: 'tqwa-ai.firebaseapp.com',
  storageBucket: 'tqwa-ai.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
