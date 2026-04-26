package findcopy

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Run finds files under src that match ext and copies them into dst.
func Run(args []string) error {
	fs := flag.NewFlagSet("find-and-copy", flag.ContinueOnError)
	fs.SetOutput(io.Discard)

	var (
		srcPath = fs.String("src", "", "source directory")
		dstPath = fs.String("dst", "", "destination directory")
		ext     = fs.String("ext", "", "file suffix to match")
	)

	if err := fs.Parse(args); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			printUsage()
			return nil
		}
		return err
	}

	if strings.TrimSpace(*srcPath) == "" {
		return errors.New("missing required flag: -src")
	}
	if strings.TrimSpace(*dstPath) == "" {
		return errors.New("missing required flag: -dst")
	}
	if strings.TrimSpace(*ext) == "" {
		return errors.New("missing required flag: -ext")
	}

	srcRoot, err := filepath.Abs(*srcPath)
	if err != nil {
		return fmt.Errorf("resolve source path: %w", err)
	}
	dstRoot, err := filepath.Abs(*dstPath)
	if err != nil {
		return fmt.Errorf("resolve destination path: %w", err)
	}

	srcInfo, err := os.Stat(srcRoot)
	if err != nil {
		return fmt.Errorf("stat source path: %w", err)
	}
	if !srcInfo.IsDir() {
		return fmt.Errorf("source path is not a directory: %s", srcRoot)
	}

	if err := os.MkdirAll(dstRoot, 0o755); err != nil {
		return fmt.Errorf("create destination directory: %w", err)
	}
	if samePath(srcRoot, dstRoot) {
		return fmt.Errorf("source and destination must be different: %s", srcRoot)
	}

	matchExt := normalizeSuffix(*ext)
	return walkDFS(srcRoot, dstRoot, func(path string) error {
		if !strings.HasSuffix(strings.ToLower(path), matchExt) {
			return nil
		}

		relPath, err := filepath.Rel(srcRoot, path)
		if err != nil {
			return fmt.Errorf("resolve relative path for %s: %w", path, err)
		}

		targetPath := filepath.Join(dstRoot, relPath)
		if err := os.MkdirAll(filepath.Dir(targetPath), 0o755); err != nil {
			return fmt.Errorf("create target directory for %s: %w", targetPath, err)
		}
		if err := copyFile(path, targetPath); err != nil {
			return err
		}

		fmt.Printf("%s -> %s\n", path, targetPath)
		return nil
	})
}

func printUsage() {
	fmt.Println("find-and-copy")
	fmt.Println("usage: find-and-copy -src <source> -dst <target> -ext <suffix>")
}

func normalizeSuffix(ext string) string {
	trimmed := strings.TrimSpace(ext)
	if trimmed == "" {
		return ""
	}
	if !strings.HasPrefix(trimmed, ".") {
		trimmed = "." + trimmed
	}
	return strings.ToLower(trimmed)
}

func walkDFS(root, skipRoot string, visit func(string) error) error {
	entries, err := os.ReadDir(root)
	if err != nil {
		return err
	}

	sort.Slice(entries, func(i, j int) bool {
		return entries[i].Name() < entries[j].Name()
	})

	for _, entry := range entries {
		fullPath := filepath.Join(root, entry.Name())
		if skipRoot != "" && isSameOrDescendant(fullPath, skipRoot) {
			continue
		}
		if entry.IsDir() {
			if err := walkDFS(fullPath, skipRoot, visit); err != nil {
				return err
			}
			continue
		}

		if err := visit(fullPath); err != nil {
			return err
		}
	}

	return nil
}

func samePath(left, right string) bool {
	return strings.EqualFold(filepath.Clean(left), filepath.Clean(right))
}

func isSameOrDescendant(path, root string) bool {
	cleanPath := filepath.Clean(path)
	cleanRoot := filepath.Clean(root)

	if strings.EqualFold(cleanPath, cleanRoot) {
		return true
	}

	prefix := cleanRoot + string(os.PathSeparator)
	return strings.HasPrefix(strings.ToLower(cleanPath), strings.ToLower(prefix))
}

func copyFile(srcPath, dstPath string) error {
	srcFile, err := os.Open(srcPath)
	if err != nil {
		return fmt.Errorf("open source file %s: %w", srcPath, err)
	}
	defer srcFile.Close()

	srcInfo, err := srcFile.Stat()
	if err != nil {
		return fmt.Errorf("stat source file %s: %w", srcPath, err)
	}

	dstFile, err := os.Create(dstPath)
	if err != nil {
		return fmt.Errorf("create destination file %s: %w", dstPath, err)
	}
	defer func() {
		_ = dstFile.Close()
	}()

	if _, err := io.Copy(dstFile, srcFile); err != nil {
		return fmt.Errorf("copy %s to %s: %w", srcPath, dstPath, err)
	}

	if err := dstFile.Sync(); err != nil {
		return fmt.Errorf("sync destination file %s: %w", dstPath, err)
	}

	if err := dstFile.Chmod(srcInfo.Mode()); err != nil {
		return fmt.Errorf("set destination mode for %s: %w", dstPath, err)
	}

	return nil
}
