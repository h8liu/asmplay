editorInit = ->
    Range = ace.require("ace/range").Range
    editor = ace.edit("editor")
    e8vm.editor = editor
    session = editor.getSession()

    editor.setTheme("ace/theme/tomorrow")
    session.setMode("ace/mode/golang")
    editor.renderer.setShowGutter(false)
    editor.setHighlightActiveLine(false)
    editor.setShowFoldWidgets(false)
    editor.setDisplayIndentGuides(false)
    # editor.setReadOnly(false)
    ff = "Consolas, Inconsolata, Monaco, \"Courier New\", Courier, monospace"
    editor.setOptions({
        maxLines: Infinity,
        minLines: 10,
        fontFamily: ff,
        fontSize: "13px",
    })
    editor.commands.removeCommands(["gotoline", "find"])

    prog = [
        'mov r0 r1',
    ].join('\n')

    editor.setValue(prog)
    editor.clearSelection()
    return

exampleInit = ->
    examples = ['3p4']

    ul = $('<ul id="examples"/>')
    for f in examples
        li = $('<li><a href="#">' + f + '</a></li>')
        li.find('a').click( (e) ->
            e.preventDefault()
            # console.log("load file: "+f)
            $.ajax("tests/" + f + ".x", {
                success: (dat) ->
                    e8vm.editor.setValue(dat)
                    e8vm.editor.clearSelection()
                    return
            })
            return
        )
        ul.append(li)

    $("div#filelist").append(ul)
    return

update = ->
    code = e8vm.editor.getValue()
    # tokens = e8vm.parseTokens("", code)
    # $("#tokens").html(tokens)
    res = e8vm.compile("func.s8", code)
    $("#compile").html(res.errs)
    $("#dasm").html(res.dasm)
    # $("#stmt-tree").html(parsed.block)

    return

main = ->
    editorInit()
    exampleInit()
    update()
    e8vm.editor.getSession().on("change", ->
        update()
        return
    )
    return

$(document).ready(main)
