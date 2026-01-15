// 1. HTMLの要素を取得
const taskInput = document.getElementById('taskInput');
const addBtn = document.getElementById('addBtn');
const taskList = document.getElementById('taskList');

// 2. ページを開いた時に、保存されたデータを読み込む
document.addEventListener('DOMContentLoaded', function() {
    loadTasks();
});

// 3. 「追加」ボタンが押された時の処理
addBtn.addEventListener('click', function() {
    const taskText = taskInput.value;

    if (taskText === '') {
        alert('タスクを入力してください！');
        return;
    }

    // タスクを追加する関数を呼び出す
    addTaskToDOM(taskText);
    
    // データを保存する
    saveTasks();

    taskInput.value = '';
});

// --- 以下、新しく作った関数たち ---

// 画面にタスクを表示する関数（作成と読み込みの両方で使うため共通化）
function addTaskToDOM(text) {
    const li = document.createElement('li');

    // ★重要：文字とボタンを分けるためにspanタグを使う
    // （保存時にボタンの「削除」という文字まで保存しないようにするため）
    const span = document.createElement('span');
    span.textContent = text;
    li.appendChild(span);

    const deleteBtn = document.createElement('button');
    deleteBtn.textContent = '削除';
    deleteBtn.classList.add('delete-btn');

    deleteBtn.addEventListener('click', function() {
        taskList.removeChild(li);
        // 削除したあとに、保存し直す（データを更新）
        saveTasks();
    });

    li.appendChild(deleteBtn);
    taskList.appendChild(li);
}

// データをブラウザに保存する関数
function saveTasks() {
    const tasks = [];
    // 現在リストにあるすべてのli要素を探す
    const listItems = taskList.querySelectorAll('li');

    // ひとつずつ文字を取り出して配列に入れる
    listItems.forEach(function(item) {
        // liの中のspanタグの文字だけを取得
        const text = item.querySelector('span').textContent;
        tasks.push(text);
    });

    // 配列を文字に変換(JSON)して、localStorageに保存
    localStorage.setItem('todoList', JSON.stringify(tasks));
}

// データをブラウザから読み込む関数
function loadTasks() {
    // 保存されたデータを取得
    const savedTasks = localStorage.getItem('todoList');

    // もしデータがあれば
    if (savedTasks) {
        // 文字(JSON)を配列に戻す
        const tasks = JSON.parse(savedTasks);
        
        // 配列の中身を順番に画面に追加していく
        tasks.forEach(function(text) {
            addTaskToDOM(text);
        });
    }
}