//go:build linux

package process

import (
	"bytes"
	"os/exec"
	"strconv"
	"strings"
)

// Linux
func (*Process) FindPIdByName(pName string) (int, error) {
	cmd := exec.Command("pgrep", pName)
	var out bytes.Buffer
	cmd.Stdout = &out
	if err := cmd.Run(); err != nil {
		return 0, err
	}
	pidStr := strings.TrimSpace(out.String())
	pid, err := strconv.Atoi(pidStr)
	if err != nil {
		return 0, err
	}
	return pid, nil
}
