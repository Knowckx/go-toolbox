package main

import (
	"log"
	"os"

	"github.com/Knowckx/go-toolbox/internal/tools/findcopy"
)

func main() {
	log.SetFlags(0)

	runner := &findcopy.Runner{}
	if err := runner.Run(os.Args[1:]); err != nil {
		log.Fatal(err)
	}
}