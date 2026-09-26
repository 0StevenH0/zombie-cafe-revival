package copylist

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

const srcDir = "../../../src"

// build_tool aborts on the first listed file that is missing.
func TestCopyFilesExist(t *testing.T) {
	for _, f := range GetCopyFiles() {
		if _, err := os.Stat(filepath.Join(srcDir, f)); err != nil {
			t.Errorf("listed but missing: %s", f)
		}
	}
}

// A smali class left out of the list is silently dropped from the APK and only
// fails at runtime (NoClassDefFoundError), e.g. after src/java/build.sh adds a
// class to the offline server.
func TestAllSmaliListed(t *testing.T) {
	listed := map[string]bool{}
	for _, f := range GetCopyFiles() {
		listed[f] = true
	}
	err := filepath.WalkDir(filepath.Join(srcDir, "smali"), func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || !strings.HasSuffix(path, ".smali") {
			return nil
		}
		rel, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}
		if !listed[filepath.ToSlash(rel)] {
			t.Errorf("smali file not in copy list: %s", filepath.ToSlash(rel))
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}
