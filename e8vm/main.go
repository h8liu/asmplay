package main

import (
	"bytes"
	"fmt"
	"html/template"
	"strings"
	"io/ioutil"
	"io"

	"github.com/gopherjs/gopherjs/js"

	"lonnie.io/e8vm/arch8"
	"lonnie.io/e8vm/conv"
	"lonnie.io/e8vm/asm8"
	"lonnie.io/e8vm/dasm8"
	"lonnie.io/e8vm/lex8"
)

func main() {
	js.Global.Set("e8vm", map[string]interface{}{
		"compile": compile,
	})
}

func compile(file, code string) map[string]interface{} {
	ret := make(map[string]interface{})
	dump, errs, out := _compile(file, code)
	ret["dasm"] = dump
	ret["errs"] = errs
	ret["out"] = out

	return ret
}

func buildBareFunc(file, code string) ([]byte, []*lex8.Error) {
	rc := ioutil.NopCloser(strings.NewReader(code))
	return asm8.BuildSingleFile(file, rc)
}

func run(bs []byte, out io.Writer) (int, error) {
	r := bytes.NewBuffer(bs)

	m := arch8.NewMachine(uint32(1<<30), 1)

	e := m.LoadImage(r, conv.InitPC)
	if e != nil {
		return 0, e
	}

	m.SetOutput(out)
	ret, exp := m.Run(100000)
	if exp == nil {
		return ret, nil
	}

	return ret, exp
}

func _compile(file, code string) (dump, errs, out string) {
	dasm := new(bytes.Buffer)
	errOut := new(bytes.Buffer)
	output := new(bytes.Buffer)

	bs, es := buildBareFunc(file, code)
	if len(es) > 0 {
		for _, e := range es {
			fmt.Fprintf(errOut, `<div class="error">%s</div>` + "\n",
				template.HTMLEscapeString(e.Error()),
			)
		}
		return "", errOut.String(), ""
	}

	lines := dasm8.Dasm(bs, conv.InitPC)
	for _, line := range lines {
		fmt.Fprintf(dasm, `%s` + "\n",
			template.HTMLEscapeString(line.String()),
		)
	}

	ncycle, e := run(bs, output)
	fmt.Fprintf(output, "(%d cycles)\n", ncycle)
	if e != nil {
		fmt.Fprintln(output, e)
	}

	return dasm.String(), "", output.String()
}
