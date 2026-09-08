import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

/** Same Firebase project as the Flutter app (`connect-giant`). */
const firebaseConfig = {
  apiKey: 'AIzaSyA-nY2JIt6DlXTGpRuV63ZnVWSoSoCsm9I',
  authDomain: 'connect-giant.firebaseapp.com',
  projectId: 'connect-giant',
  storageBucket: 'connect-giant.appspot.com',
  messagingSenderId: '17932145134',
  appId: '1:17932145134:android:fb77f3e703ba8ae645beff',
};

const app = getApps().length ? getApps()[0]! : initializeApp(firebaseConfig);

export const db = getFirestore(app);
export const storage = getStorage(app);
