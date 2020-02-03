const gui = (options, dropHandler) => {

    const fitSize = () => {
        const cpos = $('#consol').offset();
        $('#app').css('width', $('body').width());
        $('#consol')
            .css('height', window.innerHeight - cpos.top - 20)
            .css('width', $('body').width() - 10)
            .css('font-size', `${options.consoleFontSize}`);
        //console.log(window.innerHeight);
    }

    let fileDialogs = 0;

    $(window).resize(fitSize);
    $('#save_options').click(saveOptions);
    $('#save_export').click(exportData);
    $('#bytes_per_line').change(updateAfterEdit);
    $('#consol').click(removeSelection);


    $('html').on("dragover", function (event) {
        event.preventDefault();
        event.stopPropagation();

    });

    $('html').on("dragleave", function (event) {
        event.preventDefault();
        event.stopPropagation();
    });

    $('html').on("drop", function (event) {
        event.preventDefault();
        event.stopPropagation();
        if (event.originalEvent.dataTransfer.files) {
            // Use DataTransferItemList interface to access the file(s)
            for (var i = 0; i < event.originalEvent.dataTransfer.files.length; i++) {
                // If dropped items aren't files, reject them
                const file = event.originalEvent.dataTransfer.files[i];
                if (confirm(`Load new file ${file.name}?`)) {
                    dropHandler(file);
                }
            }
        }

    });


    const addMenuItem = (name, handler, parent = 'menulist', hint) => {
        const li = $('<li/>').html(name).addClass('menuitem').bind('click', handler);
        if (hint) li.attr('title', hint);
        li.appendTo(`#${parent}`);
        return li;
    }

    const addMenuFileOpen = (name, handler, parent = 'menulist', hint) => {
        const inp = $(`<input type='file' id='fdialog${fileDialogs}' class='fileinput'>`);
        const label = $('<label/>').attr('for', `fdialog${fileDialogs}`).html(name).addClass('menuitem');
        inp.change(handler);
        if (hint) label.attr('title', hint);
        $(`#${parent}`).append(inp, label);
        fileDialogs++;
        return label;
    }


    const addSeparator = (parent = 'menulist') => {
        $('<div/>').addClass('menuseparator').appendTo(`#${parent}`)
    }

    const addBR = (parent = 'menulist') => {
        $('<div/>').addClass('menubr').appendTo(`#${parent}`)
    }

    return {
        addMenuItem,
        addMenuFileOpen,
        addSeparator,
        addBR,
        fitSize
    }
};
