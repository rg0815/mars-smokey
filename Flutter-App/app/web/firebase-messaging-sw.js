
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

const firebaseConfig = {
  apiKey: "AIzaSyCrceZ5SAULEw_wrNk4S7-aPGdJmnudQFQ",
  authDomain: "ssds-112.firebaseapp.com",
  projectId: "ssds-112",
  storageBucket: "ssds-112.appspot.com",
  messagingSenderId: "36419882218",
  appId: "1:36419882218:web:05daf8924fa97ba9d91b93",
  measurementId: "G-ERPCPGHRFT"
};
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });