JsOsaDAS1.001.00bplist00�Vscript_�function TaskPaperCollapseDeferredItems(editor, options) {
    var items = editor.outline.evaluateItemPath('//@type=project or @type=task or @type=note');
    for (idx in items) {
        var item = items[idx];
        if (item.hasAttribute("data-defer")) {
            editor.setCollapsed(item);
        }
    }

    return 0;
}

Application("TaskPaper").documents[0].evaluate({
    script: TaskPaperCollapseDeferredItems.toString()
})                              �jscr  ��ޭ