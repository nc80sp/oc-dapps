
async function checkAccess() {
    var path = window.location.pathname;
    const suffix = "index.html";
    if (path.endsWith(suffix)) {
        path = path.slice(0, -suffix.length);
    }
    const segments = path.split("/").filter(Boolean);
    let currentDir = segments.length > 0 ? segments[segments.length - 1] : "";
    const pageId = currentDir;

    var hasAccess = await contract.checkAccess(userAddress, pageId);
    //hasAccess = true; //※デバッグ用※
    if (!hasAccess) {
        document.getElementById("loading").innerHTML = "サイト閲覧の権限がありません。購入ページに移動します。";
        redirectToFolder(pageId);
    } else {
        // 読み込み中メッセージを非表示
        document.getElementById("loading").style.display = "none";

        // コンテンツを表示
        document.getElementById("content").style.display = "block";
    }
}

function redirectToFolder(pageId) {
    const base = window.location.origin;
    const target = `${base}/contents/?id=` + pageId;
    setTimeout(() => (window.location.href = target), 1500);
}

document.addEventListener("DOMContentLoaded", async () => {
    let result = await connectWallet(true);
    if (result) {
        checkAccess();
    }
});
