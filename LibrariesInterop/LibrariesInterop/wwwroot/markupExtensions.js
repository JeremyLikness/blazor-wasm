window.markupExtensions = {
    toHtml: (txt, target) => {
        const area = document.createElement("textarea");
        area.innerHTML = txt;
        target.innerHTML = area.value;
    }
}