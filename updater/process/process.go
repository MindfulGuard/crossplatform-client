package process

import (
	"bytes"
	"fmt"
	"os/exec"
	"runtime"
	"strconv"
	"strings"

	"golang.org/x/sys/windows"
)

type Process struct{}

func NewProcess() *Process {
	return &Process{}
}

func (p *Process) Kill(pid int64) error {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("taskkill", "/F", "/PID", strconv.FormatInt(pid, 10))
	} else if runtime.GOOS == "linux" {
		cmd = exec.Command("kill", strconv.FormatInt(pid, 10))
	} else {
		return fmt.Errorf("unsupported operating system")
	}

	if err := cmd.Run(); err != nil {
		return err
	}

	return nil
}

func (prcs *Process) FindPIdByName(pName string) (int64, error) {
	os := runtime.GOOS
	switch os {
	case "windows":
		v, err := prcs.findPIdByNameWindows(pName)
		return int64(v), err
	case "linux":
		v, err := prcs.findPIdByNameLinux(pName)
		return int64(v), err
	default:
		panic("unknown operating system")
	}
}

func (*Process) findPIdByNameWindows(pName string) (uint32, error) {
	const processEntrySize = 568

	h, e := windows.CreateToolhelp32Snapshot(windows.TH32CS_SNAPPROCESS, 0)
	if e != nil {
		return 0, e
	}
	p := windows.ProcessEntry32{Size: processEntrySize}
	for {
		e := windows.Process32Next(h, &p)
		if e != nil {
			return 0, e
		}
		if windows.UTF16ToString(p.ExeFile[:]) == pName {
			return p.ProcessID, nil
		}
	}
}

func (*Process) findPIdByNameLinux(pName string) (int, error) {
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
