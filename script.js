import { initializeApp } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js";
import { getFirestore, collection, addDoc, onSnapshot, deleteDoc, doc, orderBy, query } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore.js";
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-auth.js";
import { getStorage, ref, uploadBytes, getDownloadURL } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-storage.js";

const firebaseConfig = {
  apiKey: "AIzaSyCPu2xi_tQmBHOl9FZxu_q3sLoSfJj7Voc",
  authDomain: "project01-1e217.firebaseapp.com",
  projectId: "project01-1e217",
  storageBucket: "project01-1e217.firebasestorage.app",
  messagingSenderId: "438455079136",
  appId: "1:438455079136:web:4865d0ec3ed299de0bc085"
};

try {
    const app = initializeApp(firebaseConfig);
    const db = getFirestore(app);
    const auth = getAuth(app);
    const storage = getStorage(app);

    const mainContent = document.getElementById('mainContent');
    const sidebarList = document.getElementById('sidebarList');
    
    // ★ 全データを保存しておくための箱
    let allMemos = [];

    // データベース監視
    const q = query(collection(db, "memos"), orderBy("createdAt", "desc"));

    onSnapshot(q, (snapshot) => {
        // データを取得して箱に入れる
        allMemos = [];
        snapshot.forEach((doc) => {
            allMemos.push({ id: doc.id, ...doc.data() });
        });

        // 最初は「すべて(all)」を表示
        renderList("all");
    });

    // ★ ナビゲーションのクリック処理
    const navItems = document.querySelectorAll('#navList li');
    navItems.forEach(item => {
        item.addEventListener('click', () => {
            // 1. 他のタブの active を消して、これに active をつける
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');

            // 2. data-cat に書いてあるカテゴリ名を取得 (all, music, art...)
            const category = item.dataset.cat;

            // 3. そのカテゴリでリストを再表示
            renderList(category);
        });
    });

    // ★ リストとメイン画面を表示する関数
    function renderList(filterCategory) {
        if (!mainContent || !sidebarList) return;

        sidebarList.innerHTML = '';
        mainContent.innerHTML = '';

        // カテゴリで絞り込み（allなら全部、それ以外なら一致するものだけ）
        const filteredMemos = allMemos.filter(memo => {
            if (filterCategory === 'all') return true;
            return memo.category === filterCategory;
        });

        // データがない場合
        if (filteredMemos.length === 0) {
            mainContent.innerHTML = "<p style='padding:20px;'>このカテゴリの投稿はまだありません。</p>";
            return;
        }

        // サイドバーを作る
        filteredMemos.forEach((memo) => {
            const div = document.createElement('div');
            div.classList.add('sidebar-item');
            div.textContent = memo.title;
            
            // クリックでメイン表示
            div.addEventListener('click', () => {
                displayMain(memo);
            });
            sidebarList.appendChild(div);
        });

        // 絞り込んだリストの一番最新（0番目）をメインに表示
        displayMain(filteredMemos[0]);
    }

    // --- 管理画面用（そのまま） ---
    const loginBtn = document.getElementById('loginBtn');
    if (loginBtn) {
        // ...admin処理（長くなるので省略なしでそのまま記述します）...
         const loginArea = document.getElementById('loginArea');
        const adminArea = document.getElementById('adminArea');
        const logoutBtn = document.getElementById('logoutBtn');
        const addBtn = document.getElementById('addBtn');

        onAuthStateChanged(auth, (user) => {
            if (user) {
                if(loginArea) loginArea.style.display = 'none';
                if(adminArea) adminArea.style.display = 'flex';
                if(document.getElementById('userEmail')) document.getElementById('userEmail').textContent = user.email;
            } else {
                if(loginArea) loginArea.style.display = 'block';
                if(adminArea) adminArea.style.display = 'none';
            }
        });

        loginBtn.addEventListener('click', async () => {
            try { await signInWithEmailAndPassword(auth, document.getElementById('emailInput').value, document.getElementById('passInput').value); } 
            catch (e) { alert("ログイン失敗: " + e.message); }
        });

        if(logoutBtn) logoutBtn.addEventListener('click', async () => { await signOut(auth); });

        if(addBtn) addBtn.addEventListener('click', async function() {
            const category = document.getElementById('categorySelect').value;
            const title = document.getElementById('titleInput').value;
            const content = document.getElementById('contentInput').value;
            const imageInput = document.getElementById('imageInput');

            if (title === '' && content === '') return;
            try {
                let downloadURL = "";
                if (imageInput && imageInput.files.length > 0) {
                    const file = imageInput.files[0];
                    const fileName = new Date().getTime() + "_" + file.name;
                    const storageRef = ref(storage, "images/" + fileName);
                    await uploadBytes(storageRef, file);
                    downloadURL = await getDownloadURL(storageRef);
                }
                await addDoc(collection(db, "memos"), {
                    category: category, title: title, content: content, imageUrl: downloadURL, createdAt: new Date()
                });
                document.getElementById('titleInput').value = '';
                document.getElementById('contentInput').value = '';
                if(imageInput) imageInput.value = '';
            } catch (e) { alert("投稿エラー: " + e.message); }
        });
    }

} catch (e) {
    console.error(e);
}

// メイン表示関数
function displayMain(data) {
    if (!document.getElementById('mainContent')) return;
    let categoryLabel = "その他";
    if (data.category === "music") categoryLabel = "🎵 作曲";
    if (data.category === "art") categoryLabel = "🎨 イラスト";
    
    let dateStr = "";
    if (data.createdAt) {
        const d = data.createdAt.toDate();
        dateStr = `${d.getFullYear()}/${d.getMonth()+1}/${d.getDate()} ${d.getHours()}:${d.getMinutes()}`;
    }

    let imageHTML = "";
    if (data.imageUrl) {
        imageHTML = `<img src="${data.imageUrl}" style="max-width:100%; border-radius:8px; margin-top:20px;">`;
    }

    document.getElementById('mainContent').innerHTML = `
        <span class="main-date">${dateStr}</span>
        <div class="main-category">${categoryLabel}</div>
        <h2 class="main-title">${escapeHTML(data.title)}</h2>
        <div class="main-body">${escapeHTML(data.content)}</div>
        ${imageHTML}
    `;
}

function escapeHTML(str) {
    if (!str) return "";
    return str.replace(/[&<>"']/g, match => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[match]));
}