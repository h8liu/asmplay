// Generated by CoffeeScript 1.9.0
(function() {
  var editorInit, exampleInit, main, update;

  editorInit = function() {
    var Range, editor, ff, prog, session;
    Range = ace.require("ace/range").Range;
    editor = ace.edit("editor");
    e8vm.editor = editor;
    session = editor.getSession();
    editor.setTheme("ace/theme/tomorrow");
    session.setMode("ace/mode/golang");
    editor.renderer.setShowGutter(false);
    editor.setHighlightActiveLine(false);
    editor.setShowFoldWidgets(false);
    editor.setDisplayIndentGuides(false);
    ff = "Consolas, Inconsolata, Monaco, \"Courier New\", Courier, monospace";
    editor.setOptions({
      maxLines: Infinity,
      minLines: 10,
      fontFamily: ff,
      fontSize: "13px"
    });
    editor.commands.removeCommands(["gotoline", "find"]);
    prog = ['var msg {', '    str     "Hello, world!\\n\\x00"', '}', '', 'func main {', '    xor     r0 r0 r0 // clear r0', '    lui     r3 msg', '    ori     r3 r3 msg', '', '.loop', '    lb      r1 r3', '    beq     r1 r0 .end', '    jal     printChar', '    addi    r3 r3 1 // inc', '    j       .loop', '', '.end', '    halt', '}', '', '// print the char in r1', 'func printChar {', '    addi    r2 r0 0x2000', '.loop', '    lbu     r4 r2 1', '    bne     r4 r0 .loop // wait for invalid', '', '    sb      r1 r2', '', '    addi    r1 r0 1', '    sb      r1 r2 1', '', '    mov     pc ret', '}'].join('\n');
    editor.setValue(prog);
    editor.clearSelection();
  };

  exampleInit = function() {
    var examples, f, li, ul, _i, _len;
    examples = ['3p4'];
    ul = $('<ul id="examples"/>');
    for (_i = 0, _len = examples.length; _i < _len; _i++) {
      f = examples[_i];
      li = $('<li><a href="#">' + f + '</a></li>');
      li.find('a').click(function(e) {
        e.preventDefault();
        $.ajax("tests/" + f + ".x", {
          success: function(dat) {
            e8vm.editor.setValue(dat);
            e8vm.editor.clearSelection();
          }
        });
      });
      ul.append(li);
    }
    $("div#filelist").append(ul);
  };

  update = function() {
    var code, res;
    code = e8vm.editor.getValue();
    res = e8vm.compile("func.s8", code);
    $("#compile").html(res.errs);
    $("#dasm").html(res.dasm);
    $("#run").html(res.out);
  };

  main = function() {
    editorInit();
    update();
    e8vm.editor.getSession().on("change", function() {
      update();
    });
  };

  $(document).ready(main);

}).call(this);

//# sourceMappingURL=play.js.map
