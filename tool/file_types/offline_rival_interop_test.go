package file_types

import (
	"bytes"
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// TestOfflineRivalInterop runs the offline server's Java self-test and then
// re-parses every rival cafe it generated with this package's reference
// FriendCafe parser, so the on-device generator and the Go format definitions
// can never drift apart silently.
//
// It needs the compiled Java classes, so it only runs when
// ZC_OFFLINE_CLASSPATH is set (src/java/test.sh does that):
//
//	ZC_OFFLINE_CLASSPATH=<classes>:<android.jar> go test ./tool/file_types -run TestOfflineRivalInterop -v
func TestOfflineRivalInterop(t *testing.T) {
	classpath := os.Getenv("ZC_OFFLINE_CLASSPATH")
	if classpath == "" {
		t.Skip("ZC_OFFLINE_CLASSPATH not set; run src/java/test.sh")
	}

	tmp := t.TempDir()

	// The APK ships characterData.bin.mid, which the build tool produces from
	// this JSON; build the same binary so the Java catalog parser sees real data.
	raw, err := os.ReadFile(filepath.Join("..", "..", "src", "assets", "data", "characterData.bin.mid.json"))
	if err != nil {
		t.Fatalf("read character JSON: %v", err)
	}
	var characters []Character
	if err := json.Unmarshal(raw, &characters); err != nil {
		t.Fatalf("parse character JSON: %v", err)
	}
	var catalog bytes.Buffer
	WriteCharacters(&catalog, characters)
	catalogPath := filepath.Join(tmp, "characterData.bin.mid")
	if err := os.WriteFile(catalogPath, catalog.Bytes(), 0o644); err != nil {
		t.Fatal(err)
	}

	outDir := filepath.Join(tmp, "rivals")
	cmd := exec.Command("java", "-cp", classpath,
		"com.capcom.zombiecafeandroid.offline.OfflineSelfTest",
		filepath.Join("testdata", "ServerData.dat"), catalogPath, outDir)
	out, err := cmd.CombinedOutput()
	t.Logf("java self-test output:\n%s", out)
	if err != nil {
		t.Fatalf("java self-test failed: %v", err)
	}

	entries, err := os.ReadDir(outDir)
	if err != nil {
		t.Fatalf("read rival dir: %v", err)
	}
	if len(entries) == 0 {
		t.Fatal("java self-test wrote no rival cafes")
	}
	source := ReadFriendData(mustOpen(t, filepath.Join("testdata", "ServerData.dat")))

	for _, e := range entries {
		path := filepath.Join(outDir, e.Name())
		data, err := os.ReadFile(path)
		if err != nil {
			t.Fatal(err)
		}
		if !ValidateFriendData(bytes.NewReader(data)) {
			t.Errorf("%s: trailing bytes after FriendCafe", e.Name())
			continue
		}
		cafe := ReadFriendData(bytes.NewReader(data))
		if cafe.Version != 63 {
			t.Errorf("%s: version %d", e.Name(), cafe.Version)
		}
		if int(cafe.State.NumZombies) != len(cafe.State.Zombies) || cafe.State.NumZombies == 0 {
			t.Errorf("%s: %d zombies", e.Name(), cafe.State.NumZombies)
		}
		if !cafe.State.U10 || !strings.HasSuffix(cafe.State.Character.Name, "\r\x00") {
			t.Errorf("%s: owner chef missing or misnamed: %q", e.Name(), cafe.State.Character.Name)
		}
		// Only the state block is generated; the layout must be the source's, untouched.
		if cafe.Cafe.MapSizeX != source.Cafe.MapSizeX || len(cafe.Cafe.Tiles) != len(source.Cafe.Tiles) {
			t.Errorf("%s: cafe layout changed", e.Name())
		}
		t.Logf("%s: level %d, %d defenders, owner %q", e.Name(), cafe.State.Level, cafe.State.NumZombies,
			strings.TrimRight(cafe.State.Character.Name, "\r\x00"))
	}
}

func mustOpen(t *testing.T, path string) *os.File {
	t.Helper()
	f, err := os.Open(path)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { f.Close() })
	return f
}
