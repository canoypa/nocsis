importScripts("https://www.gstatic.com/firebasejs/8.6.8/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.8/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBzIPmQKtoKybxCWpb3ErbQ5ohW4FPCR7g",
  authDomain: "class-clock-40088.firebaseapp.com",
  projectId: "class-clock-40088",
  storageBucket: "class-clock-40088.appspot.com",
  messagingSenderId: "219141289630",
  appId: "1:219141289630:web:6988629faf082890b1ad8f",
  measurementId: "G-KEGZJCNJDX",
});

const messaging = firebase.messaging();
