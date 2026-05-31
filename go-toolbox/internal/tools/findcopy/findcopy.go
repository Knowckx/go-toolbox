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

type Runner struct {
	srcRoot               string
	dstRoot               string
	matchExt              string
	skipRoot              string
	copiedCount           int
	firstLevelFolderCount int
	seenTargets           map[string]string
}

func (r *Runner) Run(args []string) error {
	if err := r.parseArgs(args); err != nil {
		return err
	}

	r.seenTargets = make(map[string]string)

	if err := r.countFirstLevelFolders(); err != nil {
		return err
	}

	if err := r.copyMatchedFiles(); err != nil {
		return err
	}

	fmt.Printf("successfully copied: %d/%d\n", r.copiedCount, r.firstLevelFolderCount)
	return nil
}

func (r *Runner) parseArgs(args []string) error {
	fs := flag.NewFlagSet("find-and-copy", flag.ContinueOnError)
	fs.SetOutput(io.Discard)

	var folder string
	var ext string
	var srcPath string

	fs.StringVar(&srcPath, "src", "", "source directory")
	fs.StringVar(&folder, "folder", "", "subfolder under source directory")
	fs.StringVar(&ext, "ext", "", "file suffix to match")

	if err := fs.Parse(args); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			r.printUsage()
			return nil
		}
		return err
	}

	if strings.TrimSpace(srcPath) == "" {
		return errors.New("missing required flag: -src")
	}
	if strings.TrimSpace(ext) == "" {
		return errors.New("missing required flag: -ext")
	}

	srcRoot, err := filepath.Abs(srcPath)
	if err != nil {
		return fmt.Errorf("resolve source path: %w", err)
	}
	srcInfo, err := os.Stat(srcRoot)
	if err != nil {
		return fmt.Errorf("stat source path: %w", err)
	}
	if !srcInfo.IsDir() {
		return fmt.Errorf("source path is not a directory: %s", srcRoot)
	}
	r.srcRoot = srcRoot

	dstRoot := srcRoot
	if trimmedFolder := strings.TrimSpace(folder); trimmedFolder != "" {
		dstRoot = filepath.Join(srcRoot, trimmedFolder)
	}
	if err := os.MkdirAll(dstRoot, 0o755); err != nil {
		return fmt.Errorf("create destination directory: %w", err)
	}
	r.dstRoot = dstRoot

	if !samePath(r.srcRoot, r.dstRoot) {
		r.skipRoot = r.dstRoot
	}

	r.matchExt = normalizeSuffix(ext)
	return nil
}

func (r *Runner) countFirstLevelFolders() error {
	entries, err := os.ReadDir(r.srcRoot)
	if err != nil {
		return err
	}
	count := 0
	for _, entry := range entries {
		if entry.IsDir() {
			count++
		}
	}
	r.firstLevelFolderCount = count
	return nil
}

func (r *Runner) copyMatchedFiles() error {
	return walkDFS(r.srcRoot, r.skipRoot, r.visitFile)
}

func (r *Runner) visitFile(path string) error {
	if !strings.HasSuffix(strings.ToLower(path), r.matchExt) {
		return nil
	}

	targetPath := filepath.Join(r.dstRoot, filepath.Base(path))
	targetKey := strings.ToLower(targetPath)
	// 防止本次运行内，两个源文件撞到同一个目标名
	if firstSource, exists := r.seenTargets[targetKey]; exists {
		fmt.Printf("duplicate file skipped: %s (already used by %s)\n", path, firstSource)
		return nil
	}
	// 防止覆盖磁盘上已经存在的目标文件。
	if _, err := os.Stat(targetPath); err == nil {
		fmt.Printf("duplicate file skipped: %s (already exists)\n", path)
		return nil
	}
	r.seenTargets[targetKey] = path

	if err := os.MkdirAll(filepath.Dir(targetPath), 0o755); err != nil {
		return fmt.Errorf("create target directory for %s: %w", targetPath, err)
	}
	if err := copyFile(path, targetPath); err != nil {
		return err
	}
	r.copiedCount++
	return nil
}

func (r *Runner) printUsage() {
	fmt.Println("find-and-copy")
	fmt.Println("usage: find-and-copy -src <source> -ext <suffix> [-folder <name>]")
}

// 以下工具函数保持不变

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
		if entry.IsDir() {
			continue
		}
		fullPath := filepath.Join(root, entry.Name())
		if skipRoot != "" && isSameOrDescendant(fullPath, skipRoot) {
			continue
		}
		if err := visit(fullPath); err != nil {
			return err
		}
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		fullPath := filepath.Join(root, entry.Name())
		if skipRoot != "" && isSameOrDescendant(fullPath, skipRoot) {
			continue
		}
		if err := walkDFS(fullPath, skipRoot, visit); err != nil {
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
	defer func() { _ = dstFile.Close() }()

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

