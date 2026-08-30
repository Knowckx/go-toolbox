package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	for _, src := range os.Args[1:] {
		ext := filepath.Ext(src)
		base := strings.TrimSuffix(src, ext)
		dst := base + ".hard" + ext

		if err := os.Link(src, dst); err != nil {
			fmt.Printf("创建失败: %s\n%v\n", src, err)
		}
	}
}