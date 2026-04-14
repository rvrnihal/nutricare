/* Firebase Messaging service worker for web push notifications */
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBn5KF9pPNBLB_za1ce-bbA3BwVnYU74tc',
  authDomain: 'nutricare-22ag.firebaseapp.com',
  projectId: 'nutricare-22ag',
  storageBucket: 'nutricare-22ag.firebasestorage.app',
  messagingSenderId: '247269293320',
  appId: '1:247269293320:web:67575a6b8f8ebce85540bd',
  measurementId: 'G-KRH4MWVGVB',
});

firebase.messaging();
