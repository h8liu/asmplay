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
        'var msg {',
        '    str     "Hello, world!\\n\\x00"',
        '}',
        '',
        'func main {',
        '    xor     r0 r0 r0 // clear r0',
        '    lui     r3 msg',
        '    ori     r3 r3 msg',
        '',
        '.loop',
        '    lb      r1 r3',
        '    beq     r1 r0 .end',
        '    jal     printChar',
        '    addi    r3 r3 1 // inc',
        '    j       .loop',
        '',
        '.end',
        '    halt',
        '}',
        '',
        '// print the char in r1',
        'func printChar {',
        '    addi    r2 r0 0x2000',
        '.loop',
        '    lbu     r4 r2 1',
        '    bne     r4 r0 .loop // wait for invalid',
        '',
        '    sb      r1 r2',
        '',
        '    addi    r1 r0 1',
        '    sb      r1 r2 1',
        '',
        '    mov     pc ret',
        '}',
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
    $("#run").html(res.out)
    # $("#stmt-tree").html(parsed.block)
    return

main = ->
    editorInit()
    # exampleInit()
    update()
    e8vm.editor.getSession().on("change", ->
        update()
        return
    )
    return

$(document).ready(main)
