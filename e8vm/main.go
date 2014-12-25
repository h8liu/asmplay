package main

import (
	"bytes"
	"fmt"
	"html/template"
	"strings"
	"io/ioutil"

	"github.com/gopherjs/gopherjs/js"

	"lonnie.io/e8vm/arch8"
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
	dump, errs := _compile(file, code)
	ret["dasm"] = dump
	ret["errs"] = errs

	return ret
}

func buildBareFunc(file, code string) ([]byte, []*lex8.Error) {
	rc := ioutil.NopCloser(strings.NewReader(code))
	return asm8.BuildBareFunc(file, rc)
}

func _compile(file, code string) (dump, errs string) {
	out := new(bytes.Buffer)
	errOut := new(bytes.Buffer)

	bs, es := buildBareFunc(file, code)
	if len(es) > 0 {
		for _, e := range es {
			fmt.Fprintf(errOut, `<div class="error">%s</div>` + "\n",
				template.HTMLEscapeString(e.Error()),
			)
		}
		return "", errOut.String()
	}

	lines := dasm8.Dasm(bs, arch8.InitPC)
	for _, line := range lines {
		fmt.Fprintf(out, `<div class="dasm">%s</div>` + "\n",
			template.HTMLEscapeString(line.String()),
		)
	}
	return out.String(), ""
}
